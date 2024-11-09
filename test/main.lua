

function convert_message(error_string) 

    local message, code, details = error_string:match("message:([^,]+),code:(%d+),details:([^,]+)")

    return {message = message, code = code, details = details}
end 

function info(message, details)
    return string.format("message:%s,code:%d,details:%s",message, 422, details)
end

local format_message = info("hello", "my details")
local tbl = convert_message(format_message)

print(tbl.message)
print(tbl.code)
print(tbl.details)