local timer = {}
timer.__index = timer

function timer.new(delay,callback,...)
  local self = setmetatable({},timer)
  self.delay = delay
  self.callback = callback
  self.t = 0
  self.prams = {...}
  table.insert(timers,self)
end

function timer:update(dt)
  self.t = self.t + dt
  if self.t >= self.delay then
    self.callback(unpack(self.prams))
    return true
  end
end

return timer