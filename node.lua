local Object    = require('dtech.vendor.classic')
local Transform = require('dtech.components.transform')
local ZStatic   = require('dtech.components.z_static')

local Node      = Object:extend()

local nodeId    = 0
function Node:new()
    self.id = nodeId
    nodeId = nodeId + 1

    self.childNodes = {}
    self.parentNode = nil

    -- State
    self.isDead = false
    self.timers = {}
    self.tweens = {}

    -- Components
    ---@type Transform
    self.transform = Transform(self)
    self.z = ZStatic(0)
    self.size = nil
    self.font = nil
    self.color = nil
    self.string = nil
    self.loveDrawable = nil
    self.drawable = nil
    self.hoverable = nil
    self.clickable = nil
    self.description = nil
    self.draggable = nil
    self.dropTarget = nil
end

function Node:__tostring()
    local extra = self.description and "; " .. self.description or ""
    return "Node(" .. tostring(self.id) .. extra .. ")"
end

function Node:setParentNode(parentNode)
    if self.parentNode then
        print('Node already has a parent; aborting', self, self.parentNode)
        return
    end

    self.parentNode = parentNode
    table.insert(parentNode.childNodes, self)
end

local function applyLayout_calcFitSizes(node)
    for _, childNode in ipairs(node.childNodes) do
        applyLayout_calcFitSizes(childNode)
    end

    if node.layout then
        node.layout:calcFitSize(node)
    end
end

local function applyLayout_calcGrowSizes(node)
    if node.layout then
        node.layout:calcGrowSize(node)
    end

    for _, childNode in ipairs(node.childNodes) do
        applyLayout_calcGrowSizes(childNode)
    end
end

local function applyLayout_calcPositions(node)
    for _, childNode in ipairs(node.childNodes) do
        applyLayout_calcPositions(childNode)
    end

    if node.layout then
        node.layout:calcChildPositions(node)
    end
end

function Node:applyLayout()
    applyLayout_calcFitSizes(self)
    applyLayout_calcGrowSizes(self)
    applyLayout_calcPositions(self)
end

return Node
