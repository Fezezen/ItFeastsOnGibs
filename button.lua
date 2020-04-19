local button = {}
button.__index = button

function button.new(x,y,w,h,callback,text)
  local self = setmetatable({},button)
  
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.callback = callback
  self.text = text
  
  table.insert(buttons,self)
  return self
end

local selectS = love.audio.newSource("Audio/select.wav","static")

function button:mouseCheck(x,y,b)
  if b == 1 then
    if x >= self.x and x <= self.x+self.w then
      if y >= self.y and y <= self.y+self.h then
        self.callback()
        selectS:play()
      end
    end
  end
end

function button:draw()
  love.graphics.setColor(.5,.5,.5)
  love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
  love.graphics.setColor(.7,.7,.7)
  love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
  love.graphics.setColor(0,0,0)
  local w, h;
  if(self.w<font:getWidth(self.text))then 
    w = font:getWidth(self.text)
  else
    w = self.w
  end
  if(self.h<font:getHeight(self.text))then
    h = font:getHeight(self.text)
  else
    h = self.h
  end
  love.graphics.printf(self.text, self.x, self.y+self.h/4, w, "center");
  love.graphics.setColor(1,1,1)
end

function button:destroy()
  for i,v in pairs(buttons) do
    if v == self then table.remove(buttons,i) break end
  end
end

return button