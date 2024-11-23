local openid_introspection = require("openid.introspection")
local openid_authorisation_code = require("openid.authorisation_code")
local exception = require("util.exception")

local cjson = require "cjson"

local connect = {}

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

    config.discovery_url = config_dict:get("openid_discovery_url")
    config.client_id = config_dict:get("openid_client_id")
    config.client_secret = config_dict:get("openid_client_secret")
    config.flow_type = config_dict:get("openid_flow_type")
    config.ssl_verify = config_dict:get("openid_ssl_verify")
    

    if not config.discovery_url then
        validation_error("openid discovery_url not configured")
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

    if not config.ssl_verify then
        validation_error("openid openid_ssl_verify not configured")
    end


    ngx.log(ngx.DEBUG, "discovery_url: ", config.discovery_url)
    ngx.log(ngx.DEBUG, "flow_type: ", config.flow_type)
    ngx.log(ngx.DEBUG, "client_id: ", config.client_id and "************" or "nil")
    ngx.log(ngx.DEBUG, "client_secret: ", config.client_secret and "************" or "nil")
    ngx.log(ngx.DEBUG, "ssl_verify: ", config.ssl_verify)


end

function connect.authenticate()

    ngx.log(ngx.DEBUG, "OpenID configured : ", config_dict:get("openid_configured"))

    if config_dict:get("openid_configured") == false then

        ngx.log(ngx.INFO, "OpenID not configured!!!")

        return

    end

    ngx.log(ngx.INFO, "Authorizing .........")

    validate()

    config.proxy_opts = nil
    config.token_signing_alg_values_supported = {"RS256"}

    local opts = {
        discovery = config.discovery_url,
        client_id = config.client_id,
        client_secret = config.client_secret,
        token_signing_alg_values_supported = config.token_signing_alg_values_supported,
        ssl_verify = config.ssl_verify,
        proxy_opts = config.proxy_opts  -- No proxy needed
    }

    local status = nil

    if(config.flow_type == "introspection") then

        status = openid_introspection.introspection(opts, config)

    elseif(config.flow_type == "authorization_code") then

        status = openid_authorisation_code.authenticate(opts, config)

    else

        failed_error("Flow type not support : ", config.flow_type)

    end

    if status.error then

        authenticate_failed_error(status.error)

        return 
    end

    -- ngx.req.set_header("X-User", status.response.sub)  -- you can pass user info to the upstream service

    -- ngx.log(ngx.DEBUG, "User: ", status.response.sub)

    -- if status.response.realm_access ~= nil and status.response.realm_access.roles ~= nil then
        
    --     ngx.req.set_header("X-Roles", table.concat(status.response.realm_access.roles, ","))  -- example passing roles
    -- end
 
    ngx.log(ngx.INFO, "Authorized!")

end

return connect