local Object = require('dtech.vendor.classic')

local NineSliceInstance = Object:extend()

function NineSliceInstance:new(nine_slice, w, h)
    self.nineSlice = nine_slice
    self.w = w
    self.h = h
end

function NineSliceInstance:draw()
    self.nineSlice:draw(self.w, self.h)
end

return NineSliceInstance
