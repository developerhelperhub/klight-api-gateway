local r_session = require("resty.session")
local exception = require("util.exception")
local cjson = require "cjson"

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
    sess_config.redis_pool_size = config_dict:get("redis_pool_size")
    sess_config.redis_username = config_dict:get("redis_username")
    sess_config.redis_password = config_dict:get("redis_password")

    if not sess_config.redis_host then
        validation_error("redis host not configured")
    end

    if not sess_config.redis_port then
        validation_error("redis port not configured")
    end

    if not sess_config.redis_connection_timeout then
        validation_error("redis connection_timeout not configured")
    end

    if not sess_config.redis_pool_size then
        validation_error("redis pool_size not configured")
    end

    if not sess_config.redis_username then
        validation_error("redis username not configured")
    end

    if not sess_config.redis_password then
        validation_error("redis password not configured")
    end

    ngx.log(ngx.DEBUG, "redis session config")
    ngx.log(ngx.DEBUG, "redis host:", sess_config.redis_host)
    ngx.log(ngx.DEBUG, "redis port:", sess_config.redis_port)
    ngx.log(ngx.DEBUG, "redis connection_timeout:", sess_config.redis_connection_timeout)
    ngx.log(ngx.DEBUG, "redis pool_size:", sess_config.redis_pool_size)
    ngx.log(ngx.DEBUG, "redis username: ", sess_config.redis_username and "*********" or "nil")
    ngx.log(ngx.DEBUG, "redis password: ", sess_config.redis_password and "*********" or "nil")

end

function sess.start(config) 

    if r_session then
        ngx.log(ngx.DEBUG, "Session library loaded successfully!")
    else
        validation_error("Failed to load session library!")
    end

    validate_config()

    local cookie_secure = config.ssl_verify == "yes" and true or false

    ngx.log(ngx.DEBUG, "cookie_secure :", cookie_secure)

    local sess_opts = {
        audience = config.client_id,
        storage = "redis",
        secret = config.session_secret,
        redis = { 
            host = sess_config.redis_host,
            port = sess_config.redis_port,
            timeout = sess_config.redis_connection_timeout,
            pool_size = sess_config.redis_pool_size,
            username = sess_config.redis_username,
            password = sess_config.redis_password
        },
        cookie_name = "kag_openid_session",  -- Name of the cookie
        cookie_secure = cookie_secure,       -- Set true for HTTPS
        cookie_http_only = true,      -- Prevent access from JavaScript
        cookie_same_site = "Lax",     -- Protect against CSRF
        cookie_path = "/"
    }

    -- ngx.log(ngx.DEBUG, "Session master opts: ", cjson.encode(sess_opts))
    
    local session, err, exists, refreshed = r_session.start(sess_opts)
    

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