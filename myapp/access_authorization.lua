local access_module = require("access_module")
local openid = require("openid.authorisation_code")

local function main()

    openid.authenticate()

end

access_module.execute("access_authorization", main)