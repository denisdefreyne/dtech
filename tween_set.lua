local Object = require('dtech.vendor.classic')

---@class TweenSet
local TweenSet = Object:extend()

function TweenSet:new()
    self.tweenId = 0
    self.tweens = {}
end

---@param duration number
---@param fn fun(dt: integer)
---@param loop boolean
---@return number Tween ID
function TweenSet:addTween(duration, fn, loop)
    local t = { duration = duration, id = self.tweenId, current = 0, fn = fn, loop = loop }
    self.tweens[self.tweenId] = t
    self.tweenId = self.tweenId + 1
    return t.id
end

---@param tweenId number
function TweenSet:removeTween(tweenId)
    self.tweens[tweenId] = nil
end

---@param tweenId number
function TweenSet:finishTweenImmediately(tweenId)
    local tween = self.tweens[tweenId]
    if tween then
        tween.fn(1)
        self:removeTween(tweenId)
    end
end

---@param dt number
function TweenSet:update(dt)
    for id, tween in pairs(self.tweens) do
        -- Update current (elapsed) duration
        tween.current = tween.current + dt

        -- Loop (if desired)
        if tween.current > tween.duration and tween.loop then
            tween.current = tween.current - tween.duration
        end

        local fraction = tween.current / tween.duration
        if fraction < 1 then
            tween.fn(fraction)
        else
            tween.fn(1)
            self:removeTween(id)
        end
    end
end

return TweenSet
