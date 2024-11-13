local openidc = require("resty.openidc")
local exception = require("util.exception")
local cjson = require "cjson"

local openid = {}

local config_dict = ngx.shared.config_dict

local config  = {}

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

function openid.introspection(opts) 

    validate()
    
    opts.introspection_endpoint = config.introspection_endpoint
    opts.introspection_expiry_claim = "exp"

    local res, err = openidc.introspect(opts)

    return {
        response = res,
        error = err
    }

end

return openid