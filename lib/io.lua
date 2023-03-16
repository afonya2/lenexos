local io = {}
local keyboard = require("keyboard")
local event = require("event")
local os = require("os")

function io.read(shown, char)
    local typo = ""
    local y = print_y
    local function r()
        local function render()
            local w, h = component.gpu.maxResolution()
            component.gpu.fill(1, y, w, 1, " ")
            component.gpu.set(1,y,typo)
        end
        while true do
            local e,_,_,charcode = event.pull("key_down",0.1)
            if e ~= nil then
                local char = keyboard.getKeyById(charcode)
                
                local spaces = ""
                for i=1,#typo,1 do
                    spaces = spaces.." "
                end
                component.gpu.set(1,y,spaces)
                if char == "enter" then
                    break
                else
                    if char == "back" then
                        typo = string.sub(typo, 1, #typo-1)
                    else
                        if char == "space" then
                            typo = typo.." "
                        else
                            typo = typo..char
                        end
                    end
                end
                component.gpu.set(1,y,typo)
            end
            --render()
            coroutine.yield()
        end
    end
    local function c()
        while true do
            local locs = #typo+1
            local d = component.gpu.get(locs,y)
            local ob = component.gpu.getBackground()
            component.gpu.setBackground(0xFFFFFF)
            component.gpu.set(locs,y,d)
            component.gpu.setBackground(ob)
            os.sleep(1)
            d = component.gpu.get(locs,y)
            component.gpu.set(locs,y,d)
            os.sleep(1)
            coroutine.yield()
        end
    end

    local ca = coroutine.create(r)
    local cb = coroutine.create(c)
    while true do
        local a = coroutine.resume(ca)
        coroutine.resume(cb)
        if a == false then
            break
        end
    end
    
    return typo
end

return io