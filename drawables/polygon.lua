local Object = require('dtech.vendor.classic')

local Polygon = Object:extend()

function Polygon:new(vertices)
    self.vertices = vertices
end

function Polygon:draw()
    love.graphics.polygon("fill", self.vertices)
end

return Polygon
