local Object = require('dtech.vendor.classic')

local Rectangle = Object:extend()

function Rectangle:new(size)
    self.size = size
end

function Rectangle:draw()
    love.graphics.rectangle(
        "fill",
        0, 0,                                 -- x, y
        self.size:width(), self.size:height() -- w, h
    )
end

return Rectangle
