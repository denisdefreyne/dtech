local Object = require('dtech.vendor.classic')

local TimerSet = require('dtech.timer_set')
local TweenSet = require('dtech.tween_set')
local Alignment = require('dtech.alignment')

local Scene = Object:extend()

local debugFont = love.graphics.newFont(12)

function Scene:new()
    self.nodes = {}

    self.pendingEvents = {}

    self.timerSet = TimerSet()
    self.tweenSet = TweenSet()
end

------------------------------------------------------------
-- Scene graph management

-- Add a node to the scene.
-- This does NOT automatically add child nodes.
function Scene:addNode(node)
    table.insert(self.nodes, node)
end

-- Remove a node from the scene.
-- This automatically removes all child nodes as well.
function Scene:removeNode(nodeToRemove)
    nodeToRemove.isDead = true

    -- Remove child nodes as well
    for _, childNode in pairs(nodeToRemove.childNodes) do
        childNode.isDead = true
    end
end

------------------------------------------------------------
-- Event handling

function Scene:addPendingEvent(event)
    table.insert(self.pendingEvents, event)
end

------------------------------------------------------------
-- Hooks (can implement these in subclasses)

function Scene:enter()
end

function Scene:exit()
end

function Scene:keypressed(key, scancode, isrepeat)
end

function Scene:keyreleased(key, scancode, isrepeat)
end

function Scene:resize(w, h)
end

function Scene:mousepressed(x, y, button, istouch, presses)
    self.clickedNode = nil
    self.draggedNode = nil

    -- Handle nodes in reverse Z order
    for i = #self.nodes, 1, -1 do
        local node = self.nodes[i]

        -- Handle click
        if not self.clickedNode then
            -- Don’t handle click more than once

            if node.clickable and node.clickable.bounds:containsScreen(x, y) then
                local onMouseDown = node.clickable.onMouseDown
                if onMouseDown then onMouseDown() end

                self.clickedNode = node
            end
        end

        -- Handle draggable
        if not self.draggedNode then
            -- Don’t handle drag more than once

            local draggable = node.draggable

            if draggable and draggable.bounds:containsScreen(x, y) and draggable.canDragFn() then
                self.draggedNode = node

                -- Only start draggin when mouse is moved!
                draggable.dragStarted = false

                -- Set offset
                local nodeOffsetX, nodeOffsetY = draggable.bounds.transform:fromScreen(x, y)
                draggable.offsetX = nodeOffsetX
                draggable.offsetY = nodeOffsetY
            end
        end
    end
end

function Scene:mousemoved(x, y, dx, dy)
    -- Handle draggable
    if self.draggedNode then
        local draggable = self.draggedNode.draggable

        if not draggable.dragStarted then
            draggable.dragStarted = true
            draggable.onDragStart()
        end

        -- Get change in XY coordinates
        -- (This is relative to the old transform!)
        local nodeDiffX, nodeDiffY = draggable.bounds.transform:fromScreen(x, y)

        -- Get new XY coordinates
        local newNodeX = draggable.bounds.transform.x + nodeDiffX
        local newNodeY = draggable.bounds.transform.y + nodeDiffY

        -- Adjust for click offset
        local newX = newNodeX - draggable.offsetX
        local newY = newNodeY - draggable.offsetY

        draggable.onDrag(newX, newY, nodeDiffX - draggable.offsetX, nodeDiffY - draggable.offsetY)
    end
end

function Scene:mousereleased(x, y, button, istouch, presses)
    if self.clickedNode then
        if self.clickedNode.clickable.bounds:containsScreen(x, y) then
            local onClick = self.clickedNode.clickable.onClick
            if onClick then onClick(presses) end
        else
            local onCancel = self.clickedNode.clickable.onCancel
            if onCancel then onCancel() end
        end
    end

    self.clickedNode = nil

    -- Handle draggable
    if self.draggedNode then
        local draggable = self.draggedNode.draggable

        -- Find drop target node
        local dropTargetNode = nil
        for _, node in pairs(self.nodes) do
            if node.dropTarget and node ~= self.draggedNode then
                -- Calculate anchor point, usually used as
                -- the rotation point; allow the anchor
                -- point to be in the drop target as well
                -- (not just the cursor)
                local altX, altY = self.draggedNode.transform:getGlobalLoveTransform():transformPoint(
                    self.draggedNode.transform.ox,
                    self.draggedNode.transform.oy
                )

                local isInBounds =
                    node.dropTarget.bounds:containsScreen(x, y) or
                    node.dropTarget.bounds:containsScreen(altX, altY)

                if isInBounds and node.dropTarget.canDropFn(self.draggedNode) then
                    dropTargetNode = node
                    break
                end
            end
        end

        if draggable.dragStarted then
            draggable.onDragEnd(dropTargetNode)
            draggable:reset()
        end

        self.draggedNode = nil
    end
end

------------------------------------------------------------
-- Timer/tween management

-- Creates a timer. After `duration` seconds, calls `fn`.
--
-- Returns the timer ID.
function Scene:addTimer(duration, fn)
    return self.timerSet:addTimer(duration, fn)
end

-- Creates a tween. For `duration` seconds, calls `fn` with the current progress
-- (between 0 and 1) towards the duration.
--
-- Returns the tween ID.
function Scene:addTween(duration, fn, loop)
    return self.tweenSet:addTween(duration, fn, loop)
