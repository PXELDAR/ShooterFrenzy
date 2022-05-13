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
    player.hitboxSize = 30

    myFont = love.graphics.newFont(30)

    zombies = {}
    bullets = {}

    gameState = 1
    maxTime = 2
    timer = maxTime

    controls = {}
    controls.up = "w"
    controls.down = "s"
    controls.left = "a"
    controls.right = "d"
    controls.space = "space"

end

-----------------------------------------------------------------------------------

function love.update(dt)
    if (gameState == 2) then
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

    for i,zombie in ipairs(zombies) do
        local zombieAngleToPlayer = angleBetween(player.x, player.y, zombie.x, zombie.y)
        zombie.x = zombie.x + (math.cos(zombieAngleToPlayer) * zombie.speed * dt)
        zombie.y = zombie.y + (math.sin(zombieAngleToPlayer) * zombie.speed * dt)

        local distanceToPlayer = distanceBetween(zombie.x, zombie.y, player.x, player.y)
        if(distanceToPlayer < player.hitboxSize) then
            for i,zombie in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1
                player.x = love.graphics.getWidth() / 2
                player.y = love.graphics.getHeight() / 2
            end
        end
    end

    for i,bullet in ipairs(bullets) do
        bullet.x = bullet.x + (math.cos(bullet.direction) * bullet.speed * dt)
        bullet.y = bullet.y + (math.sin(bullet.direction) * bullet.speed * dt)
    end

    for i,zombie in ipairs(zombies) do
       for j,bullet in ipairs(bullets) do
            if(distanceBetween(zombie.x, zombie.y, bullet.x, bullet.y) < zombie.hitboxSize) then
                zombie.dead = true
                bullet.dead = true
            end
       end
    end

    --#bullets = length, endingValue, each time = -1
    for i=#bullets, 1, -1 do 
        local bullet = bullets[i]
    
        if(bullet.x < 0 or bullet.y < 0 or bullet.x > love.graphics.getWidth() or bullet.y > love.graphics.getHeight()) then
            table.remove(bullets, i)
        end
    end

    --#zombies = length, endingValue, each time = -1
    for i=#zombies, 1, -1 do
        local zombie = zombies[i]
        if(zombie.dead == true) then
            table.remove(zombies, i)
        end
    end

    --#bullets = length, endingValue, each time = -1
    for i=#bullets, 1, -1 do
        local bullet = bullets[i]
        if(bullet.dead == true) then
            table.remove(bullets, i)
        end
    end


    if (gameState == 2) then
        timer = timer - dt
        if(timer  <= 0) then
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end
end

-----------------------------------------------------------------------------------

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    if (gameState == 1) then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end
    
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

    for i,bullet in ipairs(bullets) do
        local bulletOffsetX = sprites.bullet:getWidth() / 2
        local bulletOffsetY = sprites.bullet:getHeight() / 2
        love.graphics.draw(sprites.bullet, bullet.x, bullet.y, nil, 0.5, nil, bulletOffsetX, bulletOffsetY)
    end
end

-----------------------------------------------------------------------------------

function love.keypressed(key)
    if(key == controls.space) then
        spawnZombie()
    end
end

-----------------------------------------------------------------------------------

function love.mousepressed(x, y, button)
    if(button == 1 and gameState == 2) then
        spawnBullet();
    elseif (button == 1 and gameState == 1) then
        gameState = 2
        maxTime = 2
        timer = maxTime
    end
end

-----------------------------------------------------------------------------------

function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 100
    zombie.dead = false
    zombie.hitboxSize = 20

    local side = math.random(1,4)
    if (side == 1) then --Left
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif (side == 2) then --Right
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif (side == 3) then --Top
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif (side == 4) then --Bottom
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

-----------------------------------------------------------------------------------

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    local playerAngleToMouse = angleBetween(player.x, player.y, love.mouse.getX(), love.mouse.getY()) + math.pi --Invert
    bullet.direction = playerAngleToMouse
 
    table.insert(bullets, bullet)
end

-----------------------------------------------------------------------------------

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-----------------------------------------------------------------------------------

function angleBetween(x1, y1, x2, y2)
    return math.atan2(y1 - y2, x1 - x2)
end

-----------------------------------------------------------------------------------
