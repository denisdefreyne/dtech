local SceneManager = {
    currentScene = nil,
    nextScene = nil
}

local TimerSet = require('dtech.timer_set')
local TweenSet = require('dtech.tween_set')
local Shaders = require('dtech.shaders')
local Easing = require('dtech.easing')

local function captureScene(scene, canvas)
    love.graphics.setCanvas({ canvas, stencil = true })
    love.graphics.clear()

    if scene and scene.draw then
        scene:draw()
    end

    love.graphics.setCanvas()

    return canvas
end

function SceneManager:init(currentScene)
    -- The active scene.
    self.currentScene = currentScene

    -- If in a scene transition: what was the previous scene?
    self.previousScene = nil

    -- If about to start a scene transition: what scene should go next?
    self.nextScene = nil

    -- Transition details
    self.canvas1 = love.graphics.newCanvas()
    self.canvas2 = love.graphics.newCanvas()
    self.sceneTexture1 = nil
    self.sceneTexture2 = nil
    self.isInTransition = false
    self.transitionProgress = 0
    self.transitionDuration = 0

    ---@type TimerSet
    self.timerSet = TimerSet()

    ---@type TweenSet
    self.tweenSet = TweenSet()

    self.currentScene:enter()
end

function SceneManager:switchTo(scene, duration, shader, easing)
    -- Immediately finish up any tweens
    if self.activeTransitionTween then
        self.tweenSet:finishTweenImmediately(self.activeTransitionTween)
    end

    -- Cue the next scene.
    -- This next scene will be switched to in update().
    self.nextScene = scene
    self.transitionDuration = duration or 0.1
    self.transitionShader = shader or Shaders.dissolveTransition
    self.transitionEasing = easing or Easing.linear
end

function SceneManager:draw()
    if self.isInTransition then
        self.sceneTexture1 = captureScene(self.previousScene, self.canvas1)
        self.sceneTexture2 = captureScene(self.currentScene, self.canvas2)

        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.setShader(self.transitionShader)

        self.transitionShader:send("progress", self.transitionProgress)
        self.transitionShader:send("fromTexture", self.sceneTexture1)
        self.transitionShader:send("toTexture", self.sceneTexture2)
        love.graphics.draw(self.sceneTexture2)

        love.graphics.setShader()
        love.graphics.setBlendMode("alpha")
    else
        if self.currentScene then
            self.currentScene:draw()
        end
    end
end

function SceneManager:update(dt)
    -- Switch to next scene, if any.
    if self.nextScene then
        self.transitionProgress = 0
        self.isInTransition = true

        self.previousScene = self.currentScene
        self.currentScene = self.nextScene
        self.nextScene = nil

        self.previousScene:exit()
        self.currentScene:enter()

        self.activeTransitionTween = self.tweenSet:addTween(self.transitionDuration, function(dt2)
            self.transitionProgress = self.transitionEasing(dt2)

            if dt2 == 1 then
                -- Transition has ended
                self.isInTransition = false
                self.sceneTexture1 = nil
                self.sceneTexture2 = nil
                self.previousScene = nil
                self.activeTransitionTween = nil
            end
        end, false)
    end

    if self.previousScene then
        self.previousScene:update(dt)
    end

    if self.currentScene then
        self.currentScene:update(dt)
    end

    self.timerSet:update(dt)
    self.tweenSet:update(dt)
end

function SceneManager:resize(w, h)
    -- Recreate canvases to be of the correct (new) size
    self.canvas1 = love.graphics.newCanvas()
    self.canvas2 = love.graphics.newCanvas()

    if self.currentScene then
        self.currentScene:resize(w, h)
    end
end

function SceneManager:mousepressed(x, y, button, istouch, presses)
    if self.currentScene then
        self.currentScene:mousepressed(x, y, button, istouch, presses)
    end
end

function SceneManager:mousereleased(x, y, button, istouch, presses)
    if self.currentScene then
        self.currentScene:mousereleased(x, y, button, istouch, presses)
    end
end

function SceneManager:mousemoved(x, y, dx, dy)
    if self.currentScene then
        self.currentScene:mousemoved(x, y, dx, dy)
    end
end

function SceneManager:keypressed(key, scancode, isrepeat)
    if self.currentScene then
        self.currentScene:keypressed(key, scancode, isrepeat)
    end
end

function SceneManager:keyreleased(key, scancode, isrepeat)
    if self.currentScene then
        self.currentScene:keyreleased(key, scancode, isrepeat)
    end
end

return SceneManager
