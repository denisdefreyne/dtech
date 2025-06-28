local Object = require('dtech.vendor.classic')

local Event = Object:extend()

-- Override in subclasses
function Event:handle()
end

return Event
