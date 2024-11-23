local redis = require("core.redis")
local cjson = require "cjson"

local util = {}

util.CACHE_KEY_ACCESS_TOKEN = "access_token"
util.CACHE_KEY_ACCESS_EXPIRE = "access_token_expire"
util.CACHE_KEY_REFRESH_TOKEN = "refresh_token"

function util.redis_set(sub, key, value, ttl)
    local redis_key = "openid:" .. sub .. ":" .. key
    redis.set(redis_key, cjson.encode(value), ttl)
end

function util.redis_del(sub, key)
    local redis_key = "openid:" .. sub .. ":" .. key
    redis.del(redis_key)
end

function util.redis_get(sub, key)
    local redis_key = "openid:" .. sub .. ":" .. key
    local value = redis.get(redis_key)
    return value ~= nil and cjson.decode(value) or value
end

function util.get_access_token(sub) 
    return util.redis_get(sub, util.CACHE_KEY_ACCESS_TOKEN)
end

function util.get_access_token_expiration(sub) 
    return util.redis_get(sub, util.CACHE_KEY_ACCESS_EXPIRE)
end

function util.get_refresh_token(sub) 
    return util.redis_get(sub, util.CACHE_KEY_REFRESH_TOKEN)
end

function util.redis_save_token(user, config) 

    util.redis_set(user.sub, util.CACHE_KEY_ACCESS_TOKEN, user.access_token, config.access_token_lifetime)
    util.redis_set(user.sub, util.CACHE_KEY_ACCESS_EXPIRE, user.access_token_expiration, config.access_token_lifetime)
    util.redis_set(user.sub, util.CACHE_KEY_REFRESH_TOKEN, user.refresh_token, config.refresh_token_lifetime)

    ngx.log(ngx.DEBUG, "Saved token info into redis")
end


return util