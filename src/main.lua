-----------------------------------------------------------------------------------

function love.load()
    math.randomseed(os.time())

    _sprites = {}
    _sprites.background = love.graphics.newImage("assets/background.png")
    _sprites.bullet = love.graphics.newImage("assets/bullet.png")
    _sprites.player = love.graphics.newImage("assets/player.png")
    _sprites.zombie = love.graphics.newImage("assets/zombie.png")

    _player = {}
    _player.x = love.graphics.getWidth() / 2
    _player.y = love.graphics.getHeight() / 2
    _player.speed = 200
    _player.hitboxSize = 30

    _font = love.graphics.newFont(30)

    _zombies = {}
    _bullets = {}

    _gameState = 1
    _score = 0
    _zombieSpawnTimeMultiplier = 0.95
    _zombieSpawnTime = 2
    _spawnTimer = _zombieSpawnTime

    _controls = {}
    _controls.up = "w"
    _controls.down = "s"
    _controls.left = "a"
    _controls.right = "d"
    _controls.space = "space"

end

-----------------------------------------------------------------------------------

function love.update(dt)

    playerMovement(dt)
    zombieMovement(dt)
    bulletMovement(dt)

    checkBulletCollision()
    cleanOffscreenBullets()
    
    checkDeadZombies()
    checkDeadBullets()

    if(_gameState == 2) then
        spawnZombieOnRuntime(dt)
    end
end

-----------------------------------------------------------------------------------

function love.draw()
    drawBackGround()
    drawUserInterface()
    drawPlayer()
    drawZombies()
    drawBullets()
end

-----------------------------------------------------------------------------------

function playerMovement(dt)
    if (_gameState == 2) then
        if (love.keyboard.isDown(_controls.up) and _player.y > 0) then
            _player.y = _player.y - _player.speed * dt
        end
        
        if (love.keyboard.isDown(_controls.down) and _player.y < love.graphics.getHeight()) then
            _player.y = _player.y + _player.speed * dt
        end
        
        if (love.keyboard.isDown(_controls.left) and _player.x > 0) then
            _player.x = _player.x - _player.speed * dt
        end
        
        if (love.keyboard.isDown(_controls.right) and _player.x < love.graphics.getWidth()) then
            _player.x = _player.x + _player.speed * dt
        end
    end
end

-----------------------------------------------------------------------------------

function zombieMovement(dt)
    for i,zombie in ipairs(_zombies) do
        local zombieAngleToPlayer = angleBetween(_player.x, _player.y, zombie.x, zombie.y)
        zombie.x = zombie.x + (math.cos(zombieAngleToPlayer) * zombie.speed * dt)
        zombie.y = zombie.y + (math.sin(zombieAngleToPlayer) * zombie.speed * dt)

        local distanceToPlayer = distanceBetween(zombie.x, zombie.y, _player.x, _player.y)
        if(distanceToPlayer < _player.hitboxSize) then
            onZombieOverlapPlayer()
        end
    end
end

-----------------------------------------------------------------------------------

function bulletMovement(dt)
    for i,bullet in ipairs(_bullets) do
        bullet.x = bullet.x + (math.cos(bullet.direction) * bullet.speed * dt)
        bullet.y = bullet.y + (math.sin(bullet.direction) * bullet.speed * dt)
    end
end

-----------------------------------------------------------------------------------

function onZombieOverlapPlayer()
    for i,zombie in ipairs(_zombies) do
        _zombies[i] = nil
        _gameState = 1
        _player.x = love.graphics.getWidth() / 2
        _player.y = love.graphics.getHeight() / 2
    end
end

-----------------------------------------------------------------------------------

function checkBulletCollision()
    for i,zombie in ipairs(_zombies) do
        for j,bullet in ipairs(_bullets) do
             if(distanceBetween(zombie.x, zombie.y, bullet.x, bullet.y) < zombie.hitboxSize) then
                zombie.dead = true
                bullet.dead = true
                _score = _score + 1
             end
        end
     end
end

-----------------------------------------------------------------------------------

