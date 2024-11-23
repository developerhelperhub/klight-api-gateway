local openidc = require("resty.openidc")
local exception = require("util.exception")
local r_session = require("openid.session")
local util = require("openid.util")
local http = require "resty.http"
local cjson = require "cjson"

local openid = {}

local config_dict = ngx.shared.config_dict

local config  = {}

local function validation_error(details)
    exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "OpenID validation", details)
end

local function validate_auth() 

    config.validate_scope = config_dict:get("openid_validate_scope")
    config.scope = config_dict:get("openid_scope")
    config.redirect_uri = config_dict:get("openid_redirect_uri")
    config.redirect_uri_scheme = config_dict:get("openid_redirect_uri_scheme")
    config.refresh_token_lifetime = config_dict:get("openid_refresh_token_lifetime")
    config.access_token_lifetime = config_dict:get("openid_access_token_lifetime")
    config.token_validation_type = config_dict:get("token_validation_type")
    
    if not config.validate_scope == nil then
        validation_error("openid validate_scope not configured")
    end

    if not config.scope == nil then
        validation_error("openid scope not configured")
    end

    if not config.redirect_uri == nil then
        validation_error("openid redirect_uri not configured")
    end

    if not config.redirect_uri_scheme == nil then
        validation_error("openid redirect_uri_scheme not configured")
    end

    if not config.refresh_token_lifetime == nil then
        validation_error("openid refresh_token_lifetime not configured")
    end

    if not config.access_token_lifetime == nil then
        validation_error("openid access_token_lifetime not configured")
    end

    if not config.token_validation_type == nil then
        validation_error("openid token_validation_type not configured")
    end

    if config.token_validation_type == "introspection" then

        config.token_validation_intro_endpoint = config_dict:get("token_validation_intro_endpoint")

        if not config.token_validation_intro_endpoint == nil then
            validation_error("openid token_validation_intro_endpoint not configured")
        end

    else
        validation_error("openid token type " .. config.token_validation_type .. " not supported!")
    end

    ngx.log(ngx.DEBUG, "validate_scope: ", config.validate_scope)
    ngx.log(ngx.DEBUG, "scope: ", config.scope)
    ngx.log(ngx.DEBUG, "redirect_uri: ", config.redirect_uri)
    ngx.log(ngx.DEBUG, "redirect_uri_scheme: ", config.redirect_uri_scheme)
    ngx.log(ngx.DEBUG, "refresh_token_lifetime: ", config.refresh_token_lifetime)
    ngx.log(ngx.DEBUG, "access_token_lifetime: ", config.access_token_lifetime)
    ngx.log(ngx.DEBUG, "token_validation_type: ", config.token_validation_type)

end

local function find_user(session, connect_config) 

    local access_token = nil
    local refresh_token = nil
    local access_token_expiration = nil

    local found = false
    
    local user = session:get("user")
    local sub = nil

    if user then

        ngx.log(ngx.INFO, "User found!")
        ngx.log(ngx.DEBUG, "user: ", cjson.encode(user))

        sub = user.sub
        access_token = util.get_access_token(sub)
        access_token_expiration = util.get_access_token_expiration(sub)
        refresh_token = util.get_refresh_token(sub)

        if (access_token == nil and refresh_token == nil) or refresh_token == nil then
            
            ngx.log(ngx.INFO, "Token not found in redis")

            found = false
        else

            ngx.log(ngx.INFO, "Token found in redis")

            found = true
        end
    else 
        ngx.log(ngx.INFO, "User not found!")

        found = false
    end

    return {
        found = found,
        sub = sub,
        access_token_expiration = access_token_expiration,
        access_token = access_token,
        refresh_token = refresh_token
    }
end

