local openidc = require("resty.openidc")
local exception = require("util.exception")
local cjson = require "cjson"
local auth_discovery = require("openid.discovery")

local openid = {}

local config_dict = ngx.shared.config_dict

local config  = {}
local connect_config = {}

local function validation_error(details)
    exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "OpenID validation", details)
end

local function validate(discovery) 

    if not discovery.introspection_endpoint then
        validation_error("openid introspection endpoint not configured")
    end

    ngx.log(ngx.DEBUG, "introspection_endpoint: ", discovery.introspection_endpoint)

end

function openid.introspection(opts, config) 

    local discovery = auth_discovery.discovery(config)

    validate(discovery)

    connect_config = config
    
    opts.introspection_endpoint = discovery.introspection_endpoint
    opts.introspection_expiry_claim = "exp"

    local res, err = openidc.introspect(opts)

    return {
        response = res,
        error = err
    }

end


return openid