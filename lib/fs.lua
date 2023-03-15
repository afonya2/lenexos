local fs = {}

function fs.getFs(addr)
    local out = {}
    local l = addr or component.list("filesystem")()
    local rfs = component.proxy(l)
    for k,v in pairs(rfs) do
        out[k] = v
    end
    return out
end

return fs