end

-- Removes the timer with the given ID.
function Scene:removeTimer(timerId)
    self.timerSet:removeTimer(timerId)
end

-- Removes the tween with the given ID.
function Scene:removeTween(tweenId)
    self.tweenSet:removeTween(tweenId)
end

-- Similar to addTimer(), but specific for this node and the given key. When a
-- timer already exists for this node and key, the existing timer will be
-- finished immediately and deleted first.
function Scene:addTimerToNode(node, timerKey, duration, fn)
    -- Finish and delete existing timer (if any)
    local existingTimerId = node.timers[timerKey]
    if existingTimerId then
        self.timerSet:finishTimerImmediately(existingTimerId)
    end

    -- Add new timer
    local timerId = self:addTimer(duration, fn)
    node.timers[timerKey] = timerId
end

function Scene:removeTimerFromNode(node, timerKey)
    local existingTimerId = node.timers[timerKey]
    if existingTimerId then
        self.timerSet:removeTimer(existingTimerId)
    end

    node.timers[timerKey] = nil
end

-- Similar to addTween(), but specific for this node and the given key. When a
-- tween already exists for this node and key, the existing tween will be
-- finished immediately and deleted first.
function Scene:addTweenToNode(node, tweenKey, duration, fn)
    -- Finish and delete existing tween (if any)
    local existingTweenId = node.tweens[tweenKey]
    if existingTweenId then
        self.tweenSet:finishTweenImmediately(existingTweenId)
    end

    -- Add new tween
    local tweenId = self:addTween(duration, fn, false)
    node.tweens[tweenKey] = tweenId
end

function Scene:removeTweenFromNode(node, tweenKey)
    local existingTweenId = node.tweens[tweenKey]
    if existingTweenId then
        self.tweenSet:removeTween(existingTweenId)
    end

    node.tweens[tweenKey] = nil
end

function Scene:finishTweenOnNode(node, tweenKey)
    local existingTweenId = node.tweens[tweenKey]
    if existingTweenId then
        self.tweenSet:finishTweenImmediately(existingTweenId)
    end

    node.tweens[tweenKey] = nil
end

------------------------------------------------------------
-- Private

local function sortNodes(scene)
    -- Group nodes by draw order
    local buckets = {}
    for idx, node in pairs(scene.nodes) do
        local bucket = buckets[node.z:get()]

        if not bucket then
            bucket = {}
            buckets[node.z:get()] = bucket
        end

        table.insert(bucket, node)
    end

    -- Sort groups
    local zs = {}
    for z in pairs(buckets) do
        table.insert(zs, z)
    end
    table.sort(zs)

    -- Insert nodes
    scene.nodes = {}
    for _, z in pairs(zs) do
        local bucket = buckets[z]
        for _, node in pairs(bucket) do
            table.insert(scene.nodes, node)
        end
    end
end

local function drawNode(node)
    love.graphics.push()
    love.graphics.applyTransform(node.transform:getGlobalLoveTransform())

    if node.color then
        love.graphics.setColor(node.color.r, node.color.g, node.color.b, node.color.a)
    end

    if node.font then
        love.graphics.setFont(node.font)
    end

    if node.loveDrawable then
        love.graphics.draw(node.loveDrawable)
    elseif node.drawable then
        node.drawable:draw()
    elseif node.string then
        local size = node.size
        if size then
            local width = size:width()
            local alignment = "left"
            if node.aligment == Alignment.CENTER then
                alignment = "center"
            elseif node.alignment == Alignment.END then
                alignment = "right"
            end
            love.graphics.printf(node.string, 0, 0, width, alignment)
        else
            love.graphics.print(node.string)
        end
    end

    -- Debug Z index
    if CONFIG.data.debugZ then
        love.graphics.setFont(debugFont)
        local text = ("z=%i"):format(node.z:get())
        local textWidth = debugFont:getWidth(text)
        local textHeight = debugFont:getHeight()
        love.graphics.setColor(1, 0, 1)
        love.graphics.rectangle('fill', 0, 0, textWidth, textHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text)
    end

    -- Debug size
    if CONFIG.data.debugSize and node.size then
        love.graphics.setFont(debugFont)
        local text = ("%.0f×%.0f"):format(node.size:width(), node.size:height())
        local textWidth = debugFont:getWidth(text)
        local textHeight = debugFont:getHeight()
        love.graphics.setColor(1, 0, 1)
        love.graphics.rectangle('fill', 2, 2, textWidth, textHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text, 2, 2)
    end

    if node.color then
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.pop()
end

function Scene:draw()
    for _, node in pairs(self.nodes) do
        drawNode(node)
    end
end

function Scene:update(dt)
    self.timerSet:update(dt)
    self.tweenSet:update(dt)

    -- Handle events
    for _, event in ipairs(self.pendingEvents) do
        event:handle(self)
    end
    self.pendingEvents = {}

    -- Update nodes’ components
    for _, node in pairs(self.nodes) do
        if node.hoverable then
            node.hoverable:update(dt)
        end
    end

    -- Remove dead nodes
    for i = #self.nodes, 1, -1 do
        local node = self.nodes[i]
        if node.isDead then
            table.remove(self.nodes, i)
        end
    end

    sortNodes(self)
end

return Scene
