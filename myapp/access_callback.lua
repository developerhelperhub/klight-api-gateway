local access_module = require("access_module")
local openid = require("openid.authorisation_code")

local function main()

    openid.redirect_authenticate()

end

access_module.execute("access_callback", main)