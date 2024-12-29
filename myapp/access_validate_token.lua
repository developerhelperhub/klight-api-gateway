local access_module = require("access_module")
local openid = require("openid.connect")
local reverse_proxy = require("core.reverse_proxy")

local function main()

    openid.validate_token()

    reverse_proxy.route()

end

access_module.execute("access_validate_token", main)