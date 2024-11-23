local openidc = require("resty.openidc")
local exception = require("util.exception")
local redis = require("core.redis")

local cjson = require "cjson"

local openid = {}

local CACHE_KEY_TOKEN = "openid_authorise_code_token"
local CACHE_KEY_EXPIRE = "openid_authorise_code_expire"

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

    ngx.log(ngx.DEBUG, "validate_scope: ", config.validate_scope)
    ngx.log(ngx.DEBUG, "scope: ", config.scope)
    ngx.log(ngx.DEBUG, "redirect_uri: ", config.redirect_uri)
    ngx.log(ngx.DEBUG, "redirect_uri_scheme: ", config.redirect_uri_scheme)

end

local function redis_set(key, value, ttl)
    redis.set(key, cjson.encode(value), ttl)
end

local function redis_get(key)
    local token = redis.get(key)
    return token ~= nil and cjson.decode(token) or token
end


function openid.authenticate(opts) 

    validate_auth()

    local token = redis_get(CACHE_KEY_TOKEN)

    if token == nil then
        ngx.log(ngx.DEBUG, "Token not found and inital authentication!")

        opts.validate_scope = config.validate_scope
        opts.scope = config.scope .. " offline_access"
        opts.redirect_uri_scheme = config.redirect_uri_scheme
        opts.redirect_uri = config.redirect_uri
        opts.response_type = "code"
        opts.prompt = "consent"


        if opts.validate_scope == false then
            opts.scope = nil 
        end

        opts.session_contents = { state = true, id_token=true, access_token=true }

        -- ngx.log(ngx.DEBUG, "auth opts : ", cjson.encode(opts))


        local res, err = openidc.authenticate(opts)

        if not err then
            
            ngx.log(ngx.DEBUG, "token response : ", cjson.encode(res))
            
            local session = require("resty.session").start()
            ngx.log(ngx.DEBUG, "Session data : ", cjson.encode(session.data))
            ngx.log(ngx.DEBUG, "Session data access_token_expiration: ", session.data[1][1].access_token_expiration)
            ngx.log(ngx.DEBUG, "Session data authenticated: ", session.data[1][1].authenticated)
            ngx.log(ngx.DEBUG, "Session data refresh_token: ", session.data[1][1].refresh_token)
            ngx.log(ngx.DEBUG, "Session data enc_id_token: ", session.data[1][1].enc_id_token)

            -- refresh_expires_in, refresh_token, expires_in, access_token, token_type, id_token
            -- redis_set(CACHE_KEY_TOKEN, res, res.refresh_expires_in)
        end
    else

        ngx.log(ngx.DEBUG, "Token found!")

    end

    return {
        response = res,
        error = err
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
        redirect_uri_path = config.redirect_uri,
        redirect_uri_scheme = config.redirect_uri_scheme
    }

    -- ngx.log(ngx.DEBUG, "OpenID configurations : ", cjson.encode(opts))

    local res, err = openidc.authenticate(opts)

    if err then

        authenticate_failed_error(err)

        return 
    end

    ngx.log(ngx.DEBUG, "redirect res: ", cjson.encode(res))
    ngx.log(ngx.INFO, "Authentication redirected!")

end

local function validate_session()

    config.session_life_time = config_dict:get("openid_session_life_time")

    if not config.session_life_time == nil then
        validation_error("openid session_life_time not configured")
    end

    ngx.log(ngx.DEBUG, "session_life_time: ", config.session_life_time)

end

function openid.set_session(response) 

    ngx.log(ngx.DEBUG, "Create redis session authorisation_code...")

    validate_session()

    ngx.log(ngx.INFO, "Set redis session authorisation_code")
end

return openid