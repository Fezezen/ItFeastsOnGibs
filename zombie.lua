local zombie = {}
zombie.__index = zombie

local zombieSprites = {
  love.graphics.newImage("Sprites/zombie_0.png"),
  love.graphics.newImage("Sprites/zombie_1.png"),
  love.graphics.newImage("Sprites/zombie_2.png"),
  love.graphics.newImage("Sprites/zombie_3.png")
}

local slashSprite = love.graphics.newImage("Sprites/slash.png")
local diedSounds = {
  love.audio.newSource("Audio/killZombie1.wav","static"),
  love.audio.newSource("Audio/killZombie2.wav","static"),
  love.audio.newSource("Audio/killZombie3.wav","static"),
  love.audio.newSource("Audio/killZombie4.wav","static"),
}

function zombie.new(x,y)
  local self = setmetatable({},zombie)
  self.x = x
  self.y = y
  self.w = 12*3
  self.h = 18*3
  self.health = 20
  self.passed = 0
  self.delay = .3
  self.currentSprite = 1
  self.speed = math.random(30,100)
  table.insert(zombies,self)
  
  self.f = false
  self.died = false
  
  self.attacking = false
  self.lastAttack = 0
  
  self.range = 70
  
  self.bx = 0
end

local hurt = love.audio.newSource("Audio/hurt.wav","static")

local function realAttack(self)
  if self.died then return end
  local dis = math.sqrt((player.y-self.y)^2 + (player.x-self.x)^2)
  if dis < self.range+10 then
    player.health = math.max(player.health-1,0)
    hurt:play()
  end
  self.attacking = false
  self.lastAttack = time+2
end

function zombie:attack()
  self.attacking = true
  
  timer.new(.3,realAttack,self)
end

function zombie:move(dt)
  local angle = math.atan2(player.y-self.y,player.x-self.x)
  local dx,dy = math.cos(angle),math.sin(angle)
  local dis = math.sqrt((player.y-self.y)^2 + (player.x-self.x)^2)
  
  if dis > self.range then
    self.x = self.x + dx*self.speed*dt
    self.y = self.y + dy*self.speed*dt
  elseif self.lastAttack < time and not self.attacking then
    self:attack()
  end
    
  if dx < 0 then
    self.f = true
  else
    self.f = false
  end
  local s = math.sin(time*15)
  if s < 0 then s = 0 end
  self.bx = s*2
  
  self.passed = self.passed + dt
  if self.passed > self.delay then
    self.passed = 0
    self.currentSprite = self.currentSprite + 1
    if self.currentSprite > #zombieSprites then
      self.currentSprite = 1
    end
  end
end

function zombie:die()
  self.died = true 
  diedSounds[math.random(1,#diedSounds)]:play()
  for i = 1,6 do
    local angle = player.rot+math.rad(math.random(-20.1,20))
    local dx,dy = math.cos(angle),math.sin(angle)
    local speed = math.random(500,1000)
    if i > 5 then i = 5 end
    organ.new(self.x+self.w/2,self.y+self.h/2,dx*speed,dy*speed,i)
  end
  for i = 1,math.random(5,16) do
    local angle = player.rot+math.rad(math.random(-20.1,20))
    local dx,dy = math.cos(angle),math.sin(angle)
    local speed = math.random(100,1000)
    organ.new(self.x+self.w/2,self.y+self.h/2,dx*speed,dy*speed)
  end
  local h = math.random(1,6+math.floor(time/100))
  if h == 1 then
    local angle = player.rot+math.rad(math.random(-10.1,10))
    local dx,dy = math.cos(angle),math.sin(angle)
    local speed = math.random(100,500)
    organ.new(self.x+self.w/2,self.y+self.h/2,dx*speed,dy*speed,6)
  end
end

function zombie:update(dt)
  if self.health <= 0 then 
    if not self.died then
      self:die()
    end
    return true 
  end
  self:move(dt)
end

function zombie:draw()
  local ox = 0
  local s = 1
  if self.f then
    ox = 12
    s = -1
  end
  love.graphics.draw(zombieSprites[self.currentSprite],self.x,self.y+self.bx,0,s*3,3,ox)
  if self.attacking then
    local o = 10
    if s == -1 then o = 16 end
    love.graphics.draw(slashSprite,self.x+self.w/2,self.y+self.h/2,0,s*2,2,o)
  end
end

return zombie