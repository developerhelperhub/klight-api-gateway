local yaml = require("lyaml")
local config_mongo = require("core.config.config_mongo")
local config_openid = require("core.config.config_openid")

local config = {}

local config_dict = ngx.shared.config_dict

function config.is_load()
    return config_dict:get("config_security_loaded")
end

function config.load(app_env)

    local config_file = "config-security.yaml"

    config_dict:set("config_security_loaded", false)

    ngx.log(ngx.INFO, "Loading Security Config YAML...")

    if not app_env then
        ngx.log(ngx.DEBUG, "APP_ENV is not set!")
    else
        ngx.log(ngx.INFO, "APP_ENV: ", app_env)

        config_file = "config-security-" .. app_env .. ".yaml"
    end

    ngx.log(ngx.INFO, "Security Config file: ", config_file)

    local root_path = ngx.config.prefix()
    local file, err = io.open(root_path .. "/" .. config_file, "r")

    if not file then

        ngx.log(ngx.INFO, "Not found the security configuration!")

    else

        local content = file:read("*all")
        file:close()

        local config = yaml.load(content)

        config_mongo.config("secuirty", config)

        config_openid.config("secuirty", config)
        
        config_dict:set("config_security_loaded", true)

        ngx.log(ngx.INFO, "Loaded Security Config!")

    end
end


return config