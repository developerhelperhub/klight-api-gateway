local redis_client = require "resty.redis"
local cjson = require "cjson"
local bcrypt = require "bcrypt"

local exception = require("util.exception")

local redis = {}

ngx.ctx.redis = nil

local config_dict = ngx.shared.config_dict
local config = {}


local function validation_error(details)
    exception.error(ngx.HTTP_INTERNAL_SERVER_ERROR, "Redis validation", details)
end

local function connection_error(details)
    exception.error(ngx.HTTP_INTERNAL_SERVER_ERROR, "Redis connect failed", details)
end

local function validate_config() 
    config.host = config_dict:get("redis_host")
    config.port = config_dict:get("redis_port")
    config.connection_timeout = config_dict:get("redis_connection_timeout")
    config.pool_idle_timeout = config_dict:get("redis_pool_idle_timeout")
    config.pool_size = config_dict:get("redis_pool_size")

    if not config.host then
        validation_error("redis host not configured")
    end

    if not config.port then
        validation_error("redis port not configured")
    end

    if not config.connection_timeout then
        validation_error("redis connection_timeout not configured")
    end

    if not config.pool_idle_timeout then
        validation_error("redis pool_idle_timeout not configured")
    end

    if not config.pool_size then
        validation_error("redis pool_size not configured")
    end

    ngx.log(ngx.DEBUG, "redis host:", config.host)
    ngx.log(ngx.DEBUG, "redis port:", config.port)
    ngx.log(ngx.DEBUG, "redis connection_timeout:", config.connection_timeout)
    ngx.log(ngx.DEBUG, "redis pool_idle_timeout:", config.pool_idle_timeout)
    ngx.log(ngx.DEBUG, "redis pool_size:", config.pool_size)

end

function redis.new_connection() 

    validate_config()
    
    local rds = redis_client:new()
    rds:set_timeout(config.connection_timeout) -- second timeout

    local ok, err = rds:connect(config.host, config.port)

    if not ok then
        connection_error("failed to connect to Redis: " .. err)
    end

    ngx.ctx.redis = rds

    ngx.log(ngx.INFO, "Redis new connection created!")
end


function redis.set(key, value, ttl)

    if not ngx.ctx.redis then
        connection_error("Redis not connected!")
    end

    ngx.log(ngx.DEBUG, "redis set value key : ", key)

    local ok, err = ngx.ctx.redis:setex(key, ttl, value)

    if not ok then
        connection_error("Failed to store session in Redis: " .. err)
    end

end

function redis.get(key)

    if not ngx.ctx.redis then
        connection_error("Redis not connected!")
    end

    ngx.log(ngx.DEBUG, "redis get value key : ", key)

    local res, err = ngx.ctx.redis:get(key)

    if res == ngx.null then
        res = nil
    end

    return res
end

function redis.del(key)

    if not ngx.ctx.redis then
        connection_error("Redis not connected!")
    end

    ngx.log(ngx.DEBUG, "redis del value key : ", key)

    local res, err = ngx.ctx.redis:del(key)

    return 
end

function redis.release_connection()

    if not ngx.ctx.redis then
        connection_error("Redis not connected!")
    end

    local ok, err = ngx.ctx.redis:set_keepalive(config.pool_idle_timeout, config.pool_size)
    
    if not ok then
        connection_error("Redis failed to set keepalive:" .. err)
    end

    ngx.log(ngx.INFO, "Redis connection released!")

end

return redis