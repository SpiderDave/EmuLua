local cv2 = {}

function cv2:init(data)
    self.data = data
end


-- warp player to location
function cv2.warp(w)
    if not w then return end
    
    if w.facing then
        objects.player.facing = w.facing
        memory.writebyte(0x0420, objects.player.facing)
    end
    
    memory.writebyte(0x0030, w.area1)
    memory.writebyte(0x0050, w.area2)
    memory.writebyte(0x0051, w.area3)
    memory.writebyte(0x008f, w.areaFlags)
    memory.writebyte(0x004e, w.returnArea)
    memory.writebyte(0x0458, w.returnScroll1)
    memory.writebyte(0x046a, w.returnScroll2)
    memory.writebyte(0x4a0, w.returnX)
    memory.writebyte(0x4b2, w.returnY)
    
    memory.writebyte(0x0348, w.playerX)
    memory.writebyte(0x0324, w.playerY)
    
    setScroll(w.scrollX, w.scrollY)
    cv2.reloadScreen()
    cv2.unPause()
end

-- set scroll values
function cv2.setScroll(x,y)
    if x then
        memory.writebyte(0x0053, x % 0x100)
        memory.writebyte(0x0054, (x-(x % 0x100))/0x100)
    end
    if y then
        memory.writebyte(0x0056, y % 0xe0)
        memory.writebyte(0x0057, (y-(y % 0xe0))/0xe0)
    end
end

-- get scroll values
function cv2.getScroll()
    local x = memory.readbyte(0x0053) + memory.readbyte(0x0054)*0x100
    local y = memory.readbyte(0x0056) + memory.readbyte(0x0057)*0xe0
    --spidey.message("scroll %02x %02x",x, y)
    return x,y
end

-- reload screen
function cv2.reloadScreen()
    -- Note: still need to reset jump velocity, whip action, etc
    
    memory.writebyte(0x2c, 1)
end

function cv2.action()
    local action
    
    local a1 = memory.readbyte(0x001c)
    local a2 = memory.readbyte(0x001a)
    local a3 = memory.readbyte(0x002c)
    
    action = (a1 == 0x01 or (a1 == 02 and a2 == 0x01) or (a1 == 0x04 and a2 == 0x01))
    
    -- between screens
    if (a3 == 0x08) or (a3 == 0x0a) or (a3 == 0x02) then
        action = false
--        emu.frameadvance()
--        emu.frameadvance()
--        emu.frameadvance()
--        emu.frameadvance()
--        emu.frameadvance()
--        emu.frameadvance()
    end
    
    -- game still starting up
    if emu.framecount() <= 0x10 then
        action = false
    end
    
    return action
end

function cv2.unPause()
    memory.writebyte(0x0026,0)
end

function cv2.paused()
    return memory.readbyte(0x0026) == 0x02
end

function cv2.pause(n)
    memory.writebyte(0x0026, n or 2)
end

function cv2.pauseMenu()
    return memory.readbyte(0x0026) == 0x01
end

--function cv2.betweenScreens()
--    local b = memory.readbyte(0x002c)
--    if (b == 8) or (b == 0x0a) or (b == 0x02) then return true end
--end



function cv2:getAreaName(a1, a2, a3, a4)
    local locations = self.data.locations
    
    a1 = a1 or memory.readbyte(0x0030)
    a2 = a2 or memory.readbyte(0x0050)
    a3 = a3 or memory.readbyte(0x0051)
    a4 = a4 or memory.readbyte(0x004e)
    
    a3 = a3 % 0x80 --adds 0x80 if starting on right side
    
    local displayName = string.format('%s %s %s',a1, a2, a3)
    local name = ""
    local town
    
    if locations[a1] and locations[a1][a2] and locations[a1][a2][a3] then
        name = locations[a1][a2][a3]
        displayName = string.gsub(name, '%s%(Pt[1234]%)','')
    end
    
    if (displayName == "Church") or (name == "(room)") then
        town = self.data.towns[a4+1].name
    end
    
    if town then
        displayName = town .. " " .. displayName
    end
    
    return displayName, name, town
end



return cv2