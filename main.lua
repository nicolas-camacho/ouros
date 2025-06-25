love = require("love")
local StateManager = require("StateManager")
local MainMenuState = require("states.MainMenuState")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    StateManager:init()
    StateManager:changeState(MainMenuState)
end

function love.update(dt)
    StateManager:update(dt)
end

function love.draw()
    StateManager:draw()
end