local io = require("io")

component.gpu.fill(1, 1, w, h, " ")
print_x = 1
print_y = 1

print(_OSVERSION.." ".._PCNAME.." bash")
print("")
io.write(_PCNAME.." login: ")
local username = io.read()
io.write(username.."'s password: ")
local pass = io.read(true, "*")