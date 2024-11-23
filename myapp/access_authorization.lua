local openid = require("openid.connect")
local reverse_proxy = require("core.reverse_proxy")
local global_handler = require("core.global_handler")
local redis = require("core.redis")

local function pre_call() 

    redis.new_connection()

end

local function post_call() 

    redis.release_connection()

end

local function main()

    ngx.log(ngx.DEBUG, "Init `access_authorization` configuration ********************** ")
   
    pre_call() 

    openid.authenticate()

    ngx.log(ngx.INFO, "Route requesting --------------")

    reverse_proxy.route()

    ngx.log(ngx.INFO, "Routed request!!!")

    post_call()

    ngx.log(ngx.DEBUG, "End `access_authorization` configuration!!!")

end

global_handler.execute("access_authorization", main)