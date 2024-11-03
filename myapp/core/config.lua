local yaml = require("lyaml")

local config = {}

local config_dict = ngx.shared.config_dict

function config.is_load()
    return config_dict:get("config_loaded")
end

function config.load()

    local app_env = os.getenv("APP_ENV")
    local config_file = "config.yaml"


    config_dict:set("config_loaded", false)

    ngx.log(ngx.INFO, "Loading Config YAML...")

    ngx.log(ngx.DEBUG, "LUA_PATH: ", package.path)
    ngx.log(ngx.DEBUG, "LUA_CPATH: ", package.cpath)

    if not app_env then
        ngx.log(ngx.DEBUG, "APP_ENV is not set!")
    else
        ngx.log(ngx.INFO, "APP_ENV: ", app_env)

        config_file = "config-" .. app_env .. ".yaml"
    end

    ngx.log(ngx.INFO, "Config file: ", config_file)

    local root_path = ngx.config.prefix()
    local file, err = io.open(root_path .. "/" .. config_file, "r")

    if not file then

        ngx.log(ngx.ERR, "Not found the configuration!")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)

    else

        local content = file:read("*all")
        file:close()

        local config = yaml.load(content)

        config_dict:set("mongodb_host", config["mongodb"]["host"])
        config_dict:set("mongodb_port", config["mongodb"]["port"])
        config_dict:set("mongodb_db", config["mongodb"]["db"])
        config_dict:set("mongodb_username", config["mongodb"]["username"])
        config_dict:set("mongodb_password", config["mongodb"]["password"])

        config_dict:set("config_loaded", true)

        ngx.log(ngx.INFO, "Loaded Config!")

    end
end


return config