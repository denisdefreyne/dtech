local Object = require('dtech.vendor.classic')

local RelativeOffset = Object:extend()

-- Sets ox/oy based on a fraction and the size of the node.

function RelativeOffset:new(size, fox, foy)
    self.size = size
    self.fox  = fox
    self.foy  = foy
end

return RelativeOffset
