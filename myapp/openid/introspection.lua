local openidc = require("resty.openidc")
local exception = require("util.exception")
local cjson = require "cjson"

local openid = {}

local config_dict = ngx.shared.config_dict

local config  = {}
local connect_config = {}

local function validation_error(details)
    exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "OpenID validation", details)
end

local function validate() 

    config.introspection_endpoint = ngx.shared.config_dict:get("openid_introspection_endpoint")

    if not config.introspection_endpoint then
        validation_error("openid introspection endpoint not configured")
    end

    ngx.log(ngx.DEBUG, "introspection_endpoint: ", config.introspection_endpoint)

end

function openid.introspection(opts, config) 

    validate()

    connect_config = config
    
    opts.introspection_endpoint = config.introspection_endpoint
    opts.introspection_expiry_claim = "exp"

    local res, err = openidc.introspect(opts)

    return {
        response = res,
        error = err
    }

end

function openid.introspection(user, connect_config)

    ngx.log(ngx.DEBUG, "Token validating .... [introspection]")

    local opts = {
        discovery = connect_config.discovery_url,
        client_id = connect_config.client_id,
        client_secret = connect_config.client_secret,
        token_signing_alg_values_supported = connect_config.token_signing_alg_values_supported,
        ssl_verify = connect_config.ssl_verify,
        proxy_opts = connect_config.proxy_opts,
        introspection_endpoint = config.token_validation_intro_endpoint,
        introspection_expiry_claim = "exp"
    }

    local header_value = "Bearer " .. user.access_token

    -- ngx.log(ngx.DEBUG, "Authorization header_value :", header_value)

    ngx.req.set_header("Authorization", "Bearer " .. user.access_token)

    -- openidc.set_logging(nil, { DEBUG = ngx.INFO })

    local res, err = openidc.introspect(opts)

    user.res = res
    user.err = err

    if user.err then
        ngx.log(ngx.WARN, "Introspection error :", user.err)
    end

    return user
    
end

return openid