local config = {}

local config_dict = ngx.shared.config_dict

function config.config(name, config)

    local mongodb = config["mongodb"]

    if mongodb ~= nil then

        if mongodb["host"] ~= nil then
            config_dict:set("mongodb_host", mongodb["host"])
        end 

        if mongodb["port"] ~= nil then
            config_dict:set("mongodb_port", mongodb["port"])
        end

        if mongodb["db"] ~= nil then
            config_dict:set("mongodb_db", mongodb["db"])
        end

        if mongodb["username"] ~= nil then
            config_dict:set("mongodb_username", mongodb["username"])
        end

        if mongodb["password"] ~= nil then
            config_dict:set("mongodb_password", mongodb["password"])
        end

        if mongodb["connection_pool_size"] ~= nil then
            config_dict:set("mongodb_connection_pool_size", mongodb["connection_pool_size"])
        end

        ngx.log(ngx.INFO, "Loaded Mongo Config : ", name, "!")
    end

end

return config