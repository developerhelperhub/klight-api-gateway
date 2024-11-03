-- local posix = require "posix"

-- local cleanup = {}

-- local function call_back(signal)
--     ngx.log(ngx.INFO, "Cleanup started due to signal: " .. signal)
    
--     -- Perform cleanup tasks here
--     -- Example: Close database connections, release resources, etc.

--     ngx.log(ngx.INFO, "Cleanup finished.")
-- end

-- function cleanup.execute() 
    
--     -- Function to handle signal registration
--     local function register_signal(signal, handler)
--         local success, err = posix.signal(signal, handler)
--         if not success then
--             ngx.log(ngx.ERR, "Failed to register signal " .. signal .. ": " .. err)
--         else
--             ngx.log(ngx.INFO, "Successfully registered signal handler for " .. signal)
--         end
--     end

--     -- Handle SIGINT (Ctrl+C)
--     register_signal(posix.SIGINT, function()
--         call_back("SIGINT")
--         os.exit(0)  -- Exit after cleanup
--     end)

--     -- Handle SIGTERM (termination request)
--     register_signal(posix.SIGTERM, function()
--         call_back("SIGTERM")
--         os.exit(0)  -- Exit after cleanup
--     end)

--     -- Optionally handle SIGQUIT (quit request)
--     register_signal(posix.SIGQUIT, function()
--         call_back("SIGQUIT")
--         os.exit(0)  -- Exit after cleanup
--     end)

--     call_back("TEST")

--     ngx.log(ngx.INFO, "Initialized cleanup!")
-- end

-- return cleanup