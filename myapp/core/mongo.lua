local mongo_client = require "mongo"
local cjson = require "cjson"
local bcrypt = require "bcrypt"

local mongo = {}

math.randomseed(os.time())

-- global variable global_var_mongo_pool for storing pool, it will create each worker (CPU)
global_var_mongo_pool = nil

local config_dict = ngx.shared.config_dict
local mongodb_host = nil
local mongodb_port = nil
local mongodb_db = nil
local mongodb_username = nil
local mongodb_password = nil

local function validate_config() 
    mongodb_host = config_dict:get("mongodb_host")
    mongodb_port = config_dict:get("mongodb_port")
    mongodb_db = config_dict:get("mongodb_db")
    mongodb_username = config_dict:get("mongodb_username")
    mongodb_password = config_dict:get("mongodb_password")

    if not mongodb_host then
        ngx.log(ngx.ERR, "mongodb_host not configured")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if not mongodb_port then
        ngx.log(ngx.ERR, "mongodb_port not configured")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if not mongodb_db then
        ngx.log(ngx.ERR, "mongodb_db not configured")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if not mongodb_username then
        ngx.log(ngx.ERR, "mongodb_username not configured")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if not mongodb_password then
        ngx.log(ngx.ERR, "mongodb_password not configured")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
end

function mongo.create_pool() 

    validate_config()

    global_var_mongo_pool = {}
    
    local mongo_pool_size = 4
    local mongo_url = "mongodb://" .. mongodb_username .. ":" .. mongodb_password .. "@".. mongodb_host .. ":" .. mongodb_port
    
    ngx.log(ngx.INFO, "Mongodb url: ", "mongodb://" .. mongodb_host .. ":" .. mongodb_port)
    ngx.log(ngx.DEBUG, "Mongodb username: ", mongodb_username and "*********" or "nil")
    ngx.log(ngx.DEBUG, "Mongodb password: ", mongodb_password and "*********" or "nil")

    -- Create connections and store them in the pool
    for i = 1, mongo_pool_size do
        
        local client = mongo_client.Client(mongo_url)  -- Adjust the URI as necessary
        local db = client:getDatabase(mongodb_db)  -- Replace with your database name

        table.insert(global_var_mongo_pool, db)
    end

    if not global_var_mongo_pool then
        ngx.log(ngx.ERR, "Not load pool.")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    ngx.log(ngx.INFO, "Created the mongo pool : ", mongo_pool_size)
end

function mongo.is_pool_loaded() 

    local loaded = global_var_mongo_pool and true or false
    
    ngx.log(ngx.DEBUG, "Check mongo pool loaded:", loaded)

    return loaded
end

function mongo.get_db()

    if not global_var_mongo_pool then
        ngx.log(ngx.ERR, "Not load pool.")
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    local random_index = math.random(1, #global_var_mongo_pool)

    ngx.log(ngx.DEBUG, "Mongo pool size:" .. #global_var_mongo_pool .. " random_index: " .. random_index)

    return global_var_mongo_pool[random_index]
end

return mongo