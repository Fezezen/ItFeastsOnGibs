player = {}

player.sprites = {
    love.graphics.newImage("Sprites/sprite_0.png"),
    love.graphics.newImage("Sprites/sprite_1.png"),
    love.graphics.newImage("Sprites/sprite_2.png"),
    love.graphics.newImage("Sprites/sprite_3.png")
}

player.lifeSprites = {
  love.graphics.newImage("Sprites/Hearts/life0.png"),
  love.graphics.newImage("Sprites/Hearts/life1.png"),
  love.graphics.newImage("Sprites/Hearts/life2.png"),
  love.graphics.newImage("Sprites/Hearts/life3.png"),
}

local gunshot = love.audio.newSource("Audio/gunshot.wav","static")
local heal = love.audio.newSource("Audio/heal.wav","static")

function player.load()
  player.x = 200
  player.y = h/2
  player.w = 16*3
  player.h = 20*3
  player.speed = 200
  
  player.health = 3
  
  player.currentSprite = 1
  player.delay = 0.1
  player.passed = 0
  player.facing = 1
  
  player.bx = 0
  
  player.shotgunSprite = love.graphics.newImage("Sprites/shotgun.png")
  player.shotgunFireSprite = love.graphics.newImage("Sprites/shotgun_fire.png")
  player.rot = 0
  player.shotgunOX = player.w/2
  player.shotgunOY = player.h/2 + 10
  player.shotgunFireRate = .5
  player.shotgunRecoil = 10
  player.shotgunBullets = 5
  
  player.recoil = 0
  
  player.fireSprite = false  
  player.firing = false
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function movement(dt)
  local dx,dy = 0,0
  if love.keyboard.isDown("w") then
    dy = -1
  elseif love.keyboard.isDown("s") then
    dy = 1
  end
  if love.keyboard.isDown("d") then
    dx = 1
  elseif love.keyboard.isDown("a") then
    dx = -1
  end
  
  local length = math.sqrt(dy * dy + dx * dx)
  if dx ~= 0 then
    player.facing = dx
    dx = dx/length
  end
  if dy ~= 0 then
    dy = dy/length
  end
  player.x = player.x + dx*player.speed*dt
  player.y = player.y + dy*player.speed*dt
  if player.x < wallStart then player.x = wallStart
  elseif player.x > w-player.w then player.x = w-player.w end
  if player.y < 0 then player.y = 0 
  elseif player.y > h-player.h then player.y = h-player.h end
  
  if dx ~= 0 or dy ~= 0 then
    player.passed = player.passed + dt
    if player.passed > player.delay then
      player.passed = 0
      player.currentSprite = player.currentSprite + 1
      if player.currentSprite > #player.sprites then
        player.currentSprite = 1
      end
    end
    
    local s = math.sin(time*20)
    if s < 0 then s = 0 end
    player.bx = s*2
  else
    player.currentSprite = 1
    player.bx = 0
  end
end

local function unfireCallback()
  player.firing = false
end

local function unfireSpriteCallback()
  player.fireSprite = false
end

function player.mousepressed(x,y,b)
  if b == 1 and not player.firing then
    player.fireSprite = true
    player.firing = true
    timer.new(player.shotgunFireRate,unfireCallback)
    timer.new(.1,unfireSpriteCallback)
    player.recoil = player.shotgunRecoil
    
    gunshot:play()
    
    local angle = math.atan2(y-(player.y+player.shotgunOY),x-(player.x+player.shotgunOX))
    for i = 1,player.shotgunBullets do
      local a = angle+math.rad(math.random()*10)
      local dx,dy = math.cos(a),math.sin(a)
      bullet.new(player.x+player.shotgunOX,player.y+player.shotgunOY,dx*700,dy*700)
    end
  end
end

function player.update(dt)
  movement(dt)
  
  local mx,my = love.mouse.getPosition()
  player.rot = math.atan2(my-(player.y+player.shotgunOY),mx-(player.x+player.shotgunOX))
  player.recoil = lerp(player.recoil,0,dt*10)
  
  for i,v in pairs(organs) do
    if not v.stick and v.heart and player.health < 3 then
      local px = player.x + player.w/2
      local py = player.y + player.h/2
      local dis = math.sqrt(
          (px-v.x)^2 +
          (py-v.y)^2
      )
      if dis < 40 then
        player.health = player.health + 1
        heal:play()
        table.remove(organs,i)
      end
    end
  end
end

function player.draw()
  local ox = 0
  if player.facing == -1 then
    ox = 16
  end
  love.graphics.draw(player.sprites[player.currentSprite],player.x,player.y+player.bx,0,3*player.facing,3,ox)
  
  local r = math.deg(player.rot)
  local s = 1
  if r < -90 or r > 90 then
    s = -1
  end
  
  local dx,dy = math.cos(player.rot),math.sin(player.rot)
  if not player.fireSprite then
    love.graphics.draw(player.shotgunSprite,player.x+player.shotgunOX - (dx*player.recoil),player.y+player.shotgunOY - (dy*player.recoil),player.rot,2,s*2,20,5)
  else
    love.graphics.draw(player.shotgunFireSprite,player.x+player.shotgunOX - (dx*player.recoil),player.y+player.shotgunOY - (dy*player.recoil),player.rot,2,s*2,20,5)
  end
  
  love.graphics.draw(player.lifeSprites[player.health+1],w-100,0,0,3,3)
end