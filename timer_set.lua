local Object = require('dtech.vendor.classic')

---@class TimerSet
local TimerSet = Object:extend()

function TimerSet:new()
    self.timerId = 0
    self.timers = {}
end

---@param duration number
---@param fn fun(dt: integer)
---@return number Timer ID
function TimerSet:addTimer(duration, fn)
    local t = { duration = duration, id = self.timerId, current = 0, fn = fn }
    self.timers[self.timerId] = t
    self.timerId = self.timerId + 1
    return t.id
end

---@param timerId number Timer ID
function TimerSet:removeTimer(timerId)
    self.timers[timerId] = nil
end

---@param timerId number Timer ID
function TimerSet:finishTimerImmediately(timerId)
    local timer = self.timers[timerId]
    if timer then
        timer.fn(1)
        self:removeTimer(timerId)
    end
end

---@param dt number
function TimerSet:update(dt)
    for id, timer in pairs(self.timers) do
        timer.current = timer.current + dt
        if timer.current > timer.duration then
            timer.fn()
            self:removeTimer(id)
        end
    end
end

return TimerSet
