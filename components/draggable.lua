local Object = require('dtech.vendor.classic')

local Draggable = Object:extend()

function Draggable:new(bounds)
    -- Configurable via constructor
    self.bounds      = bounds

    -- Configurable via setters
    self.canDragFn   = nil
    self.onDragStart = nil
    self.onDrag      = nil
    self.onDragEnd   = nil

    self:reset()
end

function Draggable:reset()
    self.dragStarted = false
    self.offsetX     = 0
    self.offsetY     = 0
end

return Draggable
