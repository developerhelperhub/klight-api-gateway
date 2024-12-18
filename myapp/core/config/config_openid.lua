local config = {}

local config_dict = ngx.shared.config_dict

function config.config(name, config)

    local openid = config["openid"]

    if openid ~= nil then

        if openid["discovery_url"] ~= nil then
            config_dict:set("openid_discovery_url", openid["discovery_url"])
        end

        if openid["client_id"] ~= nil then
            config_dict:set("openid_client_id", openid["client_id"])
        end 

        if openid["client_secret"] ~= nil then
            config_dict:set("openid_client_secret", openid["client_secret"])
        end

        if openid["flow_type"] ~= nil then
            config_dict:set("openid_flow_type", openid["flow_type"])
        end

        if openid["introspection_endpoint"] ~= nil then
            config_dict:set("openid_introspection_endpoint", openid["introspection_endpoint"])
        end

        if openid["scope"] ~= nil then
            config_dict:set("openid_scope", openid["scope"])
        end
    
        if openid["validate_scope"] ~= nil then
            config_dict:set("openid_validate_scope", openid["validate_scope"])
        end

        if openid["redirect_uri"] ~= nil then
            config_dict:set("openid_redirect_uri", openid["redirect_uri"])
        end

        if openid["redirect_uri_scheme"] ~= nil then
            config_dict:set("openid_redirect_uri_scheme", openid["redirect_uri_scheme"])
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