local r_session = require("resty.session")

local sess = {}

function sess.start(config) 

    if r_session then
        ngx.log(ngx.DEBUG, "Session library loaded successfully!")
    else
        validation_error("Failed to load session library!")
    end

    local session, err, exists, refreshed = r_session.start({
        audience = config.client_id,
        storage = "redis",
        secret = "jjjjOjjl*nnnPPPPP767",
        redis = { 
            host = "127.0.0.1",       -- Replace with your Redis host
            port = 6379,             -- Replace with your Redis port
            timeout = 1, 
        },
        cookie_name = "session",  -- Name of the cookie
        cookie_secure = false,       -- Set true for HTTPS
        cookie_http_only = true,      -- Prevent access from JavaScript
        cookie_same_site = "Lax",     -- Protect against CSRF
        cookie_path = "/"
    })
    

    if not session then
        validation_error("Failed to initialize session, error: " .. err)
    else
        if err then
            ngx.log(ngx.ERR, "Session error: ", err)
        else
            ngx.log(ngx.DEBUG, "Session started!")
        end 
    end

    ngx.log(ngx.DEBUG, "session exists :", exists)
    ngx.log(ngx.DEBUG, "session refreshed :", refreshed)

    return session

end

function sess.save(session) 

    local ok, err = session:save()
    if not ok then
        ngx.log(ngx.ERR, "Failed to save session: ", err)
    else
        ngx.log(ngx.DEBUG, "Session saved successfully")
    end

end

return sess