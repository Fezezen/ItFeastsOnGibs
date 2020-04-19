local organ = {}
organ.__index = organ

local organSprites = {
 love.graphics.newImage("Sprites/Organs/brain.png"),
 love.graphics.newImage("Sprites/Organs/head.png"),
 love.graphics.newImage("Sprites/Organs/kidney.png"),
 love.graphics.newImage("Sprites/Organs/liver.png"),
 love.graphics.newImage("Sprites/Organs/leg.png"),
 love.graphics.newImage("Sprites/Organs/heart.png"),
}

local blood = {
  love.graphics.newImage("Sprites/Blood/blood1.png"),
  love.graphics.newImage("Sprites/Blood/blood2.png"),
  love.graphics.newImage("Sprites/Blood/blood3.png"),
}

function organ.new(x,y,dx,dy,t)
  local self = setmetatable({},organ)
  self.x = x
  self.y = y
  
  self.z = 0
  self.xvel = dx
  self.yvel = dy
  self.zvel = math.random(50,100.1)
  self.r = math.rad(math.random(0,360))
  self.grav = .2
  if t then
    self.sprite = organSprites[t]
    if t == 6 then self.heart = true end
  else
    self.blood = true
    self.sprite = blood[math.random(1,#blood)]
  end
  self.stick = false
  self.live = 0
  self.harvested = 100
  if not self.blood then
    table.insert(organs,self)
  else
    table.insert(organs,1,self)
  end
end

function organ:move(dt)
  self.x = self.x + self.xvel*dt
  self.y = self.y + self.yvel*dt
  self.z = math.min(self.z + self.zvel*dt,3)
  if self.x <= wallStart then 
    self.stick = true 
    self.x = wallStart
    table.insert(wallHarvestedOrgans,self)
  elseif self.x > w or self.y > h or self.y < 0 then
    return true
  end
  if self.z < 0 then 
    self.z = 0 
    if not self.blood then
      self.zvel = -self.zvel/2
      if self.zvel > 10 then
        organ.new(self.x,self.y,0,0)
      end
    else
      self.zvel = 0
      self.xvel = 0
      self.yvel = 0 
    end
  end
  self.zvel = self.zvel -self.grav
  self.xvel = self.xvel * (1 - math.min(dt*2, 1))
  self.yvel = self.yvel * (1 - math.min(dt*2, 1))
end

function organ:update(dt)
  self.live = self.live + dt
  if not self.stick then
    if self.live > 10 then
      return true
    end
    self:move(dt)
  else
    local angle = math.atan2(h/2-self.y,0-self.x)
    local dx, dy = math.cos(angle),math.sin(angle)
    self.x = self.x + dx*dt*10
    self.y = self.y + dy*dt*10
  end
end

function organ:draw()
  local s = self.z/15
  love.graphics.setColor(1, 1, 1, self.harvested/100)
  love.graphics.draw(self.sprite,self.x,self.y,self.r,3+s,3+s)
  love.graphics.setColor(1,1,1,1)
end

return organ