local exception = {}

local message_format = "message:%s,code:%d,details:%s,exit:%d"

function exception.convert_message(error_string) 

    local message, code, details, exit = error_string:match("message:([^,]+),code:(%d+),details:([^,]+),exit:(%d+)")

    return {message = message, code = code, details = details, exit = exit}
end 

function exception.exception(status, message, details)
    error(string.format(message_format, message, status, details, 0))
end

function exception.error(status, message, details)
    error(string.format(message_format, message, status, details, 1))
end

return exception