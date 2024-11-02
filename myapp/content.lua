local reverse_proxy = require("core.reverse_proxy")

local greeting = reverse_proxy.init()

ngx.say(greeting)

ngx.log(ngx.INFO, "Loaded content!!!")