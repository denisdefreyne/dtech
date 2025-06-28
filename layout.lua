local Object = require('dtech.vendor.classic')

local Layout = Object:extend()

local Alignment = require('dtech.alignment')
local Sizing = require('dtech.sizing')

Layout.HORIZONTAL = "horizontal"
Layout.VERTICAL = "vertical"

function Layout:new(gap, padding, direction)
    Layout.super.new(self)

    self.gap = gap
    self.padding = padding
    self.direction = direction
end

function Layout:calcFitSize(rootNode)
    if rootNode.mainSizing ~= Sizing.FIT and rootNode.mainSizing ~= Sizing.GROW then
        return
    end

    local nodes = rootNode.childNodes

    local w = 0
    local h = 0

    for _, node in ipairs(nodes) do
        local nw = node.size:width()
        local nh = node.size:height()

        if self.direction == Layout.VERTICAL then
            w = math.max(w, nw)
            h = h + nh
        else
            w = w + nw
            h = math.max(h, nh)
        end
    end

    if #nodes > 0 then
        if self.direction == Layout.VERTICAL then
            h = h + (#nodes - 1) * self.gap
        else
            w = w + (#nodes - 1) * self.gap
        end
    end

    if #nodes > 0 then
        rootNode.size:setWidth(w + 2 * self.padding)
        rootNode.size:setHeight(h + 2 * self.padding)
    else
        rootNode.size:setWidth(0)
        rootNode.size:setHeight(0)
    end
end

function Layout:calcGrowSize(rootNode)
    local nodes = rootNode.childNodes

    local numNodesWithGrowSizing = 0
    local used = 0

    for _, node in ipairs(nodes) do
        local nw = node.size:width()
        local nh = node.size:height()

        if node.mainSizing == Sizing.GROW then
            numNodesWithGrowSizing = numNodesWithGrowSizing + 1
        end

        if self.direction == Layout.VERTICAL then
            used = used + nh
        else
            used = used + nw
        end
    end

    local rw = rootNode.size:width() - 2 * self.padding
    local rh = rootNode.size:height() - 2 * self.padding

    if numNodesWithGrowSizing > 0 then
        -- Adjust for padding and inter-child gap
        if #nodes > 0 then
            used = used + (#nodes - 1) * self.gap
        end

        -- Calculate space that can be distributed
        local available
        if self.direction == Layout.VERTICAL then
            available = rh - used
        else
            available = rw - used
        end
        local divided = available / numNodesWithGrowSizing

        -- Distribute space
        for _, node in ipairs(nodes) do
            if node.mainSizing == Sizing.GROW then
                if self.direction == Layout.VERTICAL then
                    node.size:setHeight(node.size:height() + divided)
                else
                    node.size:setWidth(node.size:width() + divided)
                end
            end
        end
    end

    -- Grow on cross axis
    for _, node in ipairs(nodes) do
        if node.crossSizing == Sizing.GROW then
            if self.direction == Layout.VERTICAL then
                node.size:setWidth(rw)
            else
                node.size:setHeight(rh)
            end
        end
    end
end

function Layout:calcChildPositions(rootNode)
    local nodes = rootNode.childNodes

    local dist = self.padding

    for _, node in ipairs(nodes) do
        if self.direction == Layout.VERTICAL then
            if node.alignment == Alignment.CENTER then
                node.transform:setX((rootNode.size:width() - node.size:width()) / 2)
            elseif node.alignment == Alignment.END then
                node.transform:setX(rootNode.size:width() - self.padding - node.size:width())
            else
                node.transform:setX(self.padding)
            end

            node.transform:setY(dist)

            dist = dist + self.gap + node.size:height()
        else
            if node.alignment == Alignment.CENTER then
                node.transform:setY((rootNode.size:height() - node.size:height()) / 2)
            elseif node.alignment == Alignment.END then
                node.transform:setY(rootNode.size:height() - self.padding - node.size:height())
            else
                node.transform:setY(self.padding)
            end

            node.transform:setX(dist)

            dist = dist + self.gap + node.size:width()
        end
    end
end

return Layout
