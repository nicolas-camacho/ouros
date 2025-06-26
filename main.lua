love = require("love")
local StateManager = require("StateManager")
local MainMenuState = require("states.MainMenuState")

function love.load()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    WIDTH = width
    HEIGHT = height
    love.graphics.setDefaultFilter("nearest", "nearest")
    Font =love.graphics.newFont("assets/Precise-M.ttf", 16)
    love.graphics.setFont(Font)
    StateManager:init()
    StateManager:changeState(MainMenuState)
end

function love.update(dt)
    StateManager:update(dt)
end

function love.draw()
    StateManager:draw()
end

function love.keypressed(key)
    if StateManager.keypressed then
        StateManager:keypressed(key)
    end
end