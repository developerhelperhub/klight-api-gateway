local openidc = require("resty.openidc")

openid = {}

local config_dict = ngx.shared.config_dict

local config  = {}


local function validate() 

    config.introspection_endpoint = ngx.shared.config_dict:get("openid_introspection_endpoint")

    ngx.log(ngx.DEBUG, "introspection_endpoint: ", config.introspection_endpoint)

end

function openid.introspection(opts) 

    opts.introspection_endpoint = config.introspection_endpoint
    opts.introspection_expiry_claim = "exp"

    local res, err = openidc.introspect(opts)

    return {
        response = res,
        error = err
    }

end

return openid