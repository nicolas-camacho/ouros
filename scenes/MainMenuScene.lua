local MainMenuScene = {}

function MainMenuScene:load()
    MainMenuScene.selectedOption = 1
    MainMenuScene.options = {"Start Game", "Exit"}
end

function MainMenuScene:update(dt)
end

function MainMenuScene:draw()
    love.graphics.print("OUROS", WIDTH / 2 - 120, HEIGHT / 2 - 100, 0, 3, 3)
    for i, option in ipairs(MainMenuScene.options) do
        if i == MainMenuScene.selectedOption then
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

function MainMenuScene:enter(message)
    print("MainMenuScene:enter", message)
end

function MainMenuScene:exit(nextState)
    print("MainMenuScene:exit", nextState.name)
end

function MainMenuScene:keypressed(key)
    if key == "up" then
        if MainMenuScene.selectedOption > 1 then
            MainMenuScene.selectedOption = MainMenuScene.selectedOption - 1
        else
            MainMenuScene.selectedOption = #MainMenuScene.options
        end
    elseif key == "down" then
        if MainMenuScene.selectedOption < #MainMenuScene.options then
            MainMenuScene.selectedOption = MainMenuScene.selectedOption + 1
        else
            MainMenuScene.selectedOption = 1
        end
    end

    if key == "return" then
        if MainMenuScene.selectedOption == 1 then
            local GameScene = require("scenes.GameScene")
            require("SceneManager"):changeState(GameScene)
        elseif MainMenuScene.selectedOption == 2 then
            love.event.quit()
        end
    end
end

MainMenuScene.name = "MainMenuScene"

return MainMenuScene