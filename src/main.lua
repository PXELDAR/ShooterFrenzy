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

    controls = {}
    controls.up = "w"
    controls.down = "s"
    controls.left = "a"
    controls.right = "d"

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
    love.graphics.draw(sprites.player, player.x, player.y)
end

-----------------------------------------------------------------------------------