local openid = require("openid.introspection")
local cjson = require "cjson"
local exception = require("util.exception")

connect = {}

local config_dict = ngx.shared.config_dict

local config  = {}

local function validation_error(details)
    exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "OpenID validation", details)
end

local function failed_error(details)
    exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "OpenID failed", details)
end

local function authenticate_failed_error(details)
    exception.exception(ngx.HTTP_FORBIDDEN, "Authorization failed", details)
end

local function validate() 

    config.discovery_url = ngx.shared.config_dict:get("openid_discovery_url")
    config.validate_scope = ngx.shared.config_dict:get("openid_validate_scope")
    config.client_id = ngx.shared.config_dict:get("openid_client_id")
    config.client_secret = ngx.shared.config_dict:get("openid_client_secret")
    config.flow_type = ngx.shared.config_dict:get("openid_flow_type")

    if not config.discovery_url then
        validation_error("openid discovery_url not configured")
    end

    if not config.validate_scope == nil then
        validation_error("openid validate_scope not configured")
    end

    if not config.client_id then
        validation_error("openid client_id not configured")
    end

    if not config.client_secret then
        validation_error("openid client_secret not configured")
    end

    if not config.flow_type then
        validation_error("openid flow_type not configured")
    end


    ngx.log(ngx.DEBUG, "discovery_url: ", config.discovery_url)
    ngx.log(ngx.DEBUG, "validate_scope: ",config.validate_scope)
    ngx.log(ngx.DEBUG, "flow_type: ", config.flow_type)
    ngx.log(ngx.DEBUG, "client_id: ", config.client_id and "************" or "nil")
    ngx.log(ngx.DEBUG, "client_secret: ", config.client_secret and "************" or "nil")


end

function connect.authenticate()

    ngx.log(ngx.INFO, "Authorizing .........")

    validate()

    local opts = {
        discovery = config.discovery_url,
        client_id = config.client_id,
        client_secret = config.client_secret,
        token_signing_alg_values_supported = {"RS256"},
        ssl_verify = "no",
        validate_scope = config.validate_scope,
        proxy_opts = nil  -- No proxy needed
    }

    local status = nil

    if(config.flow_type == "introspection") then

        status = openid.introspection(opts)

    else

        failed_error("Flow type not support : ", config.flow_type)

    end

    if status.error then

        authenticate_failed_error(status.error)

        return 
    end

    ngx.req.set_header("X-User", status.response.sub)  -- you can pass user info to the upstream service
    
    ngx.log(ngx.DEBUG, "User: ", status.response.sub)
    ngx.log(ngx.DEBUG, "Token is valid. Roles: ", require("cjson").encode(status.response.realm_access.roles))

    if status.response.realm_access.roles ~= nil then
        
        ngx.req.set_header("X-Roles", table.concat(status.response.realm_access.roles, ","))  -- example passing roles
    end
 
    ngx.log(ngx.INFO, "Authorized!")

end

return connect