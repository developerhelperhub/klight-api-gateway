
local handler =  {}

function handler.release_handler()

    ngx.log(ngx.INFO, "Resources release handler executing ...")

    require("core.redis").release_connection()

    ngx.log(ngx.INFO, "Resources release handler executed!")
end

return handler