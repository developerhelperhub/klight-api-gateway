local config = require("core.config")

local config_dict = ngx.shared.config_dict

ngx.log(ngx.INFO, "Intializing configuration!!!")

ngx.log(ngx.DEBUG, "Check configuration :", config_dict:get("loaded"))

if config_dict:get("loaded") == nil then

    config.load()

end 

ngx.log(ngx.INFO, "Intialized configuration!!!")