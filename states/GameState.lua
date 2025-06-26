local GameState = {
    PLAYER = {
        x = 0,
        y = 0,
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
    },
    POINT = {
        x = 0,
        y = 0,
        width = 25,
        height = 25,
        exists = false,
        timer = 0,
        collided = false,
        sprite = love.graphics.newImage("assets/point.png")
    },
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
    },
    SCORE = 0
}

function CollitionDetectionPlayer(collider)
    if GameState.PLAYER.x < collider.x + collider.width and
        GameState.PLAYER.x + GameState.PLAYER.width > collider.x and
        GameState.PLAYER.y < collider.y + collider.height and
        GameState.PLAYER.y + GameState.PLAYER.height > collider.y then
        return true
    end
    return false
end

function GameState:load()
    INITIAL_X = WIDTH / 2 - 250
    INITIAL_Y = HEIGHT / 2 - 300
    -- Ouros
    OurosHead = love.graphics.newImage("assets/ouros-head-simple.png")
    OurosBody = love.graphics.newImage("assets/ouros-body-simple.png")
    OurosTail = love.graphics.newImage("assets/ouros-tail-simple.png")

    -- Player
    GameState.PLAYER.x = INITIAL_X + 250
    GameState.PLAYER.y = INITIAL_Y + 250

    for i = 1, 4 do
        GameState.PLAYER.quads[i] = love.graphics.newQuad(
            (i - 1) * GameState.PLAYER.quad_width,
            0,
            GameState.PLAYER.quad_width,
            GameState.PLAYER.quad_height,
            GameState.PLAYER.sprite_width,
            GameState.PLAYER.sprite_height)
    end

    BULLET_1 = {
        width = 5,
        height = 5,
        sprite = love.graphics.newImage("assets/bullet-1.png"),
        type = 1,
    }
end

function GameState:update(dt)
    if GameState.POINT.exists == false then
        GameState.POINT.timer = GameState.POINT.timer + 1
    end

    if GameState.ATTACK.exists == false then
        GameState.ATTACK.timer = GameState.ATTACK.timer + 1
    end

    -- Reset animation state at the beginning of each frame
    GameState.PLAYER.animation.walk = false

    if love.keyboard.isDown("up") and GameState.PLAYER.y > INITIAL_Y then
        GameState.PLAYER.y = GameState.PLAYER.y - GameState.PLAYER.speed * dt
        GameState.PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("down") and GameState.PLAYER.y < INITIAL_Y + (500 - GameState.PLAYER.height) then
        GameState.PLAYER.y = GameState.PLAYER.y + GameState.PLAYER.speed * dt
        GameState.PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("left") and GameState.PLAYER.x > INITIAL_X then
        GameState.PLAYER.x = GameState.PLAYER.x - GameState.PLAYER.speed * dt
        GameState.PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("right") and GameState.PLAYER.x < INITIAL_X + (500 - GameState.PLAYER.width) then
        GameState.PLAYER.x = GameState.PLAYER.x + GameState.PLAYER.speed * dt
        GameState.PLAYER.animation.walk = true
    end

    -- Reset animation frame to 1 when not walking
    if GameState.PLAYER.animation.walk == false then
        GameState.PLAYER.animation.frame = 1
        GameState.PLAYER.animation.speed = 0.1
    end

    if GameState.POINT.exists == false and GameState.POINT.timer > 30 then
        GameState.POINT.x = math.random(INITIAL_X, INITIAL_X + 500 - GameState.POINT.width)
        GameState.POINT.y = math.random(INITIAL_Y, INITIAL_Y + 500 - GameState.POINT.height)
        GameState.POINT.exists = true
        GameState.POINT.timer = 0
        GameState.POINT.collided = false
    end

    CollideWithPoint = CollitionDetectionPlayer(GameState.POINT)

    if CollideWithPoint == true and GameState.POINT.collided == false then
        GameState.SCORE = GameState.SCORE + 1
        GameState.POINT.exists = false
        GameState.POINT.collided = true
    end

    if GameState.ATTACK.exists == false and GameState.ATTACK.timer > 60 then
        if GameState.ATTACK.type == 1 then
            GameState.ATTACK.x = INITIAL_X
            GameState.ATTACK.y = INITIAL_Y
            GameState.ATTACK.width = 250
            GameState.ATTACK.height = 25
        end

        GameState.ATTACK.exists = true
        GameState.ATTACK.timer = 0
        GameState.ATTACK.collided = false
    end

    if GameState.ATTACK.exists == true then
        GameState.ATTACK.y = GameState.ATTACK.y + GameState.ATTACK.speed * dt
        if GameState.ATTACK.y > INITIAL_Y + 500 then
            GameState.ATTACK.exists = false
        end
    end

    CollideWithAttack = CollitionDetectionPlayer(GameState.ATTACK)

    if CollideWithAttack == true and GameState.ATTACK.collided == false then
        GameState.SCORE = GameState.SCORE - 1
        GameState.ATTACK.exists = false
        GameState.ATTACK.collided = true
        GameState.PLAYER.x = INITIAL_X + 250
        GameState.PLAYER.y = INITIAL_Y + 250
    end

    if GameState.PLAYER.animation.walk == true then
        GameState.PLAYER.animation.speed = GameState.PLAYER.animation.speed + dt

        if GameState.PLAYER.animation.speed > 0.2 then
            GameState.PLAYER.animation.speed = 0.1

            GameState.PLAYER.animation.frame = GameState.PLAYER.animation.frame + 1

            if GameState.PLAYER.animation.frame > 4 then
                GameState.PLAYER.animation.frame = 1
            end
        end
    end
end

function GameState:draw()
    -- Map
    love.graphics.rectangle(
        "line",
        INITIAL_X,
        INITIAL_Y,
        500,
        500
    )
    -- Player
    love.graphics.draw(GameState.PLAYER.sprite, GameState.PLAYER.quads[GameState.PLAYER.animation.frame], GameState.PLAYER.x, GameState.PLAYER.y, 0, 25 / GameState.PLAYER.quad_width, 25 / GameState.PLAYER.quad_height)
    -- Points
    if GameState.POINT.exists == true then
        love.graphics.draw(GameState.POINT.sprite, GameState.POINT.x, GameState.POINT.y, 0, 25 / GameState.POINT.sprite:getWidth(), 25 / GameState.POINT.sprite:getHeight())
    end
    -- Attack
    if GameState.ATTACK.exists == true then
        for i = 1, 8 do
            love.graphics.draw(BULLET_1.sprite, GameState.ATTACK.x + ((i - 1) * 30), GameState.ATTACK.y, 0, 25 / BULLET_1.sprite:getWidth(), 25 / BULLET_1.sprite:getHeight())
        end
    end
    -- Ouros movement
    for i = 1, GameState.SCORE do
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
            
            if i == GameState.SCORE then
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

function GameState:enter(message)
    print("Entrando a GameState. Mensaje:", message)
    -- Útil si vienes de un menú de pausa y necesitas reanudar
end

function GameState:exit(nextState)
    print("Saliendo de GameState hacia:", nextState.name or "un estado sin nombre")
end

GameState.name = "GameState"

return GameState