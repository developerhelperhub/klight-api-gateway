local mongo = require("core.mongo")
local mongo_client = require "mongo"
local cjson = require "cjson"
local exception = require("util.exception")

local service = {}
local collection_name ="service"


local function create_table_item(item)

    local object = {}

    object.id = tostring(item._id)
    object.name = item.name
    object.path = item.path
    object.protocol = item.protocol
    object.host = item.host

    return object
end

function service.list() 
    local db = mongo.get_db()
    local collection = db:getCollection(collection_name)

    local success, result = pcall(function()
        return collection:find{}
    end)

    if not success then
        ngx.log(ngx.ERR, collection_name .. " not find documents: ", result)
    else
        ngx.log(ngx.DEBUG, "Found documents! success : ", success)
    end

    local items = {}

    for item in result:iterator() do
        table.insert(items, create_table_item(item))
    end

    return items
end


function service.print_item(item) 
    ngx.log(ngx.DEBUG, "service ---------- : ", item.name)
    ngx.log(ngx.DEBUG, "id : ", item.id)
    ngx.log(ngx.DEBUG, "path : ", item.path)
    ngx.log(ngx.DEBUG, "protocol : ", item.protocol)
    ngx.log(ngx.DEBUG, "host : ", item.host)
end


function service.print_items() 
    for index, item in ipairs(service.list()) do
        service.print_item(item)
    end
end


function service.find(service_path) 
    local items = {}
    local db = mongo.get_db()
    local collection = db:getCollection(collection_name)
    
    local query = { path = service_path}

    ngx.log(ngx.DEBUG, "service query : ", cjson.encode(query))

    local success, result = pcall(function()
        return collection:findOne(query):value()
    end)
    
    if not success then
        ngx.log(ngx.ERR, collection_name .. " not find document: ", result)
        return nil
    else
        ngx.log(ngx.DEBUG, "Found document! success : ", success)
    end
    
    return create_table_item(result)
end

return service