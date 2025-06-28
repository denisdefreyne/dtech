local Object = require('dtech.vendor.classic')

local Clickable = Object:extend()

function Clickable:new(bounds, onClick, onMouseDown, onCancel)
    self.bounds      = bounds
    self.onClick     = onClick
    self.onMouseDown = onMouseDown
    self.onCancel    = onCancel
end

return Clickable
