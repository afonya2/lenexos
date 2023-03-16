local io = require("io")
local ser = require("serialization")
local os = require("os")
local fs = component.filesystem
local bash = {}
bash.dir = "/"

local w, h = component.gpu.maxResolution()
component.gpu.fill(1, 1, w, h, " ")
print_x = 1
print_y = 1

print(_OSVERSION.." ".._PCNAME.." bash")
print("")
local fih = fs.open("/usr/users.dat", "r")
local fid = ""
repeat
  local data = fs.read(fih, math.huge)
  fid = fid .. (data or "")
until not data
fs.close(fih)
local users = ser.unserialize(fid)

function bash.resolveDirectory(dir)
    if dir == "/home/".._USERNAME then
        dir = "~"
    end
    return dir
end

function bash.runFile(path,args)
    if args == nil then
        args = {}
    end
    local handle = fs.open(path, "r")
    local fi = ""
    repeat
        local data = fs.read(handle, math.huge)
        fi = fi .. (data or "")
    until not data
    fs.close(handle)
    
    local program = load("local args="..ser.serialize(args).."\n"..fi)
    if program then
        local result = table.pack(xpcall(program, function(msg)
            print("ERROR: "..debug.traceback(msg))
        end))
        if result[1] then
            return table.unpack(result, 2, result.n)
        end
    else
        error(reason)
    end
end

function bash.run(program, args)
    if program ~= nil then
        program = tostring(program)
        if string.sub(program, 1, 1) == "/" then
            if fs.exists("/"..string.sub(program, 2, #program)) then
                bash.runFile("/"..string.sub(program, 2, #program), args)
                return
            end
        else
            if string.sub(program, 1, 2) == "./" then
                if fs.exists(bash.dir.."/"..string.sub(program, 3, #program)) then
                    bash.runFile(bash.dir.."/"..string.sub(program, 3, #program), args)
                    return
                end
            else
                if fs.exists("/bin/"..program..".lua") then
                    bash.runFile("/bin/"..program..".lua", args)
                    return
                end
            end
        end
    end
    print("File not found!")
end

local function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

local function shell()
    while true do
        io.write(_USERNAME.."@".._PCNAME..":"..bash.resolveDirectory(bash.dir).."$")
        local cmd = io.read()
        local spi = mysplit(cmd, " ")
        bash.run(spi[1], spi)
        os.sleep(0)
    end
end

local function loginTry()
    io.write(_PCNAME.." login: ")
    local username = io.read()
    io.write(username.."'s password: ")
    local pass = io.read(true, "*")
    if users[username] == nil then
        print("Incorrect credentials")
        loginTry()
        return
    end
    if users[username].password ~= pass then
        print("Incorrect credentials")
        loginTry()
        return
    end
    _G._USERNAME = username
    shell()
end

loginTry()
