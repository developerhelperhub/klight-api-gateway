local rsession = require "resty.session"
local exception = require("util.exception")

local session = {}

local config_dict = ngx.shared.config_dict
local config  = {}

local function validation_error(details)
    exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "Redis validation", details)
end

local function validate() 
    config.redis_host = config_dict:get("redis_host")
    config.redis_port = config_dict:get("redis_port")
    config.session_secure = config_dict:get("session_secure")
    config.session_httponly = config_dict:get("session_httponly")
    
    ngx.log(ngx.DEBUG, "session_secure: ", config.session_secure)

    if not config.redis_host then
        validation_error("redis host not configured")
    end

    if not config.redis_port then
        validation_error("redis port not configured")
    end

    if config.session_secure == nil then
        validation_error("session secure not configured")
    end

    if config.session_httponly == nil then
        validation_error("session httponly not configured")
    end

    ngx.log(ngx.DEBUG, "redis_host: ", config.redis_host)
    ngx.log(ngx.DEBUG, "redis_port: ", config.redis_port)
    ngx.log(ngx.DEBUG, "session_secure: ", config.session_secure)
    ngx.log(ngx.DEBUG, "session_httponly: ", config.session_httponly)
end

function session.start(prefix, lifetime)

    validate()

    local sess = rsession.start{
        storage = "redis",
        redis = {
            host = config.redis_host,  -- Redis server
            port = config.redis_port,        -- Redis port
            prefix = prefix .. ":",   -- Prefix for session keys
        },
        cookie = {
            lifetime = lifetime,    -- Cookie lifetime in seconds
            secure = config.session_secure,     -- Set to true for HTTPS
            httponly = config.session_httponly,    -- Restrict access to HTTP only
        }
    }

    return sess

end

return session