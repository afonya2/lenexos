local io = require("io")
local ser = require("serialization")
local fs = require("fs")
local os = require("os")
fs = fs.getFs(computer.getBootAddress())
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

local function shell()
    while true do
        io.write(_USERNAME.."@".._PCNAME..":"..bash.resolveDirectory(bash.dir).."$")
        local cmd = io.read()
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
