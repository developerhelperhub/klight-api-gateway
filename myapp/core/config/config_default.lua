local yaml = require("lyaml")
local config_mongo = require("core.config.config_mongo")
local config_openid = require("core.config.config_openid")

local config = {}

local config_dict = ngx.shared.config_dict

function config.is_load()
    return config_dict:get("config_default_loaded")
end

function config.load(app_env)

    local config_file = "config.yaml"

    config_dict:set("config_default_loaded", false)

    ngx.log(ngx.INFO, "Default Loading Config YAML...")

    if not app_env then
        ngx.log(ngx.DEBUG, "APP_ENV is not set!")
    else
        ngx.log(ngx.INFO, "APP_ENV: ", app_env)

        config_file = "config-" .. app_env .. ".yaml"
    end

    ngx.log(ngx.INFO, "Default config file: ", config_file)

    local root_path = ngx.config.prefix()
    local file, err = io.open(root_path .. "/" .. config_file, "r")

    if not file then

        ngx.log(ngx.ERR, "Not found the default configuration!")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)

    else

        local content = file:read("*all")
        file:close()

        local config = yaml.load(content)

        config_mongo.config("default", config)

        config_openid.config("default", config)
        
        config_dict:set("config_default_loaded", true)

        ngx.log(ngx.INFO, "Loaded Default Config!")

    end
end


return config