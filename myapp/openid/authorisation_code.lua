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

    config = util.common_validation()
    config.validate_scope = config_dict:get("openid_authentication_validate_scope")
    config.scope = config_dict:get("openid_authentication_scope")
    config.redirect_uri = config_dict:get("openid_authentication_redirect_uri")
    config.redirect_uri_scheme = config_dict:get("openid_authentication_redirect_uri_scheme")
    
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

function openid.authenticate() 

    validate_auth()

    local opts = {
        discovery = config.discovery_url,
        client_id = config.client_id,
        client_secret = config.client_secret,
        token_signing_alg_values_supported = {"RS256"},
        ssl_verify = config.ssl_verify,
        proxy_opts = config.proxy_opts  -- No proxy needed
    }

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

    local session = r_session.start(config)
    local res, err, target, session = openidc.authenticate(opts, nil, nil, session)

    if not err  then
        ngx.log(ngx.DEBUG, "Session data authenticated =============== ")
        ngx.log(ngx.DEBUG, "authenticated: ", session:get("authenticated"))

        -- ngx.log(ngx.DEBUG, "access_token_expiration: ", session:get("access_token_expiration"))
        -- ngx.log(ngx.DEBUG, "refresh_token: ", session:get("refresh_token"))
        -- ngx.log(ngx.DEBUG, "enc_id_token: ", session:get("enc_id_token"))
        -- ngx.log(ngx.DEBUG, "access_token: ", session:get("access_token"))
        local body = {
            access_token = session:get("access_token"),
            access_token_expiration = session:get("access_token_expiration"),
            id_token = session:get("enc_id_token"),
            refresh_token = session:get("refresh_token")
        }

        ngx.header.content_type = "application/json"

        ngx.say(cjson.encode(body))
        ngx.exit(ngx.HTTP_OK)

    else
        validation_error("Error in authentiction: ", err)
    end

end

local function validate_redirect_auth() 

    config = util.common_validation()
    
    config.redirect_uri = config_dict:get("openid_authentication_redirect_uri")
    config.redirect_uri_scheme = config_dict:get("openid_authentication_redirect_uri_scheme")

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
    local res, err = openidc.authenticate(opts, nil, "deny", session)

    if err then

        authenticate_failed_error(err)

        return 
    end

    ngx.log(ngx.DEBUG, "redirect res: ", cjson.encode(res))
    ngx.log(ngx.INFO, "Authentication redirected!")

end


return openid