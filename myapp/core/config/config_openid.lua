local config = {}

local config_dict = ngx.shared.config_dict

function config.config(name, config)

    local openid = config["openid"]

    if openid ~= nil then

        local discovery = openid["discovery"]

        if discovery ~= nil then

            if discovery["url"] ~= nil then
                config_dict:set("openid_discovery_url", discovery["url"])
            end

            if discovery["token_endpoint"] ~= nil then
                config_dict:set("openid_discovery_token_endpoint", discovery["token_endpoint"])
            end

            if discovery["issuer"] ~= nil then
                config_dict:set("openid_discovery_issuer", discovery["issuer"])
            end

            if discovery["authorization_endpoint"] ~= nil then
                config_dict:set("openid_discovery_authorization_endpoint", discovery["authorization_endpoint"])
            end

            if discovery["jwks_uri"] ~= nil then
                config_dict:set("openid_discovery_jwks_uri", discovery["jwks_uri"])
            end

            if discovery["userinfo_endpoint"] ~= nil then
                config_dict:set("openid_discovery_userinfo_endpoint", discovery["userinfo_endpoint"])
            end

            if discovery["introspection_endpoint"] ~= nil then
                config_dict:set("openid_discovery_introspection_endpoint", discovery["introspection_endpoint"])
            end

            if discovery["end_session_endpoint"] ~= nil then
                config_dict:set("openid_discovery_end_session_endpoint", discovery["end_session_endpoint"])
            end

        end

        if openid["client_id"] ~= nil then
            config_dict:set("openid_client_id", openid["client_id"])
        end 

        if openid["client_secret"] ~= nil then
            config_dict:set("openid_client_secret", openid["client_secret"])
        end

        if openid["ssl_verify"] ~= nil then
            config_dict:set("openid_ssl_verify", openid["ssl_verify"])
        end

        if openid["session_secret"] ~= nil then
            config_dict:set("openid_session_secret", openid["session_secret"])
        end

        local token_validation = openid["token_validation"]

        if token_validation == nil or token_validation["type"] == nil then
            config_dict:set("token_validation_type", nil)

            ngx.log(ngx.DEBUG, "openid_token_validation_type not configured!")

        else
            
            ngx.log(ngx.DEBUG, "openid_token_validation_type : ", token_validation["type"])

            config_dict:set("openid_token_validation_type", token_validation["type"])

        end

        local authentication = openid["authentication"]

        if authentication == nil or authentication["flow_type"] == nil then
            config_dict:set("openid_authentication_flow_type", nil)

            ngx.log(ngx.DEBUG, "openid_authentication_flow_type not configured!")

        else

            if authentication["flow_type"] ~= nil then
                config_dict:set("openid_authentication_flow_type", authentication["flow_type"])
            end
    
            if authentication["scope"] ~= nil then
                config_dict:set("openid_authentication_scope", authentication["scope"])
            end
        
            if authentication["validate_scope"] ~= nil then
                config_dict:set("openid_authentication_validate_scope", authentication["validate_scope"])
            end
    
            if authentication["redirect_uri"] ~= nil then
                config_dict:set("openid_authentication_redirect_uri", authentication["redirect_uri"])
            end
    
            if authentication["redirect_uri_scheme"] ~= nil then
                config_dict:set("openid_authentication_redirect_uri_scheme", authentication["redirect_uri_scheme"])
            end
            
        end 

        config_dict:set("openid_configured", true)

        ngx.log(ngx.INFO, "Loaded OpenId Config : ", name, "!")
        ngx.log(ngx.DEBUG, "Loaded OpenId Config - validate_scope : ", openid["validate_scope"])
        
        
    else
        if config_dict:get("openid_configured") ~= true then
            config_dict:set("openid_configured", false)
        end
    end

    ngx.log(ngx.DEBUG, "Loaded OpenId Config - openid_configured : ", config_dict:get("openid_configured"))
end 


return config