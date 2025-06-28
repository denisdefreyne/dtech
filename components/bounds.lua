local Object = require('dtech.vendor.classic')

local Bounds = Object:extend()

function Bounds:new(transform, size)
    self.transform = transform
    self.size      = size
end

function Bounds:containsScreen(x, y)
    local loveTransform = self.transform:getInverseGlobalLoveTransform()
    local lx, ly = loveTransform:transformPoint(x, y)

    return lx > 0 and lx < self.size:width() and ly > 0 and ly < self.size:height()
end

function Bounds:__tostring()
    return "Bounds(transform=" .. tostring(self.transform) .. ", size=" .. tostring(self.size) .. ")"
end

return Bounds
