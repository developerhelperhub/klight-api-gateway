local config = {}

local config_dict = ngx.shared.config_dict

function config.config(name, config)

    local main_config = config["redis"]

    if main_config ~= nil then

        if main_config["host"] ~= nil then
            config_dict:set("redis_host", main_config["host"])
        end 

        if main_config["port"] ~= nil then
            config_dict:set("redis_port", main_config["port"])
        end

        if main_config["connection_timeout"] ~= nil then
            config_dict:set("redis_connection_timeout", main_config["connection_timeout"])
        end

        if main_config["pool_idle_timeout"] ~= nil then
            config_dict:set("redis_pool_idle_timeout", main_config["pool_idle_timeout"])
        end

        if main_config["pool_size"] ~= nil then
            config_dict:set("redis_pool_size", main_config["pool_size"])
        end

        if main_config["username"] ~= nil then
            config_dict:set("redis_username", main_config["username"])
        end

        if main_config["password"] ~= nil then
            config_dict:set("redis_password", main_config["password"])
        end

        ngx.log(ngx.INFO, "Loaded Redis Config : ", name, "!")
        
        config_dict:set("redis_configured", true)
        
    else
        if config_dict:get("redis_configured") ~= true then
            config_dict:set("redis_configured", false)
        end
    end

    ngx.log(ngx.DEBUG, "Loaded Redis Config - redis_configured : ", config_dict:get("redis_configured"))

end

return config