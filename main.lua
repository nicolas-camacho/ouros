love = require("love")
local SceneManager = require("SceneManager")
local MainMenuScene = require("scenes.MainMenuScene")

function love.load()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    WIDTH = width
    HEIGHT = height
    INITIAL_X = WIDTH / 2 - 250
    INITIAL_Y = HEIGHT / 2 - 300
    love.graphics.setDefaultFilter("nearest", "nearest")
    Font =love.graphics.newFont("assets/Precise-M.ttf", 16)
    love.graphics.setFont(Font)
    SceneManager:init()
    SceneManager:changeState(MainMenuScene)
end

function love.update(dt)
    SceneManager:update(dt)
end

function love.draw()
    SceneManager:draw()
end

function love.keypressed(key)
    if SceneManager.keypressed then
        SceneManager:keypressed(key)
    end
end