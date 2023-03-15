local pkg = {}
pkg.loaded = {}
pkg.path = "/lib/"
pkg.fs = nil

function pkg.init(fs)
    pkg.fs = fs
end

function pkg.Rrequire(path)
    if pkg.fs ~= nil then
        local handle = pkg.fs.open(path, "r")
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
                return table.unpack(result, 2, result.n)
            else
                error(debug.traceback(result[2]))
            end
        else
            error(reason)
        end
    end
end

function pkg.require(file)
    if pkg.loaded[file] ~= nil then
        return table.unpack(pkg.loaded[file])
    else
        if pkg.fs ~= nil then
            if pkg.fs.exists("/"..file) then
                local res = table.pack(pkg.Rrequire("/"..file))
                pkg.loaded[file] = res
                return table.unpack(res)
            end

            if pkg.fs.exists(pkg.path..file) then
                local res = table.pack(pkg.Rrequire(pkg.path..file))
                pkg.loaded[file] = res
                return table.unpack(res)
            end

            if pkg.fs.exists("/bin/"..file) then
                local res = table.pack(pkg.Rrequire("/bin"..file))
                pkg.loaded[file] = res
                return table.unpack(res)
            end
        end
    end
end

return pkg