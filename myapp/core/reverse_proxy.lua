-- File: core/reverse_proxy.lua
local repo_service = require("repository.service")

local reverse_proxy = {}

-- A function to return a greeting message
function reverse_proxy.init()

    repo_service.list()

    return "Hello, Klight API Gateay!"
end

-- Return the module table
return reverse_proxy