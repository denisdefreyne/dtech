local Object = require('dtech.vendor.classic')

---@class Hoverable
local Hoverable = Object:extend()

function Hoverable:new(bounds, mouseIn, mouseOut)
    self.bounds      = bounds
    self.mouseIn     = mouseIn
    self.mouseOut    = mouseOut

    self.isHovering  = false
    self.wasHovering = false
end

function Hoverable:update(dt)
    local wasHovering = self.isHovering

    local mx, my = love.mouse.getPosition()
    local isHovering = self.bounds:containsScreen(mx, my)

    self.wasHovering = wasHovering
    self.isHovering = isHovering

    if self.mouseIn and not wasHovering and isHovering then
        self.mouseIn()
    elseif self.mouseOut and wasHovering and not isHovering then
        self.mouseOut()
    end
end

return Hoverable