local function authenticate_user(session, user, opts) 

    ngx.log(ngx.DEBUG, "Inital authentication!")

    opts.validate_scope = config.validate_scope
    opts.scope = config.scope .. " offline_access"
    opts.redirect_uri_scheme = config.redirect_uri_scheme
    opts.grant_type="authorization_code"
    opts.redirect_uri = config.redirect_uri

    if opts.validate_scope == false then
        opts.scope = nil 
    end

    opts.debug = true

    -- openidc.set_logging(nil, { DEBUG = ngx.INFO })

    local res, err, target, session = openidc.authenticate(opts, nil, nil, session)

    if not err then

        ngx.log(ngx.DEBUG, "Session data authenticated =============== ")
        ngx.log(ngx.DEBUG, "authenticated: ", session:get("authenticated"))

        -- ngx.log(ngx.DEBUG, "access_token_expiration: ", session:get("access_token_expiration"))
        -- ngx.log(ngx.DEBUG, "refresh_token: ", session:get("refresh_token"))
        -- ngx.log(ngx.DEBUG, "enc_id_token: ", session:get("enc_id_token"))
        -- ngx.log(ngx.DEBUG, "access_token: ", session:get("access_token"))
        
        user.sub = session:get("user").sub
        user.access_token = session:get("access_token")
        user.access_token_expiration = session:get("access_token_expiration")
        user.refresh_token = session:get("refresh_token")
        
        session.data.user = session:get("user")
        
        r_session.save(session)

        util.redis_save_token(user, config)
    else

        ngx.log(ngx.ERR, "Error in authentiction: ", err)

        validation_error("Error in authentiction!")
    end

    user.res = res
    user.err = err

    return user
end

function openid.authenticate(opts, connect_config) 

    validate_auth()

    local cookies = ngx.var.http_cookie
    local uri = ngx.var.uri
    
    ngx.log(ngx.INFO, "request uri : ", uri)

    local session = r_session.start(connect_config)
    local user = find_user(session, connect_config)

    if user.found == false then
        
        ngx.log(ngx.DEBUG, "Token not found!")

        user = authenticate_user(session, user, opts)

    else

        ngx.log(ngx.DEBUG, "Token found!")
        ngx.log(ngx.DEBUG, "Token validation type :", config.token_validation_type)

        -- if config.token_validation_type == "introspection" then
        
        --     user = token_validation_introspection(user, connect_config)

        -- end

        -- if user.err then

        --     ngx.log(ngx.INFO, "Token is invalid and logout!")

        --     user = logout(user, connect_config)

        --     user.res = nil
        --     user.err = "Logout the session!"
        -- end
    end

    return {
        response = user.res,
        error = user.err
    }

end


local function validate_redirect_auth() 

    config.discovery_url = config_dict:get("openid_discovery_url")
    config.client_id  = config_dict:get("openid_client_id")
    config.client_secret  = config_dict:get("openid_client_secret")
    config.redirect_uri = config_dict:get("openid_redirect_uri")
    config.redirect_uri_scheme = config_dict:get("openid_redirect_uri_scheme")

    if not config.discovery_url then
        validation_error("openid discovery_url not configured")
    end

    if not config.client_id then
        validation_error("openid client_id not configured")
    end

    if not config.client_secret then
        validation_error("openid client_secret not configured")
    end

    if not config.redirect_uri == nil then
        validation_error("openid redirect_uri not configured")
    end

    if not config.redirect_uri_scheme == nil then
        validation_error("openid redirect_uri_scheme not configured")
    end

    ngx.log(ngx.DEBUG, "redirect_uri_scheme: ", config.redirect_uri_scheme)

end

local function authenticate_failed_error(details)
    exception.exception(ngx.HTTP_FORBIDDEN, "Authorization redirect failed", details)
end

function openid.redirect_authenticate() 

    ngx.log(ngx.DEBUG, "OpenID redirect authentication...")
    ngx.log(ngx.DEBUG, "OpenID configured : ", config_dict:get("openid_configured"))

    if config_dict:get("openid_configured") == false then

        ngx.log(ngx.INFO, "OpenID not configured!!!")

        return

    end

    validate_redirect_auth()

    local opts = {
        discovery = config.discovery_url,
        client_id = config.client_id,
        client_secret = config.client_secret,
        redirect_uri = config.redirect_uri,
        redirect_uri_scheme = config.redirect_uri_scheme
    }

    -- ngx.log(ngx.DEBUG, "OpenID configurations : ", cjson.encode(opts))

    ngx.log(ngx.DEBUG, "redirect_uri : ", config.redirect_uri)

    -- openidc.set_logging(nil, { DEBUG = ngx.INFO })

    local session = r_session.start(config)
    local user = find_user(session, config)
    local res, err = openidc.authenticate(opts, nil, "deny", session)

    if err then

        authenticate_failed_error(err)

        return 
    end

    ngx.log(ngx.DEBUG, "redirect res: ", cjson.encode(res))
    ngx.log(ngx.INFO, "Authentication redirected!")

end


return openid