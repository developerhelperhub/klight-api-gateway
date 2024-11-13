local config_default = require("core.config.config_default")
local config_security = require("core.config.config_security")

config = {}

function config.is_load()
    local is_load = config_default.is_load()

    ngx.log(ngx.INFO, "Is Loaded Config, ", is_load)

    return is_load
end

function config.load() 

    local app_env = os.getenv("APP_ENV")

    config_default.load(app_env)
    config_security.load(app_env)

    ngx.log(ngx.INFO, "Loaded Config!")

end

return config