local yaml = require("lyaml")

local config = {}

local config_dict = ngx.shared.config_dict

function config.is_load()
    return config_dict:get("config_loaded")
end

local function mongodb_config(config)

    config_dict:set("mongodb_host", config["mongodb"]["host"])
    config_dict:set("mongodb_port", config["mongodb"]["port"])
    config_dict:set("mongodb_db", config["mongodb"]["db"])
    config_dict:set("mongodb_username", config["mongodb"]["username"])
    config_dict:set("mongodb_password", config["mongodb"]["password"])
    config_dict:set("mongodb_connection_pool_size", config["mongodb"]["connection-pool-size"])

    ngx.log(ngx.INFO, "Loaded Mongo Config!")

end 

local function openid_config(config)

    config_dict:set("openid_discovery_url", config["openid"]["discovery_url"])
    config_dict:set("openid_validate_scope", config["openid"]["validate_scope"])
    config_dict:set("openid_client_id", config["openid"]["client_id"])
    config_dict:set("openid_client_secret", config["openid"]["client_secret"])
    config_dict:set("openid_flow_type", config["openid"]["flow_type"])
    config_dict:set("openid_introspection_endpoint", config["openid"]["introspection_endpoint"])

    ngx.log(ngx.INFO, "Loaded OpenId Config!")
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

        mongodb_config(config)

        openid_config(config)
        
        config_dict:set("config_loaded", true)

        ngx.log(ngx.INFO, "Loaded Config!")

    end
end


return config