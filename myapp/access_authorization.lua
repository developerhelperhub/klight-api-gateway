local openid = require("openid.connect")
local reverse_proxy = require("core.reverse_proxy")
local global_handler = require("core.global_handler")

local function main()

    ngx.log(ngx.DEBUG, "Init `access_authorization` configuration ********************** ")

    openid.authenticate()

    ngx.log(ngx.INFO, "Route requesting --------------")

    reverse_proxy.route()

    ngx.log(ngx.INFO, "Routed request!!!")

    ngx.log(ngx.DEBUG, "End `access_authorization` configuration!!!")

end

global_handler.execute("access_authorization", main)