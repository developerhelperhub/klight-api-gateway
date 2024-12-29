local log = {}

function log.logout(user, session) 

    ngx.log(ngx.INFO, "Logout ....")
    ngx.log(ngx.INFO, "Logout user sub: ", user.sub)

    local opts = {
        discovery = connect_config.discovery_url,
        client_id = connect_config.client_id,
        client_secret = connect_config.client_secret,
        token_signing_alg_values_supported = connect_config.token_signing_alg_values_supported,
        ssl_verify = connect_config.ssl_verify,
        proxy_opts = connect_config.proxy_opts,
        logout_path = "/logout",
    }

    -- openidc.set_logging(nil, { DEBUG = ngx.INFO })

    local res, err = openidc.authenticate(opts, nil, "deny", session)

    if not err then
        ngx.header["Set-Cookie"] = "session_id=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT"
    
        -- redis_del(user.sub, CACHE_KEY_ACCESS_TOKEN)
        -- redis_del(user.sub, CACHE_KEY_ACCESS_EXPIRE)
        -- redis_del(user.sub, CACHE_KEY_REFRESH_TOKEN)

        ngx.log(ngx.INFO, "Cleaned cookies!")
    end

    user.res = res
    user.err = err

    return user

end

return log