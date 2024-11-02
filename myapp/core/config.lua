local yaml = require("lyaml")
local config = {}

function config.load()

    local app_env = os.getenv("APP_ENV")
    local config_file = "config.yaml"
    local config_dict = ngx.shared.config_dict

    config_dict:set("loaded", false)

    ngx.log(ngx.INFO, "Loading Config YAML...")

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

        config_dict:set("loaded", true)

        ngx.log(ngx.INFO, "Loaded Config!")

    end
end


return config