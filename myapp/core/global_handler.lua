local exception = require("util.exception")
local cjson = require "cjson"

local global_handler =  {}

local function global_error_handler(error_message) 

    local err = exception.convert_message(error_message)
    
    if error_message:find("exit:") and error_message:find("code:") and error_message:find("message:") then
        ngx.log(ngx.ERR, "Handled error exit: ", err.exit, ", code: ", err.code, ", message: ", err.message, ", details: ", err.details)
    else
        ngx.log(ngx.ERR, "Unhandled error: ", error_message)

        err = {
            exit = 1,
            message = "Unhandled error",
            details = error_message
        }
    end

    ngx.log(ngx.ERR, debug.traceback())

    return err

end

function global_handler.execute(name, call_function) 

    local ok, err = xpcall(call_function, global_error_handler)

    if not ok then
        ngx.log(ngx.ERR, "Failed executed method :", name, ", exit: ", err.exit)
        
        if tonumber(err.exit) == 1 then
            ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
        else

            ngx.header.content_type = "application/json"

            local out_response = {
                message = err.message,
                details = err.details
            }

            ngx.status = tonumber(err.code)
            ngx.say(cjson.encode(out_response))
            ngx.exit(ngx.status)

        end 
        
    else
        ngx.log(ngx.ERR, "Successfully executed method :", name)
    end
end

return global_handler