local redis = require("core.redis")
local cjson = require "cjson"

local util = {}

util.CACHE_KEY_ACCESS_TOKEN = "access_token"
util.CACHE_KEY_ACCESS_EXPIRE = "access_token_expire"
util.CACHE_KEY_REFRESH_TOKEN = "refresh_token"

local config_dict = ngx.shared.config_dict

local function validation_error(details)
    exception.exception(ngx.HTTP_INTERNAL_SERVER_ERROR, "OpenID validation", details)
end

function util.common_validation() 
    local config  = {}

    config.discovery_url = config_dict:get("openid_discovery_url")
    config.discovery_token_endpoint = config_dict:get("openid_discovery_token_endpoint")
    config.discovery_issuer = config_dict:get("openid_discovery_issuer")
    config.discovery_authorization_endpoint = config_dict:get("openid_discovery_authorization_endpoint")
    config.discovery_jwks_uri = config_dict:get("openid_discovery_jwks_uri")
    config.discovery_userinfo_endpoint = config_dict:get("openid_discovery_userinfo_endpoint")
    config.discovery_introspection_endpoint = config_dict:get("openid_discovery_introspection_endpoint")
    config.discovery_end_session_endpoint = config_dict:get("openid_discovery_end_session_endpoint")

    config.client_id = config_dict:get("openid_client_id")
    config.client_secret = config_dict:get("openid_client_secret")
    config.ssl_verify = config_dict:get("openid_ssl_verify")
    config.token_validation_type = config_dict:get("openid_token_validation_type")
    config.session_secret = config_dict:get("openid_session_secret")

    if not config.discovery_url then
        validation_error("openid discovery_url not configured")
    end

    if not config.client_id then
        validation_error("openid client_id not configured")
    end

    if not config.client_secret then
        validation_error("openid client_secret not configured")
    end

    if not config.token_validation_type then
        validation_error("openid token_validation_type not configured")
    end

    if not config.ssl_verify then
        validation_error("openid openid_ssl_verify not configured")
    end

    if not config.session_secret then
        validation_error("openid session_secret not configured")
    end


    ngx.log(ngx.DEBUG, "discovery_url: ", config.discovery_url)
    ngx.log(ngx.DEBUG, "token_validation_type: ", config.token_validation_type)
    ngx.log(ngx.DEBUG, "client_id: ", config.client_id and "************" or "nil")
    ngx.log(ngx.DEBUG, "client_secret: ", config.client_secret and "************" or "nil")
    ngx.log(ngx.DEBUG, "session_secret: ", config.session_secret and "************" or "nil")
    ngx.log(ngx.DEBUG, "ssl_verify: ", config.ssl_verify)

    return config
end

function util.redis_set(sub, key, value, ttl)
    local redis_key = "kag_openid_session:" .. sub .. ":" .. key
    redis.set(redis_key, cjson.encode(value), ttl)
end

function util.redis_del(sub, key)
    local redis_key = "kag_openid_session:" .. sub .. ":" .. key
    redis.del(redis_key)
end

function util.redis_get(sub, key)
    local redis_key = "kag_openid_session:" .. sub .. ":" .. key
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