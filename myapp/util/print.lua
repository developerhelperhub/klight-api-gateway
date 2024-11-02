local print = {}

function print.filter_serializable(table)
    local result = {}
    for k, v in pairs(table) do
        if type(v) ~= "function" then  -- Exclude functions
            result[k] = v
        end
    end
    return result
end


return print