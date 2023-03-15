local pkg = {}
pkg.loaded = {}
pkg.path = "/lib"
pkg.fs = nil

function pkg.init(fs)
    pkg.fs = fs
end

function pkg.require(lib)
    if pkg.loaded[lib] ~= nil then
        return pkg.loaded[lib]
    else
        if pkg.fs ~= nil then
            local handle = pkg.fs.open(pkg.path.."/"..lib..".lua", "r")
            local fi = ""
            repeat
                local data = pkg.fs.read(handle, math.huge)
                fi = fi .. (data or "")
            until not data
            pkg.fs.close(handle)
            
            local program = load(fi)
            if program then
                local result = table.pack(xpcall(program, function(msg)
                    print("ERROR: "..debug.traceback(msg))
                end))
                if result[1] then
                    pkg.loaded[lib] = table.unpack(result, 2, result.n)
                    return table.unpack(result, 2, result.n)
                else
                    error(debug.traceback(result[2]))
                end
            else
                error(reason)
            end
        end
    end
end

return pkg