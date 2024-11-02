-- File: core/reverse_proxy.lua
local reverse_proxy = {}

-- A function to return a greeting message
function reverse_proxy.init()

    local config_dict = ngx.shared.config_dict

    ngx.log(ngx.DEBUG, "Mongodb host: ", config_dict:get("mongodb_host"))
    
    return "Hello, Klight API Gateay!"
end

-- Return the module table
return reverse_proxy