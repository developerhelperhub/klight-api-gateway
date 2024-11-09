local config = {}

local config_dict = ngx.shared.config_dict

function config.config(name, config)

    local openid = config["openid"]

    if openid ~= nil then

        if openid["discovery_url"] ~= nil then
            config_dict:set("openid_discovery_url", openid["discovery_url"])
        end

        if openid["validate_scope"] ~= nil then
            config_dict:set("openid_validate_scope", openid["validate_scope"])
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
    
        ngx.log(ngx.INFO, "Loaded OpenId Config : ", name, "!")
    end

end 


return config