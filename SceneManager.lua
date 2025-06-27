local SceneManager = {}

SceneManager.currentState = nil
SceneManager.previousStates = {}

function SceneManager:init()
end

function SceneManager:changeState(newState, message)
    if SceneManager.currentState and SceneManager.currentState.exit then
        SceneManager.currentState:exit(newState)
    end

    SceneManager.currentState = newState

    if SceneManager.currentState.enter and SceneManager.currentState.enter then
        SceneManager.currentState:enter(message)
    end

    if SceneManager.currentState and SceneManager.currentState.load then
        SceneManager.currentState:load()
    end
end

function SceneManager:update(dt)
    if SceneManager.currentState and SceneManager.currentState.update then
        SceneManager.currentState:update(dt)
    end
end

function SceneManager:draw()
    if SceneManager.currentState and SceneManager.currentState.draw then
        SceneManager.currentState:draw()
    end
end

function SceneManager:keypressed(key)
    if SceneManager.currentState and SceneManager.currentState.keypressed then
        SceneManager.currentState:keypressed(key)
    end
end

return SceneManager
