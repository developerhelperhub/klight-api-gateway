local config = require("core.config")
local mongo = require("core.mongo")

local config_dict = ngx.shared.config_dict

ngx.log(ngx.INFO, "Intializing configuration!!!")

ngx.log(ngx.DEBUG, "Check configuration :", config.is_load())

if config.is_load() == nil then

    config.load()

end 

if mongo.is_pool_loaded() == false then
    
    mongo.create_pool()

end

ngx.log(ngx.INFO, "Intialized configuration!!!")