local Object = require('dtech.vendor.classic')

local Color = Object:extend()

function Color:new(r, g, b, a)
    a = a or 1

    self.r = r
    self.g = g
    self.b = b
    self.a = a
end

return Color
