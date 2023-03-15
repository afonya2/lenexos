local raw_loadfile = ...

_G._OSVERSION = "Lenex 0.1-BETA"

local component = component
local computer = computer

local w, h
local screen = component.list("screen", true)()
local gpu = screen and component.list("gpu", true)()
if gpu then
  gpu = component.proxy(gpu)
  if not gpu.getScreen() then
    gpu.bind(screen)
  end
  _G.boot_screen = gpu.getScreen()
  w, h = gpu.maxResolution()
  gpu.setResolution(w, h)
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")
end

local y = 1
function status(level, msg)
    if gpu then
        if level == "ok" then
            gpu.setForeground(0x15ed23)
            gpu.set(1,y,"[OK] "..msg)
        end
        if level == "err" then
            gpu.setForeground(0xed1515)
            gpu.set(1,y,"[ERR] "..msg)
        end
        if level == "warn" then
            gpu.setForeground(0xeda815)
            gpu.set(1,y,"[WARN] "..msg)
        end
        if y == h then
            gpu.copy(1, 2, w, h - 1, 0, -1)
            gpu.fill(1, h, w, 1, " ")
        else
            y = y + 1
        end
    end
end

status("ok", "Gpu allocated")
status("ok", "Booting ".._OSVERSION.."...")

local function dofile(file)
    status("ok", "File: "..file)
    local program, reason = raw_loadfile(file)
    if program then
      local result = table.pack(pcall(program))
      if result[1] then
        return table.unpack(result, 2, result.n)
      else
        error(debug.traceback(result[2]))
      end
    else
      error(reason)
    end
end

local fis = dofile("/lib/fs.lua")
local fs = fis.getFs(computer.getBootAddress())
status("ok", "filesystem loaded!")

status("ok", "package manager inited!")

local function rom_invoke(method, ...)
    return component.invoke(computer.getBootAddress(), method, ...)
end

local scripts = {}
for _, file in ipairs(fs.list("boot")) do
  local path = "boot/" .. file
  if not fs.isDirectory(path) then
    table.insert(scripts, path)
  end
end
table.sort(scripts)
for i = 1, #scripts do
  dofile(scripts[i])
end

status("ok", "Bootscripts ran!")

for c, t in component.list() do
    computer.pushSignal("component_added", c, t)
end

status("ok", "components inited")
computer.pushSignal("init")
