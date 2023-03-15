local os = {}

--[[function os.sleep(timeout)
    checkArg(1, timeout, "number", "nil")
    local deadline = computer.uptime() + (timeout or 0)
    repeat
      computer.pullSignal(deadline - computer.uptime())
    until computer.uptime() >= deadline-1
end]]
os.sleep = function(s)
    if type(s) == "number" then
        local t = computer.uptime()
        while computer.uptime() - t <= s do
            coroutine.yield()
        end
    else
        error("bad argument #1 to 'os.sleep' (number expected, got " .. type(s) .. ")")
    end
end

return os