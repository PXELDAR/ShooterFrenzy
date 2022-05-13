-----------------------------------------------------------------------------------

function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage("assets/background.png")
    sprites.bullet = love.graphics.newImage("assets/bullet.png")
    sprites.player = love.graphics.newImage("assets/player.png")
    sprites.zombie = love.graphics.newImage("assets/zombie.png")

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 200

    zombies = {}

    controls = {}
    controls.up = "w"
    controls.down = "s"
    controls.left = "a"
    controls.right = "d"
    controls.space = "space"

end

-----------------------------------------------------------------------------------

function love.update(dt)
    if (love.keyboard.isDown(controls.up)) then
        player.y = player.y - player.speed * dt
    end
    if (love.keyboard.isDown(controls.down)) then
        player.y = player.y + player.speed * dt
    end
    if (love.keyboard.isDown(controls.left)) then
        player.x = player.x - player.speed * dt
    end
    if (love.keyboard.isDown(controls.right)) then
        player.x = player.x + player.speed * dt
    end
end

-----------------------------------------------------------------------------------

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
    
    local playerRotationValue = angleBetween(player.x, player.y, love.mouse.getX(), love.mouse.getY()) + math.pi --Invert
    local playerOffsetX = sprites.player:getWidth() / 2
    local playerOffsetY = sprites.player:getHeight() / 2
    love.graphics.draw(sprites.player, player.x, player.y, playerRotationValue, nil, nil, playerOffsetX, playerOffsetY)

    for i,zombie in ipairs(zombies) do
        local zombieRotationValue = angleBetween(player.x, player.y, zombie.x, zombie.y)
        local zombieOffsetX = sprites.zombie:getWidth() / 2
        local zombieOffsetY = sprites.zombie:getHeight() / 2
        love.graphics.draw(sprites.zombie, zombie.x, zombie.y, zombieRotationValue, nil, nil, zombieOffsetX, zombieOffsetY)
    end
end

-----------------------------------------------------------------------------------

function love.keypressed(key)
    if(key == controls.space) then
        spawnZombie()
    end
end

-----------------------------------------------------------------------------------

function angleBetween(x1, y1, x2, y2)
    return math.atan2(y1 - y2, x1 - x2)
end

-----------------------------------------------------------------------------------

function spawnZombie()
    local zombie = {}
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = math.random(0, love.graphics.getHeight())
    zombie.speed = 100

    table.insert(zombies, zombie)
end

-----------------------------------------------------------------------------------
