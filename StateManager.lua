local StateManager = {}

StateManager.currentState = nil
StateManager.previousStates = {}

function StateManager:init()
end

function StateManager:changeState(newState, message)
    if StateManager.currentState and StateManager.currentState.exit then
        StateManager.currentState:exit(newState)
    end

    StateManager.currentState = newState

    if StateManager.currentState.enter and StateManager.currentState.enter then
        StateManager.currentState:enter(message)
    end

    if StateManager.currentState and StateManager.currentState.load then
        StateManager.currentState:load()
    end
end

function StateManager:update(dt)
    if StateManager.currentState and StateManager.currentState.update then
        StateManager.currentState:update(dt)
    end
end

function StateManager:draw()
    if StateManager.currentState and StateManager.currentState.draw then
        StateManager.currentState:draw()
    end
end

return StateManager
