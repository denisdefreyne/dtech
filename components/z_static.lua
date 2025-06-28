local Object = require('dtech.vendor.classic')

local ZStatic = Object:extend()

function ZStatic:new(value)
    self.value = value
end

function ZStatic:get()
    return self.value
end

return ZStatic
