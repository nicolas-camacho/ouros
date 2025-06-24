love = require("love")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    -- Ouros
    OurosHead = love.graphics.newImage("assets/ouros-head-simple.png")
    OurosBody = love.graphics.newImage("assets/ouros-body-simple.png")
    OurosTail = love.graphics.newImage("assets/ouros-tail-simple.png")

    INITIAL_X = width / 2 - 250
    INITIAL_Y = height / 2 - 300

    PLAYER = {
        x = INITIAL_X + 250,
        y = INITIAL_Y + 250,
        width = 25,
        height = 25,
        speed = 200,
        sprite = love.graphics.newImage("assets/player.png"),
        sprite_width = 32,
        sprite_height = 8,
        quad_width = 8,
        quad_height = 8,
        quads = {},
        animation = {
            walk = false,
            frame = 1,
            speed = 0.1
        }
    }

    for i = 1, 4 do
        PLAYER.quads[i] = love.graphics.newQuad(
            (i - 1) * PLAYER.quad_width,
            0,
            PLAYER.quad_width,
            PLAYER.quad_height,
            PLAYER.sprite_width,
            PLAYER.sprite_height)
    end

    POINT = {
        x = 0,
        y = 0,
        width = 25,
        height = 25,
        exists = false,
        timer = 0,
        collided = false,
        sprite = love.graphics.newImage("assets/point.png")
    }

    BULLET_1 = {
        width = 5,
        height = 5,
        sprite = love.graphics.newImage("assets/bullet-1.png"),
        type = 1,
    }

    ATTACK = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
        timer = 0,
        type = 1,
        exists = false,
        collided = false,
        speed = 200,
    }

    SCORE = 0
end

function love.update(dt)

    if POINT.exists == false then
        POINT.timer = POINT.timer + 1
    end

    if ATTACK.exists == false then
        ATTACK.timer = ATTACK.timer + 1
    end

    -- Reset animation state at the beginning of each frame
    PLAYER.animation.walk = false

    if love.keyboard.isDown("up") and PLAYER.y > INITIAL_Y then
        PLAYER.y = PLAYER.y - PLAYER.speed * dt
        PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("down") and PLAYER.y < INITIAL_Y + (500 - PLAYER.height) then
        PLAYER.y = PLAYER.y + PLAYER.speed * dt
        PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("left") and PLAYER.x > INITIAL_X then
        PLAYER.x = PLAYER.x - PLAYER.speed * dt
        PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("right") and PLAYER.x < INITIAL_X + (500 - PLAYER.width) then
        PLAYER.x = PLAYER.x + PLAYER.speed * dt
        PLAYER.animation.walk = true
    end

    -- Reset animation frame to 1 when not walking
    if PLAYER.animation.walk == false then
        PLAYER.animation.frame = 1
        PLAYER.animation.speed = 0.1
    end

    if POINT.exists == false and POINT.timer > 30 then
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

    if ATTACK.exists == false and ATTACK.timer > 60 then
        if ATTACK.type == 1 then
            ATTACK.x = INITIAL_X
            ATTACK.y = INITIAL_Y
            ATTACK.width = 250
            ATTACK.height = 25
        end

        ATTACK.exists = true
        ATTACK.timer = 0
        ATTACK.collided = false
    end

    if ATTACK.exists == true then
        ATTACK.y = ATTACK.y + ATTACK.speed * dt
        if ATTACK.y > INITIAL_Y + 500 then
            ATTACK.exists = false
        end
    end

    CollideWithAttack = CollitionDetectionPlayer(ATTACK)

    if CollideWithAttack == true and ATTACK.collided == false then
        SCORE = SCORE - 1
        ATTACK.exists = false
        ATTACK.collided = true
        PLAYER.x = INITIAL_X + 250
        PLAYER.y = INITIAL_Y + 250
    end

    if PLAYER.animation.walk == true then
        PLAYER.animation.speed = PLAYER.animation.speed + dt

        if PLAYER.animation.speed > 0.2 then
            PLAYER.animation.speed = 0.1

            PLAYER.animation.frame = PLAYER.animation.frame + 1

            if PLAYER.animation.frame > 4 then
                PLAYER.animation.frame = 1
            end
        end
    end
end

function love.draw()
    -- Map
    love.graphics.rectangle(
        "line",
        INITIAL_X,
        INITIAL_Y,
        500,
        500
    )
    -- Player
    love.graphics.draw(PLAYER.sprite, PLAYER.quads[PLAYER.animation.frame], PLAYER.x, PLAYER.y, 0, 25 / PLAYER.quad_width, 25 / PLAYER.quad_height)
    -- Points
    if POINT.exists == true then
        love.graphics.draw(POINT.sprite, POINT.x, POINT.y, 0, 25 / POINT.sprite:getWidth(), 25 / POINT.sprite:getHeight())
    end
    -- Attack
    if ATTACK.exists == true then
        for i = 1, 8 do
            love.graphics.draw(BULLET_1.sprite, ATTACK.x + ((i - 1) * 30), ATTACK.y, 0, 25 / BULLET_1.sprite:getWidth(), 25 / BULLET_1.sprite:getHeight())
        end
    end
    -- Ouros movement
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
            
            if i == SCORE then
                if side == 1 then
                    love.graphics.draw(OurosHead, x + 25, y, math.rad(90), 25 / OurosHead:getWidth(), 25 / OurosHead:getHeight())
                elseif side == 2 then
                    love.graphics.draw(OurosHead, x + 25, y + 25, math.rad(180), 25 / OurosHead:getWidth(), 25 / OurosHead:getHeight())
                elseif side == 3 then
                    love.graphics.draw(OurosHead, x, y + 25, math.rad(270), 25 / OurosHead:getWidth(), 25 / OurosHead:getHeight())
                else
                    love.graphics.draw(OurosHead, x, y, 0, 25 / OurosHead:getWidth(), 25 / OurosHead:getHeight())
                end
            elseif i == 1 then
                love.graphics.draw(OurosTail, x, y, 0, 25 / OurosTail:getWidth(), 25 / OurosTail:getHeight())
            else
                if side == 1 then
                    love.graphics.draw(OurosBody, x + 25, y, math.rad(90), 25 / OurosBody:getWidth(), 25 / OurosBody:getHeight())
                elseif side == 2 then
                    love.graphics.draw(OurosBody, x + 25, y + 25, math.rad(180), 25 / OurosBody:getWidth(), 25 / OurosBody:getHeight())
                elseif side == 3 then
                    love.graphics.draw(OurosBody, x, y + 25, math.rad(270), 25 / OurosBody:getWidth(), 25 / OurosBody:getHeight())
                else
                    love.graphics.draw(OurosBody, x, y, 0, 25 / OurosBody:getWidth(), 25 / OurosBody:getHeight())
                end
            end
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
