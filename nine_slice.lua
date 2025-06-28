local Object = require('dtech.vendor.classic')

local NineSlice = Object:extend()

function NineSlice:new(image, leftWidth, rightWidth, topHeight, bottomHeight)
    NineSlice.super.new(self)

    self.image = image

    local width = image:getWidth()
    local height = image:getHeight()

    self.w1 = leftWidth
    self.w2 = width - leftWidth - rightWidth
    self.w3 = rightWidth

    self.h1 = topHeight
    self.h2 = height - topHeight - bottomHeight
    self.h3 = bottomHeight

    self.x1 = 0
    self.x2 = self.w1
    self.x3 = self.w1 + self.w2

    self.y1 = 0
    self.y2 = self.h1
    self.y3 = self.h1 + self.h2

    self.quads = {}
    table.insert(self.quads, love.graphics.newQuad(self.x1, self.y1, self.w1, self.h1, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x2, self.y1, self.w2, self.h1, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x3, self.y1, self.w3, self.h1, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x1, self.y2, self.w1, self.h2, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x2, self.y2, self.w2, self.h2, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x3, self.y2, self.w3, self.h2, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x1, self.y3, self.w1, self.h3, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x2, self.y3, self.w2, self.h3, width, height))
    table.insert(self.quads, love.graphics.newQuad(self.x3, self.y3, self.w3, self.h3, width, height))
end

function NineSlice:draw(w, h)
    love.graphics.setColor(1, 1, 1)

    local middleOriginalWidth = self.w2
    local middleDesiredWidth = w - self.w1 - self.w3
    local sx = middleDesiredWidth / middleOriginalWidth

    local middleOriginalHeight = self.h2
    local middleDesiredHeight = h - self.h1 - self.h3
    local sy = middleDesiredHeight / middleOriginalHeight

    love.graphics.draw(self.image, self.quads[1], 0, 0, 0, 1, 1)
    love.graphics.draw(self.image, self.quads[2], self.w1, 0, 0, sx, 1)
    love.graphics.draw(self.image, self.quads[3], self.w1 + self.w2 * sx, 0, 0, 1, 1)

    love.graphics.draw(self.image, self.quads[4], 0, self.h1, 0, 1, sy)
    love.graphics.draw(self.image, self.quads[5], self.w1, self.h1, 0, sx, sy)
    love.graphics.draw(self.image, self.quads[6], self.w1 + self.w2 * sx, self.h1, 0, 1, sy)

    love.graphics.draw(self.image, self.quads[7], 0, self.h1 + self.h2 * sy, 0, 1, 1)
    love.graphics.draw(self.image, self.quads[8], self.w1, self.h1 + self.h2 * sy, 0, sx, 1)
    love.graphics.draw(self.image, self.quads[9], self.w1 + self.w2 * sx, self.h1 + self.h2 * sy, 0, 1, 1)
end

return NineSlice
