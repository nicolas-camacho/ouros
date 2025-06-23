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
        speed = 300
    }

    POINT = {
        x = 0,
        y = 0,
        width = 25,
        height = 25,
        exists = false,
        timer = 0,
        collided = false
    }

    SCORE = 0
end

function love.update(dt)

    if POINT.exists == false then
        POINT.timer = POINT.timer + 1
    end

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

    if POINT.exists == false and POINT.timer > 60 then
        POINT.x = math.random(INITIAL_X, INITIAL_X + 500 - POINT.width)
        POINT.y = math.random(INITIAL_Y, INITIAL_Y + 500 - POINT.height)
        POINT.exists = true
        POINT.timer = 0
        POINT.collided = false
    end

    CollideWithPoint = CollitionDetectionPlayer(POINT)

    if CollideWithPoint == true and POINT.collided == false then
        SCORE = SCORE + 1
        POINT.exists = false
        POINT.collided = true
    end
end

function love.draw()
    love.graphics.rectangle(
        "line",
        INITIAL_X,
        INITIAL_Y,
        500,
        500
    )

    love.graphics.rectangle("fill", PLAYER.x, PLAYER.y, PLAYER.width, PLAYER.height)

    if POINT.exists == true then
        love.graphics.rectangle("fill", POINT.x, POINT.y, POINT.width, POINT.height)
    end

    for i = 1, SCORE do
        local squaresPerSide = math.floor(500 / 25) + 1  -- 20 squares per side (500/25)
        local totalSquares = squaresPerSide * 4  -- 80 squares total around the rectangle
        
        if i <= totalSquares then
            local side = math.floor((i - 1) / squaresPerSide)  -- 0=top, 1=right, 2=bottom, 3=left
            local position = (i - 1) % squaresPerSide  -- Position on current side
            
            local x, y
            if side == 0 then  -- Top side
                x = INITIAL_X + (position * 25)
                y = INITIAL_Y - 25
            elseif side == 1 then  -- Right side
                x = INITIAL_X + 500
                y = INITIAL_Y + (position * 25)
            elseif side == 2 then  -- Bottom side
                x = INITIAL_X + 500 - ((position + 1) * 25)
                y = INITIAL_Y + 500
            else  -- Left side
                x = INITIAL_X - 25
                y = INITIAL_Y + 500 - ((position + 1) * 25)
            end
            
            love.graphics.rectangle("fill", x, y, 25, 25)
        end
    end
end

function CollitionDetectionPlayer(collider)
    if PLAYER.x < collider.x + collider.width and
        PLAYER.x + PLAYER.width > collider.x and
        PLAYER.y < collider.y + collider.height and
        PLAYER.y + PLAYER.height > collider.y then
        return true
    end
    return false
end
