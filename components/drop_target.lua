local Object = require('dtech.vendor.classic')

local DropTarget = Object:extend()

function DropTarget:new(bounds)
    -- Configurable via constructor
    self.bounds = bounds

    -- Configurable via setters
    self.canDropFn = nil
end

return DropTarget
