local Attacks = require("resources.Attacks")
local Phrases = require("resources.Phrases")

function RandomAttack()
    local random = math.random(1, #Attacks)
    return Attacks[random]
end

function DebugHitbox(hitbox)
    -- Hitbox (líneas rojas)
    local r, g, b, a = love.graphics.getColor() -- Guardar color actual
    love.graphics.setColor(1, 0, 0, 1)          -- Color rojo
    love.graphics.rectangle("line", hitbox.x, hitbox.y, hitbox.width, hitbox.height)
    love.graphics.setColor(r, g, b, a)          -- Restaurar color original
end

local GameScene = {
    PLAYER = {
        x = 0,
        y = 0,
        width = 25,
        height = 25,
        speed = 220,
        sprite = love.graphics.newImage("assets/player.png"),
        sprite_width = 32,
        sprite_height = 8,
        quad_width = 8,
        quad_height = 8,
        quads = {},
        lives = 3,
        animation = {
            walk = false,
            frame = 1,
            speed = 0.1
        },
        hitbox = {
            x = 0,
            y = 0,
            width = 20,
            height = 20
        },
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
        type = RandomAttack().type,
        exists = false,
        collided = false,
        speed = 260,
        movement = "vertical",
        hitbox = {
            x = 0,
            y = 0,
            width = 0,
            height = 0
        },
        signal = {
            exists = false,
            x = 0,
            y = 0,
        }
    },
    SCORE = 0,
    PHRASE = {
        exists = false,
        phrase = "",
        timer = 0
    },
    HEART_POINT = {
        x = 0,
        y = 0,
        width = 25,
        height = 25,
        exists = false,
        timer = 0,
        collided = false,
        sprite = love.graphics.newImage("assets/heart-point.png"),
        sprite_width = 35,
        sprite_height = 7,
        quad_width = 7,
        quad_height = 7,
        quads = {},
        animation = {
            frame = 1,
            speed = 0.1
        }
    }
}

function CollitionDetectionPlayer(collider)
    if GameScene.PLAYER.hitbox.x < collider.x + collider.width and
        GameScene.PLAYER.hitbox.x + GameScene.PLAYER.hitbox.width > collider.x and
        GameScene.PLAYER.hitbox.y < collider.y + collider.height and
        GameScene.PLAYER.hitbox.y + GameScene.PLAYER.hitbox.height > collider.y then
        return true
    end
    return false
end

function CreateAnimation(frames, quad_width, quad_height, sprite_width, sprite_height)
    local quads = {}
    for i = 1, frames do
        quads[i] = love.graphics.newQuad(
            (i - 1) * quad_width,
            0,
            quad_width,
            quad_height,
            sprite_width, sprite_height)
    end
    return quads
end

function PlayAnimation(animation, dt)
    animation.speed = animation.speed + dt

    if animation.speed > 0.2 then
        animation.speed = 0.1

        animation.frame = animation.frame + 1

        if animation.frame > 4 then
            animation.frame = 1
        end
    end
end

function GameScene:load()
    -- Ouros
    OurosHead = love.graphics.newImage("assets/ouros-head-simple.png")
    OurosBody = love.graphics.newImage("assets/ouros-body-simple.png")
    OurosTail = love.graphics.newImage("assets/ouros-tail-simple.png")
    -- Heart
    Heart = love.graphics.newImage("assets/heart.png")
    -- Player
    GameScene.PLAYER.hitbox.x = INITIAL_X + 250 + 2.5
    GameScene.PLAYER.hitbox.y = INITIAL_Y + 250 + 2.5
    GameScene.PLAYER.x = INITIAL_X + 250
    GameScene.PLAYER.y = INITIAL_Y + 250
    -- Signal
    Signal = love.graphics.newImage("assets/signal.png")

    GameScene.PLAYER.quads = CreateAnimation(4, GameScene.PLAYER.quad_width, GameScene.PLAYER.quad_height,
        GameScene.PLAYER.sprite_width, GameScene.PLAYER.sprite_height)

    GameScene.HEART_POINT.quads = CreateAnimation(5, GameScene.HEART_POINT.quad_width, GameScene.HEART_POINT.quad_height,
        GameScene.HEART_POINT.sprite_width, GameScene.HEART_POINT.sprite_height)

    BULLET_1 = {
        width = 1,
        height = 1,
        sprite = love.graphics.newImage("assets/bullet-1.png"),
        type = 1,
    }
end

function GameScene:update(dt)
    if GameScene.PLAYER.lives == 0 then
        local GameOverScene = require("scenes.GameOverScene")
        require("SceneManager"):changeState(GameOverScene)
    end

    if GameScene.SCORE > 0 then
        for i = 1, #Phrases do
            if GameScene.SCORE == Phrases[i].points then
                GameScene.PHRASE.phrase = Phrases[i].phrase
                GameScene.PHRASE.exists = true
                GameScene.PHRASE.timer = 0
                break
            end
        end
    end

    if GameScene.PHRASE.exists == true then
        GameScene.PHRASE.timer = GameScene.PHRASE.timer + 1
        if GameScene.PHRASE.timer > 120 then
            GameScene.PHRASE.exists = false
        end
    end

    if GameScene.POINT.exists == false then
        GameScene.POINT.timer = GameScene.POINT.timer + 1
    end

    if GameScene.ATTACK.exists == false then
        GameScene.ATTACK.timer = GameScene.ATTACK.timer + 1
    end

    -- Reset animation state at the beginning of each frame
    GameScene.PLAYER.animation.walk = false

    if love.keyboard.isDown("up") and GameScene.PLAYER.y > INITIAL_Y then
        GameScene.PLAYER.hitbox.y = GameScene.PLAYER.hitbox.y - GameScene.PLAYER.speed * dt
        GameScene.PLAYER.y = GameScene.PLAYER.y - GameScene.PLAYER.speed * dt
        GameScene.PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("down") and GameScene.PLAYER.y < INITIAL_Y + (500 - GameScene.PLAYER.height) then
        GameScene.PLAYER.hitbox.y = GameScene.PLAYER.hitbox.y + GameScene.PLAYER.speed * dt
        GameScene.PLAYER.y = GameScene.PLAYER.y + GameScene.PLAYER.speed * dt
        GameScene.PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("left") and GameScene.PLAYER.x > INITIAL_X then
        GameScene.PLAYER.hitbox.x = GameScene.PLAYER.hitbox.x - GameScene.PLAYER.speed * dt
        GameScene.PLAYER.x = GameScene.PLAYER.x - GameScene.PLAYER.speed * dt
        GameScene.PLAYER.animation.walk = true
    end

    if love.keyboard.isDown("right") and GameScene.PLAYER.x < INITIAL_X + (500 - GameScene.PLAYER.width) then
        GameScene.PLAYER.hitbox.x = GameScene.PLAYER.hitbox.x + GameScene.PLAYER.speed * dt
        GameScene.PLAYER.x = GameScene.PLAYER.x + GameScene.PLAYER.speed * dt
        GameScene.PLAYER.animation.walk = true
    end

    -- Reset animation frame to 1 when not walking
    if GameScene.PLAYER.animation.walk == false then
        GameScene.PLAYER.animation.frame = 1
        GameScene.PLAYER.animation.speed = 0.1
    end

    if GameScene.POINT.exists == false and GameScene.POINT.timer > 20 then
        GameScene.POINT.x = math.random(INITIAL_X, INITIAL_X + 500 - GameScene.POINT.width)
        GameScene.POINT.y = math.random(INITIAL_Y, INITIAL_Y + 500 - GameScene.POINT.height)
        GameScene.POINT.exists = true
        GameScene.POINT.timer = 0
        GameScene.POINT.collided = false
    end

    CollideWithPoint = CollitionDetectionPlayer(GameScene.POINT)

    if CollideWithPoint == true and GameScene.POINT.collided == false then
        GameScene.SCORE = GameScene.SCORE + 1
        GameScene.POINT.exists = false
        GameScene.POINT.collided = true
    end

    if GameScene.SCORE > 0 and GameScene.SCORE % 21 == 0 and GameScene.HEART_POINT.exists == false then
        GameScene.HEART_POINT.exists = true
        GameScene.HEART_POINT.x = math.random(INITIAL_X, INITIAL_X + 500 - GameScene.HEART_POINT.width)
        GameScene.HEART_POINT.y = math.random(INITIAL_Y, INITIAL_Y + 500 - GameScene.HEART_POINT.height)
        GameScene.HEART_POINT.timer = 0
        GameScene.HEART_POINT.collided = false
    end

    if GameScene.HEART_POINT.exists == false then
        GameScene.HEART_POINT.timer = GameScene.HEART_POINT.timer + 1
        if GameScene.HEART_POINT.timer > 120 then
            GameScene.HEART_POINT.exists = false
        end
    end

    CollideWithHeartPoint = CollitionDetectionPlayer(GameScene.HEART_POINT)

    if CollideWithHeartPoint == true and GameScene.HEART_POINT.collided == false then
        GameScene.PLAYER.lives = GameScene.PLAYER.lives + 1
        GameScene.HEART_POINT.exists = false
        GameScene.HEART_POINT.collided = true
    end

    if GameScene.ATTACK.exists == false and GameScene.ATTACK.timer > 45 and GameScene.ATTACK.signal.exists == false then
        for i = 1, #Attacks do
            if Attacks[i].type == GameScene.ATTACK.type then
                GameScene.ATTACK.signal.exists = true
                GameScene.ATTACK.signal.x = Attacks[i].x
                GameScene.ATTACK.signal.y = Attacks[i].y
                GameScene.ATTACK.x = Attacks[i].x
                GameScene.ATTACK.y = Attacks[i].y
                GameScene.ATTACK.width = Attacks[i].width
                GameScene.ATTACK.height = Attacks[i].height
                GameScene.ATTACK.movement = Attacks[i].movement
                GameScene.ATTACK.hitbox.x = Attacks[i].x + 5
                GameScene.ATTACK.hitbox.y = Attacks[i].y + 5
                GameScene.ATTACK.hitbox.width = Attacks[i].width - 10
                GameScene.ATTACK.hitbox.height = Attacks[i].height - 10
                break
            end
        end
    end

    if GameScene.ATTACK.signal.exists == true and GameScene.ATTACK.timer > 75 then
        GameScene.ATTACK.signal.exists = false
    end

    if GameScene.ATTACK.exists == false and GameScene.ATTACK.timer > 80 then
        GameScene.ATTACK.exists = true
        GameScene.ATTACK.timer = 0
        GameScene.ATTACK.collided = false
    end

    if GameScene.ATTACK.exists == true then
        if GameScene.ATTACK.movement == "vertical" then
            GameScene.ATTACK.hitbox.y = GameScene.ATTACK.hitbox.y + GameScene.ATTACK.speed * dt
            GameScene.ATTACK.y = GameScene.ATTACK.y + GameScene.ATTACK.speed * dt
            if GameScene.ATTACK.y > INITIAL_Y + 500 then
                GameScene.ATTACK.exists = false
                GameScene.ATTACK.type = RandomAttack().type
            end
        elseif GameScene.ATTACK.movement == "horizontal" then
            GameScene.ATTACK.hitbox.x = GameScene.ATTACK.hitbox.x + GameScene.ATTACK.speed * dt
            GameScene.ATTACK.x = GameScene.ATTACK.x + GameScene.ATTACK.speed * dt
            if GameScene.ATTACK.x > INITIAL_X + 500 then
                GameScene.ATTACK.exists = false
                GameScene.ATTACK.type = RandomAttack().type
            end
        elseif GameScene.ATTACK.movement == "vertical-reverse" then
            GameScene.ATTACK.hitbox.y = GameScene.ATTACK.hitbox.y - GameScene.ATTACK.speed * dt
            GameScene.ATTACK.y = GameScene.ATTACK.y - GameScene.ATTACK.speed * dt
            if GameScene.ATTACK.y < INITIAL_Y then
                GameScene.ATTACK.exists = false
                GameScene.ATTACK.type = RandomAttack().type
            end
        elseif GameScene.ATTACK.movement == "horizontal-reverse" then
            GameScene.ATTACK.hitbox.x = GameScene.ATTACK.hitbox.x - GameScene.ATTACK.speed * dt
            GameScene.ATTACK.x = GameScene.ATTACK.x - GameScene.ATTACK.speed * dt
            if GameScene.ATTACK.x < INITIAL_X then
                GameScene.ATTACK.exists = false
                GameScene.ATTACK.type = RandomAttack().type
            end
        end
    end

    CollideWithAttack = CollitionDetectionPlayer(GameScene.ATTACK.hitbox)

    if CollideWithAttack == true and GameScene.ATTACK.collided == false then
        if GameScene.PLAYER.lives > 0 then
            GameScene.PLAYER.lives = GameScene.PLAYER.lives - 1
        end
        GameScene.ATTACK.exists = false
        GameScene.ATTACK.collided = true
        GameScene.PLAYER.x = INITIAL_X + 250
        GameScene.PLAYER.y = INITIAL_Y + 250
        GameScene.PLAYER.hitbox.x = INITIAL_X + 250 + 2.5
        GameScene.PLAYER.hitbox.y = INITIAL_Y + 250 + 2.5
        GameScene.ATTACK.type = RandomAttack().type
    end

    if GameScene.PLAYER.animation.walk == true then
        PlayAnimation(GameScene.PLAYER.animation, dt)
    end

    if GameScene.HEART_POINT.exists == true then
        PlayAnimation(GameScene.HEART_POINT.animation, dt)
    end
end

function GameScene:draw()
    -- Map
    love.graphics.rectangle(
        "line",
        INITIAL_X,
        INITIAL_Y,
        500,
        500
    )
    -- Phrase
    if GameScene.PHRASE.exists == true then
        love.graphics.print(GameScene.PHRASE.phrase, INITIAL_X, INITIAL_Y + 500 + 50, 0, 1, 1)
    end
    -- Player
    love.graphics.draw(GameScene.PLAYER.sprite, GameScene.PLAYER.quads[GameScene.PLAYER.animation.frame],
        GameScene.PLAYER.x, GameScene.PLAYER.y, 0, 25 / GameScene.PLAYER.quad_width, 25 / GameScene.PLAYER.quad_height)
    -- Lives
    for i = 1, GameScene.PLAYER.lives do
        love.graphics.draw(Heart, INITIAL_X - 70, INITIAL_Y + ((i - 1) * 25), 0, 16 / Heart:getWidth(),
            16 / Heart:getHeight())
    end
    -- Points
    if GameScene.POINT.exists == true then
        love.graphics.draw(GameScene.POINT.sprite, GameScene.POINT.x, GameScene.POINT.y, 0,
            25 / GameScene.POINT.sprite:getWidth(), 25 / GameScene.POINT.sprite:getHeight())
    end
    -- Heart point
    if GameScene.HEART_POINT.exists == true then
        love.graphics.draw(GameScene.HEART_POINT.sprite, GameScene.HEART_POINT.quads[GameScene.HEART_POINT.animation.frame],
            GameScene.HEART_POINT.x, GameScene.HEART_POINT.y, 0,
            25 / GameScene.HEART_POINT.quad_width, 25 / GameScene.HEART_POINT.quad_height)
    end
    -- Attack
    if GameScene.ATTACK.signal.exists == true then
        if GameScene.ATTACK.movement == "vertical" then
            love.graphics.draw(
                Signal,
                GameScene.ATTACK.signal.x + GameScene.ATTACK.width / 2,
                GameScene.ATTACK.signal.y,
                0,
                25 / Signal:getWidth(),
                25 / Signal:getHeight()
            )
        elseif GameScene.ATTACK.movement == "horizontal" then
            love.graphics.draw(
                Signal,
                GameScene.ATTACK.signal.x,
                GameScene.ATTACK.signal.y + GameScene.ATTACK.height / 2,
                0,
                25 / Signal:getWidth(),
                25 / Signal:getHeight()
            )
        elseif GameScene.ATTACK.movement == "vertical-reverse" then
            love.graphics.draw(
                Signal,
                GameScene.ATTACK.signal.x + GameScene.ATTACK.width / 2,
                GameScene.ATTACK.signal.y - 25,
                0,
                25 / Signal:getWidth(),
                25 / Signal:getHeight()
            )
        elseif GameScene.ATTACK.movement == "horizontal-reverse" then
            love.graphics.draw(
                Signal,
                GameScene.ATTACK.signal.x - 25,
                GameScene.ATTACK.signal.y + GameScene.ATTACK.height / 2,
                0,
                25 / Signal:getWidth(),
                25 / Signal:getHeight()
            )
        end
    end

    if GameScene.ATTACK.exists == true then
        local originX = BULLET_1.sprite:getWidth() / 2
        local originY = BULLET_1.sprite:getHeight() / 2
        local positionX = GameScene.ATTACK.x + originX
        local positionY = GameScene.ATTACK.y + originY
        for i = 1, 10 do
            if GameScene.ATTACK.movement == "vertical" then
                love.graphics.draw(
                    BULLET_1.sprite,
                    GameScene.ATTACK.x + ((i - 1) * 25),
                    GameScene.ATTACK.y,
                    0,
                    1,
                    1
                )
            elseif GameScene.ATTACK.movement == "horizontal" then
                love.graphics.draw(
                    BULLET_1.sprite,
                    positionX,
                    positionY + ((i - 1) * 25),
                    math.rad(270),
                    1,
                    1,
                    originX,
                    originY
                )
            elseif GameScene.ATTACK.movement == "vertical-reverse" then
                love.graphics.draw(
                    BULLET_1.sprite,
                    positionX + ((i - 1) * 25),
                    positionY,
                    math.rad(180),
                    1,
                    1,
                    originX,
                    originY
                )
            elseif GameScene.ATTACK.movement == "horizontal-reverse" then
                love.graphics.draw(
                    BULLET_1.sprite,
                    positionX,
                    positionY + ((i - 1) * 25),
                    math.rad(90),
                    1,
                    1,
                    originX,
                    originY
                )
            end
        end
        --DebugHitbox(GameScene.ATTACK.hitbox)
    end
    --DebugHitbox(GameScene.PLAYER.hitbox)
    -- Ouros movement
    for i = 1, GameScene.SCORE do
        local squaresPerSide = math.floor(500 / 25) + 1 -- 20 squares per side (500/25)
        local totalSquares = squaresPerSide * 4         -- 80 squares total around the rectangle

        if i <= totalSquares then
            local side = math.floor((i - 1) / squaresPerSide) -- 0=top, 1=right, 2=bottom, 3=left
            local position = (i - 1) % squaresPerSide         -- Position on current side

            local x, y
            if side == 0 then -- Top side
                x = INITIAL_X + (position * 25)
                y = INITIAL_Y - 25
            elseif side == 1 then -- Right side
                x = INITIAL_X + 500
                y = INITIAL_Y + (position * 25)
            elseif side == 2 then -- Bottom side
                x = INITIAL_X + 500 - ((position + 1) * 25)
                y = INITIAL_Y + 500
            else -- Left side
                x = INITIAL_X - 25
                y = INITIAL_Y + 500 - ((position + 1) * 25)
            end

            if i == GameScene.SCORE then
                if side == 1 then
                    love.graphics.draw(OurosHead, x + 25, y, math.rad(90), 25 / OurosHead:getWidth(),
                        25 / OurosHead:getHeight())
                elseif side == 2 then
                    love.graphics.draw(OurosHead, x + 25, y + 25, math.rad(180), 25 / OurosHead:getWidth(),
                        25 / OurosHead:getHeight())
                elseif side == 3 then
                    love.graphics.draw(OurosHead, x, y + 25, math.rad(270), 25 / OurosHead:getWidth(),
                        25 / OurosHead:getHeight())
                else
                    love.graphics.draw(OurosHead, x, y, 0, 25 / OurosHead:getWidth(), 25 / OurosHead:getHeight())
                end
            elseif i == 1 then
                love.graphics.draw(OurosTail, x, y, 0, 25 / OurosTail:getWidth(), 25 / OurosTail:getHeight())
            else
                if side == 1 then
                    love.graphics.draw(OurosBody, x + 25, y, math.rad(90), 25 / OurosBody:getWidth(),
                        25 / OurosBody:getHeight())
                elseif side == 2 then
                    love.graphics.draw(OurosBody, x + 25, y + 25, math.rad(180), 25 / OurosBody:getWidth(),
                        25 / OurosBody:getHeight())
                elseif side == 3 then
                    love.graphics.draw(OurosBody, x, y + 25, math.rad(270), 25 / OurosBody:getWidth(),
                        25 / OurosBody:getHeight())
                else
                    love.graphics.draw(OurosBody, x, y, 0, 25 / OurosBody:getWidth(), 25 / OurosBody:getHeight())
                end
            end
        end
    end
end

function GameScene:enter(message)
    print("Entrando a GameScene. Mensaje:", message)
    -- Útil si vienes de un menú de pausa y necesitas reanudar
end

function GameScene:exit(nextState)
    if nextState.name == "GameOverScene" then
        GameScene.PLAYER.lives = 3
        GameScene.SCORE = 0
        GameScene.ATTACK.exists = false
        GameScene.POINT.exists = false
        GameScene.POINT.collided = false
        GameScene.POINT.timer = 0
        GameScene.ATTACK.timer = 0
        GameScene.ATTACK.type = RandomAttack().type
        GameScene.ATTACK.collided = false
        GameScene.PHRASE.exists = false
        GameScene.PHRASE.phrase = ""
        GameScene.PHRASE.timer = 0
    end
    print("Saliendo de GameScene hacia:", nextState.name or "un estado sin nombre")
end

GameScene.name = "GameScene"

return GameScene
