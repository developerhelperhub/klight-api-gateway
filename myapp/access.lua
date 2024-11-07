local openid = require("openid.connect")

ngx.log(ngx.DEBUG, "Init access configuration ********************** ")

openid.authenticate()

ngx.log(ngx.DEBUG, "End access configuration!!!")