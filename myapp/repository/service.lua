local mongo = require("core.mongo")

local service = {}
local collection_name ="services"

function service.list() 
    local db = mongo.get_db()
    local collection = db:getCollection(collection_name)
    
    local cursor, err = collection:find{}
    if not cursor then
        ngx.log(ngx.ERR, collection_name .. " not find document: ", err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    for item in collection:find({}, {}):iterator() do
        print(tostring(item._id) .. "----" .. item.name)
    end
end

return service