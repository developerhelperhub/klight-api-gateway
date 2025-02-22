local http = require("resty.http")
local exception = require("util.exception")
local cjson = require("cjson")

local obj = {}
local discovery_body = ngx.shared.discovery_body

local function log_discovery(discovery) 
    ngx.log(ngx.DEBUG, "discovery token_endpoint :", discovery.token_endpoint)
    ngx.log(ngx.DEBUG, "discovery issuer :", discovery.issuer)
    ngx.log(ngx.DEBUG, "discovery authorization_endpoint :", discovery.authorization_endpoint)
    -- ngx.log(ngx.DEBUG, "discovery jwks_uri :", discovery.jwks_uri)
    -- ngx.log(ngx.DEBUG, "discovery userinfo_endpoint :", discovery.userinfo_endpoint)
end

function obj.discovery(config) 

    local local_discovery_body = discovery_body:get("discovery_body")
    local request = false

    if local_discovery_body == nil then
        ngx.log(ngx.INFO, "Discovery body requsting!")
        ngx.log(ngx.INFO, "Discovery URL :", config.discovery_url)

        local httpc = http.new()
        local res, err = httpc:request_uri(config.discovery_url, { method = "GET" })

        if not res or res.status ~= 200 then
            exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "OpenID validation", err)
        end

        local_discovery_body = res.body

        discovery_body:set("discovery_body", local_discovery_body)

        request = true
    
    else
        ngx.log(ngx.INFO, "Discovery body loaded!")
    end 

    local discovery = cjson.decode(local_discovery_body)

    if request == true then

        ngx.log(ngx.DEBUG, "discovery body : --------------")

        log_discovery(discovery)

        ngx.log(ngx.DEBUG, "discovery maped config : -------------")
    end

    if config.discovery_issuer ~= nil then
        discovery.issuer = config.discovery_issuer
    end
    
    if config.discovery_token_endpoint ~= nil then
        discovery.token_endpoint = config.discovery_token_endpoint
    end

    if config.discovery_authorization_endpoint ~= nil then
        discovery.authorization_endpoint = config.discovery_authorization_endpoint
    end

    if config.discovery_jwks_uri ~= nil then
        discovery.jwks_uri = config.discovery_jwks_uri
    end

    if config.discovery_userinfo_endpoint ~= nil then
        discovery.userinfo_endpoint = config.discovery_userinfo_endpoint
    end

    if config.discovery_introspection_endpoint ~= nil then
        discovery.introspection_endpoint = config.discovery_introspection_endpoint
    end

    if config.discovery_introspection_endpoint ~= nil then
        discovery.introspection_endpoint = config.discovery_introspection_endpoint
    end

    if request == true then
        log_discovery(discovery)
    end

    return discovery
end

return obj