
local config = require("core.config")
local mongo = require("core.mongo")
local cleanup = require("core.cleanup")
local global_handler = require("core.global_handler")

local config_dict = ngx.shared.config_dict

ngx.log(ngx.DEBUG, "LUA_PATH: ", package.path)
ngx.log(ngx.DEBUG, "LUA_CPATH: ", package.cpath)

ngx.log(ngx.INFO, "Intializing configuration!!!")

local function main()

    if config.is_load() == nil then

        config.load()

    end 

    if mongo.is_pool_loaded() == false then
        
        mongo.create_pool()

    end

    -- cleanup.execute()

    ngx.log(ngx.INFO, "Intialized configuration!!!")

end

global_handler.execute("init", main)