local bullet = {}
bullet.__index = bullet

local bulletSprite = love.graphics.newImage("Sprites/bullet.png")

function bullet.new(x,y,dx,dy)
  local self = setmetatable({},bullet)
  self.x = x
  self.y = y
  self.dx = dx
  self.dy = dy
  table.insert(bullets,self)
end

function bullet:update(dt)
  self.x = self.x + self.dx *dt
  self.y = self.y + self.dy * dt
  if self.x < 0 or self.x > w or self.y < 0 or self.y > h then
    return true
  end
  for _,v in pairs(zombies) do
    if self.x >= v.x and self.x <= v.x+v.w then
      if self.y >= v.y and self.y <= v.y+v.h then
        v.health = v.health - 5
        return true
      end
    end
  end
end

function bullet:draw()
  love.graphics.draw(bulletSprite,self.x,self.y)
end

return bullet