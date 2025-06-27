local GameOverScene = {}

function GameOverScene:load()
    GameOverScene.selectedOption = 1
    GameOverScene.options = {"Start Again", "Exit"}
end

function GameOverScene:update(dt)
end

function GameOverScene:draw()
    love.graphics.print("GAME OVER", WIDTH / 2 - 120, HEIGHT / 2 - 100, 0, 3, 3)
    for i, option in ipairs(GameOverScene.options) do
        if i == GameOverScene.selectedOption then
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

function GameOverScene:enter(message)
    print("GameOverScene:enter", message)
end

function GameOverScene:exit(nextState)
    print("GameOverScene:exit", nextState.name)
end

function GameOverScene:keypressed(key)
    if key == "up" then
        if GameOverScene.selectedOption > 1 then
            GameOverScene.selectedOption = GameOverScene.selectedOption - 1
        else
            GameOverScene.selectedOption = #GameOverScene.options
        end
    elseif key == "down" then
        if GameOverScene.selectedOption < #GameOverScene.options then
            GameOverScene.selectedOption = GameOverScene.selectedOption + 1
        else
            GameOverScene.selectedOption = 1
        end
    end

    if key == "return" then
        if GameOverScene.selectedOption == 1 then
            local GameScene = require("scenes.GameScene")
            require("SceneManager"):changeState(GameScene)
        elseif GameOverScene.selectedOption == 2 then
            love.event.quit()
        end
    end
end

GameOverScene.name = "GameOverScene"

return GameOverScene