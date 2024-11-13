local openidc = require("resty.openidc")
local exception = require("util.exception")
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


function openid.authenticate(opts) 

    validate_auth()

    opts.validate_scope = config.validate_scope
    opts.scope = config.scope
    opts.redirect_uri_scheme = config.redirect_uri_scheme
    opts.redirect_uri = config.redirect_uri
    
    if opts.validate_scope == false then
        opts.scope = nil 
    end

    -- ngx.log(ngx.DEBUG, "OpenID configurations : ", cjson.encode(opts))

    local res, err = openidc.authenticate(opts)

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

return openid