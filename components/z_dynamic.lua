local Object = require('dtech.vendor.classic')

local ZDynamic = Object:extend()

function ZDynamic:new(fn)
    self.fn = fn
end

function ZDynamic:get()
    return self.fn()
end

return ZDynamic
