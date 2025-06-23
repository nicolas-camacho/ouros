love = require("love")

function love.load()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    INITIAL_X = width / 2 - 250
    INITIAL_Y = height / 2 - 300

    PLAYER = {
        x = INITIAL_X,
        y = INITIAL_Y,
        width = 25,
        height = 25,
        speed = 200
    }
end

function love.update(dt)
    if love.keyboard.isDown("up") and PLAYER.y > INITIAL_Y then
        PLAYER.y = PLAYER.y - PLAYER.speed * dt
    end

    if love.keyboard.isDown("down") and PLAYER.y < INITIAL_Y + (500 - PLAYER.height) then
        PLAYER.y = PLAYER.y + PLAYER.speed * dt
    end

    if love.keyboard.isDown("left") and PLAYER.x > INITIAL_X then
        PLAYER.x = PLAYER.x - PLAYER.speed * dt
    end

    if love.keyboard.isDown("right") and PLAYER.x < INITIAL_X + (500 - PLAYER.width) then
        PLAYER.x = PLAYER.x + PLAYER.speed * dt
    end
end

function love.draw()
    love.graphics.print(love.timer.getFPS())
    
    love.graphics.rectangle(
        "line",
        INITIAL_X,
        INITIAL_Y,
        500,
        500
    )

    love.graphics.rectangle("fill", PLAYER.x, PLAYER.y, PLAYER.width, PLAYER.height)
end
