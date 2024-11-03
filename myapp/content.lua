local reverse_proxy = require("core.reverse_proxy")

ngx.log(ngx.INFO, "Route requesting --------------")

reverse_proxy.route()

ngx.say("Klight API Gateway")

ngx.log(ngx.INFO, "Routed request!!!")