local r_session = require("resty.session")
local exception = require("util.exception")

local sess = {}

local config_dict = ngx.shared.config_dict
local sess_config = {}

local function validation_error(details)
    exception.error(ngx.HTTP_INTERNAL_SERVER_ERROR, "Session validation", details)
end


local function validate_config() 
    sess_config.redis_host = config_dict:get("redis_host")
    sess_config.redis_port = config_dict:get("redis_port")
    sess_config.redis_connection_timeout = config_dict:get("redis_connection_timeout")

    if not sess_config.host then
        validation_error("redis host not configured")
    end

    if not sess_config.port then
        validation_error("redis port not configured")
    end

    if not sess_config.connection_timeout then
        validation_error("redis connection_timeout not configured")
    end

    ngx.log(ngx.DEBUG, "redis host:", sess_config.redis_host)
    ngx.log(ngx.DEBUG, "redis port:", sess_config.redis_port)
    ngx.log(ngx.DEBUG, "redis connection_timeout:", sess_config.redis_connection_timeout)

end

function sess.start(config) 

    if r_session then
        ngx.log(ngx.DEBUG, "Session library loaded successfully!")
    else
        validation_error("Failed to load session library!")
    end

    local session, err, exists, refreshed = r_session.start({
        audience = config.client_id,
        storage = "redis",
        secret = config.session_secret,
        redis = { 
            host = sess_config.redis_host,       -- Replace with your Redis host
            port = sess_config.port,             -- Replace with your Redis port
            timeout = sess_config.redis_connection_timeout, 
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
            ngx.log(ngx.WARN, "Session error: ", err)
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
        validation_error("Failed to save session: ", err)
    else
        ngx.log(ngx.DEBUG, "Session saved successfully")
    end

end

return sess