local Object = require('dtech.vendor.classic')

local Size = Object:extend()

function Size:new(width, height)
    self._width  = width
    self._height = height
end

function Size:width()
    return self._width
end

function Size:setWidth(width)
    self._width = width
end

function Size:height()
    return self._height
end

function Size:setHeight(height)
    self._height = height
end

function Size:__tostring()
    return "Size(width=" .. tostring(self:width()) .. ", height=" .. tostring(self:height()) .. ")"
end

return Size