function cleanOffscreenBullets()
    --#_bullets = length, endingValue, each time = -1
    for i=#_bullets, 1, -1 do 
        local bullet = _bullets[i]
    
        if(bullet.x < 0 or bullet.y < 0 or bullet.x > love.graphics.getWidth() or bullet.y > love.graphics.getHeight()) then
            table.remove(_bullets, i)
        end
    end
end

-----------------------------------------------------------------------------------

function checkDeadZombies()
    --#_zombies = length, endingValue, each time = -1
    for i=#_zombies, 1, -1 do
        local zombie = _zombies[i]
        if(zombie.dead == true) then
            table.remove(_zombies, i)
        end
    end
end

-----------------------------------------------------------------------------------

function checkDeadBullets()
    --#_bullets = length, endingValue, each time = -1
    for i=#_bullets, 1, -1 do
        local bullet = _bullets[i]
        if(bullet.dead == true) then
            table.remove(_bullets, i)
        end
    end
end

-----------------------------------------------------------------------------------

function spawnZombieOnRuntime(dt)
    _spawnTimer = _spawnTimer - dt
    if(_spawnTimer  <= 0) then
        spawnZombie()
        _zombieSpawnTime = _zombieSpawnTimeMultiplier * _zombieSpawnTime
        _spawnTimer = _zombieSpawnTime
    end
end

-----------------------------------------------------------------------------------

function drawBackGround()
    love.graphics.draw(_sprites.background, 0, 0)
end

-----------------------------------------------------------------------------------

function drawUserInterface()
    if (_gameState == 1) then
        love.graphics.setFont(_font)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end

    love.graphics.printf("Score: " .. _score, 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")
end

-----------------------------------------------------------------------------------

function drawPlayer()
    local playerRotationValue = angleBetween(_player.x, _player.y, love.mouse.getX(), love.mouse.getY()) + math.pi --Invert
    local playerOffsetX = _sprites.player:getWidth() / 2
    local playerOffsetY = _sprites.player:getHeight() / 2
    love.graphics.draw(_sprites.player, _player.x, _player.y, playerRotationValue, nil, nil, playerOffsetX, playerOffsetY)
end

-----------------------------------------------------------------------------------

function drawZombies()
    for i,zombie in ipairs(_zombies) do
        local zombieRotationValue = angleBetween(_player.x, _player.y, zombie.x, zombie.y)
        local zombieOffsetX = _sprites.zombie:getWidth() / 2
        local zombieOffsetY = _sprites.zombie:getHeight() / 2
        love.graphics.draw(_sprites.zombie, zombie.x, zombie.y, zombieRotationValue, nil, nil, zombieOffsetX, zombieOffsetY)
    end
end

-----------------------------------------------------------------------------------

function drawBullets()
    for i,bullet in ipairs(_bullets) do
        local bulletOffsetX = _sprites.bullet:getWidth() / 2
        local bulletOffsetY = _sprites.bullet:getHeight() / 2
        love.graphics.draw(_sprites.bullet, bullet.x, bullet.y, nil, 0.5, nil, bulletOffsetX, bulletOffsetY)
    end
end

-----------------------------------------------------------------------------------

function love.keypressed(key)
    if(key == _controls.space) then
        spawnZombie()
    end
end

-----------------------------------------------------------------------------------

function love.mousepressed(x, y, button)
    if(button == 1 and _gameState == 2) then
        spawnBullet();
    elseif (button == 1 and _gameState == 1) then
        _gameState = 2
        _zombieSpawnTime = 2
        _spawnTimer = _zombieSpawnTime
        _score = 0
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

    table.insert(_zombies, zombie)
end

-----------------------------------------------------------------------------------

function spawnBullet()
    local bullet = {}
    bullet.x = _player.x
    bullet.y = _player.y
    bullet.speed = 500
    bullet.dead = false
    local playerAngleToMouse = angleBetween(_player.x, _player.y, love.mouse.getX(), love.mouse.getY()) + math.pi --Invert
    bullet.direction = playerAngleToMouse
 
    table.insert(_bullets, bullet)
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