local openid_introspection = require("openid.introspection")
local openid_authorisation_code = require("openid.authorisation_code")
local exception = require("util.exception")
local openid_util = require("openid.util")
local auth_discovery = require("openid.discovery")

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
    config = openid_util.common_validation()
end

function connect.validate_token()

    ngx.log(ngx.DEBUG, "OpenID configured : ", config_dict:get("openid_configured"))

    if config_dict:get("openid_configured") == false then

        ngx.log(ngx.INFO, "OpenID not configured!!!")

        return

    end

    ngx.log(ngx.INFO, "Validating token .........")

    validate()

    local discovery = auth_discovery.discovery(config)

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

    if(config.token_validation_type == "introspection") then

        status = openid_introspection.introspection(opts, config)

    else

        failed_error("token_validation_type not support : ", config.token_validation_type)

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
 
    ngx.log(ngx.INFO, "Valid token!")

end

return connect