local Object = require('dtech.vendor.classic')

---@class Transform
local Transform = Object:extend()

function Transform:new(node)
    self.node = node

    -- position
    self.x = 0
    self.y = 0

    -- rotation
    self.r = 0

    -- scale
    self.sx = 1
    self.sy = 1

    -- offset
    self.ox = 1
    self.oy = 1

    -- shear
    self.kx = 0
    self.ky = 0

    -- internal state
    self._loveTransform = nil
    self._isDirty = true
end

function Transform:_markDirty()
    self._isDirty = true

    for _, childNode in pairs(self.node.childNodes) do
        childNode.transform:_markDirty()
    end
end

-- Basic accessors

function Transform:setX(x)
    self.x = x
    self:_markDirty()
end

function Transform:setY(y)
    self.y = y
    self:_markDirty()
end

function Transform:setR(r)
    self.r = r
    self:_markDirty()
end

function Transform:setSX(sx)
    self.sx = sx
    self:_markDirty()
end

function Transform:setSY(sy)
    self.sy = sy
    self:_markDirty()
end

function Transform:setOX(ox)
    self.ox = ox
    self:_markDirty()
end

function Transform:setOY(oy)
    self.oy = oy
    self:_markDirty()
end

function Transform:setKX(kx)
    self.kx = kx
    self:_markDirty()
end

function Transform:setKY(ky)
    self.ky = ky
    self:_markDirty()
end

-- Utilities

function Transform:fromScreen(x, y)
    return self:getInverseGlobalLoveTransform():transformPoint(x, y)
end

function Transform:toScreen(x, y)
    return self:getGlobalLoveTransform():transformPoint(x, y)
end

-- Getters for LÖVE transforms
-- (inverse = transform from screen to world)

function Transform:getInverseLoveTransform()
    -- TODO: Consider caching
    return self:getLoveTransform():inverse()
end

function Transform:getInverseGlobalLoveTransform()
    -- TODO: Consider caching
    return self:getGlobalLoveTransform():inverse()
end

function Transform:getGlobalLoveTransform()
    -- TODO: Consider caching

    if self.node.parentNode then
        local parentTransform = self.node.parentNode.transform:getGlobalLoveTransform()
        return parentTransform:clone():apply(self:getLoveTransform())
    else
        return self:getLoveTransform()
    end
end

function Transform:getLoveTransform()
    -- Recalculate transform if dirty
    if not self._loveTransform or self._isDirty then
        self._loveTransform = love.math.newTransform(
            self.x,
            self.y,
            self.r,
            self.sx,
            self.sy,
            self.ox,
            self.oy,
            self.kx,
            self.ky
        )
        self._isDirty = false
    end

    return self._loveTransform
end

function Transform:__tostring()
    return "Transform(" ..
        "x=" .. tostring(self.x) ..
        ", y=" .. tostring(self.y) ..
        ", r=" .. tostring(self.r) ..
        ", sx=" .. tostring(self.sx) ..
        ", sy=" .. tostring(self.sy) ..
        ", ox=" .. tostring(self.ox) ..
        ", oy=" .. tostring(self.oy) ..
        ", kx=" .. tostring(self.kx) ..
        ", ky=" .. tostring(self.ky) ..
        ")"
end

return Transform
