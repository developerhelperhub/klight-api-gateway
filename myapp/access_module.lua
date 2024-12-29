local openid = require("openid.connect")
local reverse_proxy = require("core.reverse_proxy")
local global_handler = require("core.global_handler")
local redis = require("core.redis")
local exception = require("util.exception")

local access_module = {}

local function pre_call() 

    redis.new_connection()

end

local function post_call() 

    redis.release_connection()

end

local function global_error_handler(error_message) 

    ngx.log(ngx.ERR, debug.traceback())

    return error_message
end

local function main(name, call_function)

    ngx.log(ngx.DEBUG, "Init `" .. name .."` configuration ********************** ")
   
    pre_call() 

    local ok, err = xpcall(call_function, global_error_handler)
    
    if not ok then
        exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "Failed access module", err)
    end

    post_call()

    ngx.log(ngx.DEBUG, "End `" .. name .."` configuration!!!")

end

function access_module.execute(name, call_function) 

    global_handler.execute(name, function() 
        return main(name, call_function) 
    end)
end

return access_module