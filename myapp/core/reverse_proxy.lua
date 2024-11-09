-- File: core/reverse_proxy.lua
local http = require "resty.http"  -- OpenResty's HTTP client library
local cjson = require "cjson"
local repo_service = require("repository.service")
local service = require("repository.service")
local exception = require("util.exception")

local reverse_proxy = {}

local ERR_MESS_SERVICE_NOT_FOUND = "Service not found"

local function find_service(path)
    
    local item = service.find(path)

    if item then
        
        service.print_item(item)

        return item
    else
        exception.exception(ngx.HTTP_NOT_FOUND, ERR_MESS_SERVICE_NOT_FOUND, "No match upstream.")
    end

end

local function find_path(uri) 

    local first_pos = string.find(uri, "/")
    local second_pos = string.find(uri, "/", first_pos + 1)
    local len = string.len(uri)

    if not second_pos then
        return nil
    end

    local out = {}
    out.path = string.sub(uri, 1, second_pos - 1)
    out.uri = string.sub(uri, second_pos, len)

    ngx.log(ngx.DEBUG, "find_path - Second poistion of '/' character: ", second_pos, " len: ", len)
    ngx.log(ngx.DEBUG, "find_path - find path: ", out.path)
    ngx.log(ngx.DEBUG, "find_path - find uri: ", out.uri)
    
    return out
end

-- A function to return a greeting message
function reverse_proxy.route()

    local uri = ngx.var.uri
    
    ngx.log(ngx.DEBUG, "request uri : ", uri)

    -- service.print_items() 

    local fpath = find_path(uri)
    local item = find_service(fpath.path)
    local rewrite_uri = ngx.re.sub(fpath.uri, "^/(.*)", "/$1", "o")
    local upstream_url = item.protocol .. "://".. item.host .. rewrite_uri
    
    -- local upstream_url = "http://localhost:8081/items"
    local httpc = http.new()

    ngx.log(ngx.DEBUG, "rewrite uri : ", rewrite_uri)
    ngx.log(ngx.DEBUG, "request uri : ", uri)
    ngx.log(ngx.DEBUG, "upstream_url : ", upstream_url)

    local res, err = httpc:request_uri(upstream_url, {
        method = ngx.req.get_method(),
        body = ngx.req.get_body_data(),
        headers = ngx.req.get_headers()
    })

    ngx.header.content_type = "application/json"

    if not res then
        
        ngx.log(ngx.ERR, "Upstream error : ", err)

        exception.exception(ngx.HTTP_NOT_FOUND, "Upstream failed", err)

        return ngx.HTTP_NOT_FOUND
    end

    for k, v in pairs(res.headers) do
        ngx.header[k] = v
    end

    
    ngx.say(res.body)
    ngx.exit(res.status)
end

-- Return the module table
return reverse_proxy