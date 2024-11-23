local openid = require("openid.authorisation_code")
local reverse_proxy = require("core.reverse_proxy")
local global_handler = require("core.global_handler")

local function main()

    ngx.log(ngx.DEBUG, "Init access_logout configuration ********************** ")

    -- openid.logout()

    ngx.log(ngx.DEBUG, "End access_logout configuration!!!")

end

global_handler.execute("access_logout", main)