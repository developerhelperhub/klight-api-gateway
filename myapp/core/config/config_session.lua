local config = {}

local config_dict = ngx.shared.config_dict

function config.config(name, config)

    local main_config = config["session"]

    if main_config ~= nil then

        if main_config["secure"] ~= nil then
            config_dict:set("session_secure", main_config["secure"])
        end 

        if main_config["httponly"] ~= nil then
            config_dict:set("session_httponly", main_config["httponly"])
        end

        ngx.log(ngx.INFO, "Loaded Session Config : ", name, "!")
        
        config_dict:set("session_configured", true)
        
    else
        if config_dict:get("session_configured") ~= true then
            config_dict:set("session_configured", false)
        end
    end

    ngx.log(ngx.DEBUG, "Loaded Session Config - session_configured : ", config_dict:get("session_configured"))

end

return config