local timer={timers={}} --This is the one that holds everything
local Timer={}

local inf = 1/0

timer.debug=false

-- Constructor
function Timer:new(...)
    local arg={...}
    local object = {
        t=arg[1] or 100,
        action={done=arg[2]},
        startTime = os.clock(),
        rep = false,
        done=false,
    }
    object.startValue = object.t
    setmetatable(object, { __index = Timer})
    return object
end

function Timer:update()
    if self.done then return end
    if os.clock()-self.startTime >= self.t then
        if self.rep then
            if (type(self.rep)=="number" and self.rep > 0) then
                self.doAction=true
                self.startTime = os.clock()
                self.rep=self.rep-1
                if self.rep==0 then self.done=true end
            elseif self.rep==true then
                self.doAction=true
                self.startTime = os.clock()
            end
        else
            -- Don't repeat
            self.doAction=true
            self.done=true
        end
    end
end

function timer.add(...)
    timer.timers[#timer.timers+1]=Timer:new(...)
    return timer.timers[#timer.timers]
end

function timer.update()
    for i=#timer.timers,1,-1 do
        if timer.timers[i].doAction then
            if timer.timers[i].action.done then
                timer.timers[i].action.done()
            end
            timer.timers[i].doAction = false
        end
        if timer.timers[i].done then
            table.remove(timer.timers,i)
        else
            timer.timers[i]:update()
        end
    end
end

return timer