local MainMenuState = {}

function MainMenuState:load()
    MainMenuState.selectedOption = 1
    MainMenuState.options = {"Start Game", "Exit"}
end

function MainMenuState:update(dt)
end

function MainMenuState:draw()
    love.graphics.print("OUROS", WIDTH / 2 - 120, HEIGHT / 2 - 100, 0, 3, 3)
    for i, option in ipairs(MainMenuState.options) do
        if i == MainMenuState.selectedOption then
            love.graphics.print({
                {1, 1, 1, 1},
                option
            }, WIDTH / 2 - 120, HEIGHT / 2 - 100 + (i - 1) * 20 + 100)
        else
            love.graphics.print({
                {0.5, 0.5, 0.5, 1},
                option
            }, WIDTH / 2 - 120, HEIGHT / 2 - 100 + (i - 1) * 20 + 100)
        end
    end
end

function MainMenuState:enter(message)
    print("MainMenuState:enter", message)
end

function MainMenuState:exit(nextState)
    print("MainMenuState:exit", nextState.name)
end

function MainMenuState:keypressed(key)
    if key == "up" then
        if MainMenuState.selectedOption > 1 then
            MainMenuState.selectedOption = MainMenuState.selectedOption - 1
        else
            MainMenuState.selectedOption = #MainMenuState.options
        end
    elseif key == "down" then
        if MainMenuState.selectedOption < #MainMenuState.options then
            MainMenuState.selectedOption = MainMenuState.selectedOption + 1
        else
            MainMenuState.selectedOption = 1
        end
    end

    if key == "return" then
        if MainMenuState.selectedOption == 1 then
            local GameState = require("states.GameState")
            require("StateManager"):changeState(GameState)
        elseif MainMenuState.selectedOption == 2 then
            love.event.quit()
        end
    end
end

MainMenuState.name = "MainMenuState"

return MainMenuState