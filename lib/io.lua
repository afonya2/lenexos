local io = {}
local keyboard = require("keyboard")
local event = require("event")
local os = require("os")

function io.write(msg)
    component.gpu.set(print_x,print_y,msg)
    print_x = print_x + #msg
end

function io.read(hidden, hchar)
    local typo = ""
    local y = print_y
    local x = print_x
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
                component.gpu.set(x,y,spaces)
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
                if hidden == true then
                    local strang = ""
                    for i=1,#typo,1 do
                        strang = strang..hchar
                    end
                    component.gpu.set(x,y,strang)
                else
                    component.gpu.set(x,y,typo)
                end
            end
            --render()
            coroutine.yield()
        end
    end
    local function c()
        while true do
            local locs = x+#typo
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
    print_x = 1
    print_y = print_y + 1
    
    return typo
end

return io