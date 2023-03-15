local event = {}

function event.pull(event, time)
    if time == nil then
        time = math.huge
    end
    local signal
    repeat
        signal = table.pack(computer.pullSignal(time))
    until (event == nil) or (signal[1] == event) or (signal[1] == nil)
    return table.unpack(signal)
end

function event.push(...)
    computer.pushSignal(...)
end

return event