-- there is a wall that hungers
-- it feasts on the flesh, organs and blood of humans
-- hordes of zombies come at you and you must blast their organs and blood onto the wall to keep it from dying
w,h = 0,0
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")

math.randomseed(os.time())

require"player"
timer = require"timer"
bullet = require"bullet"
button = require"button"

time = 0
timers = {}
bullets = {}
zombies = {}
organs = {}
buttons = {}

wallHarvestedOrgans = {}
wallHealth = 100

zombie = require"zombie"
organ = require"organ"

gameover = false
paused = false
gameoverReason = 0
local gameovertext = love.graphics.newImage("Sprites/gameover.png")
local reason1 = love.graphics.newImage("Sprites/reason1.png")
local reason2 = love.graphics.newImage("Sprites/reason2.png")

local monsterSprite = love.graphics.newImage("Sprites/monster.png")
local monsterEatSprite = love.graphics.newImage("Sprites/monster_eat.png")

font = love.graphics.newFont(20)
love.graphics.setFont(font)

local gameoverSound = love.audio.newSource("Audio/lose.wav","static")
tut = false

local song = love.audio.newSource("Audio/random.ogg","static")
song:setLooping(true)
song:setVolume(.2)
local m = true

local function musicToggle()
  if m then
    m = false
    song:setVolume(0)
  else
    m = true
    song:setVolume(.2)
  end
end

local function loadGame()
  time = 0
  gameover = false
  timers = {}
  bullets = {}
  zombies = {}
  organs = {}
  buttons = {}
  wallHarvestedOrgans = {}
  wallHealth = 100
  monsterPass = 0
  monsterDelay = .5
  monsterEat = false
  
  player.load()
  wallStart = 200
  tile = love.graphics.newImage("Sprites/tile.png")
  bg_image = tile
  bg_image:setWrap("repeat", "repeat")
  
  bg_quad = love.graphics.newQuad(0, 0, w, h, bg_image:getWidth()*3, bg_image:getHeight()*3)
  
  lastSpawned = 0
  song:play()
end

local setPause
local firstPause = true
function love.load()
  w,h = love.graphics.getWidth(),love.graphics.getHeight()
  loadGame()
  setPause()
end

local function gameOverEvent(r)
  gameover = true
  gameoverReason = r
  button.new(w/2-100,h/2-20,200,50,loadGame,"Restart")
  gameoverSound:play()
  song:stop()
end

local function mainGameLoop(dt)
  if player.health <= 0 then
    gameOverEvent(1)
    return
  elseif wallHealth <= 0 then
    gameOverEvent(2)
    return
  end
  
  time = time + dt
  if lastSpawned < time then
    local tmin = math.max(1,5-(time/10))
    local tmax = math.max(2,15-(time/10))
    lastSpawned = time+math.random(tmin,tmax)
    zombie.new(w,math.random(50,h-50))
  end
  player.update(dt)
  for i,v in pairs(timers) do
    local d = v:update(dt)
    if d then
      table.remove(timers,i)
    end
  end
  
  for i,v in pairs(bullets) do
    local d = v:update(dt)
    if d then
      table.remove(bullets,i)
    end
  end
  
  for i,v in pairs(zombies) do
    local d = v:update(dt)
    if d then
      table.remove(zombies,i)
    end
  end
  
  for i,v in pairs(organs) do
    local d = v:update(dt)
    if d then
      table.remove(organs,i)
    end
  end
  local t = math.min(100,.9 + (time/100))
  wallHealth = math.max(wallHealth - dt*t,0)
  if #wallHarvestedOrgans > 0 then
    monsterPass = monsterPass + dt
    if monsterPass >= monsterDelay then
      monsterPass = 0
      monsterEat = not monsterEat
    end
  else
    monsterEat = false
  end
  for i,v in pairs(wallHarvestedOrgans) do
    v.harvested = v.harvested - dt*10
    wallHealth = math.min(wallHealth+dt*.1,100)
    if v.harvested <= 0 then
      table.remove(wallHarvestedOrgans,i)
    end
  end
end

function love.update(dt)
  if not gameover and not paused then
    mainGameLoop(dt)
  end
end

function love.mousepressed(x,y,b)
  if not gameover and not paused then
    player.mousepressed(x,y,b)
  end
  if tut then tut = false end
  for _,v in pairs(buttons) do
    v:mouseCheck(x,y,b)
  end
end

local resumeButton
local tutButton
local musicButton

local function onTut () tut = true  end

setPause = function()
  if not paused then
    paused = true
    song:pause()
    if not firstPause then
      resumeButton = button.new(w/2-100,h/2-25,200,50,setPause,"Resume")
    else
      resumeButton = button.new(w/2-100,h/2-25,200,50,setPause,"Play")
    end
    tutButton = button.new(w/2-100,h/2+30,200,50,onTut,"Tutorial")
    musicButton = button.new(w-250,h-60,200,50,musicToggle,"Music On/Off")
  elseif not tut then
    firstPause = false
    paused = false
    resumeButton:destroy()
    tutButton:destroy()
    musicButton:destroy()
    song:play()
  end
end

function love.keypressed(key)
  if key == "p" and not gameover then
    setPause()
  end
end

local function mainDraw()
  love.graphics.draw(bg_image, bg_quad, 0, 0)
  for i,v in pairs(bullets) do
    v:draw()
  end
  for i,v in pairs(organs) do
    v:draw()
  end
  if not monsterEat then
    love.graphics.draw(monsterSprite,-300,0,0,3,3)
  else
    love.graphics.draw(monsterEatSprite,-300,0,0,3,3)
  end
  for i,v in pairs(zombies) do
    v:draw()
  end
  
  player.draw()
  
  love.graphics.print("Monster's hunger: ")
  love.graphics.setColor(1,0,0)
  love.graphics.rectangle("fill",200,7,100,10)
  love.graphics.setColor(0,1,0)
  love.graphics.rectangle("fill",200,7,(wallHealth/100)*100,10)
  love.graphics.setColor(1,1,1)
  formatedTime = ""
  local round = math.floor(time)
  local m = math.floor(round/60)
  local s = round - (m*60)
  formatedTime = m..":"..s
  love.graphics.print("Time survived: "..formatedTime,w/2-50)
end

local function drawGameOverScreen()
  love.graphics.draw(gameovertext,w/2,h/2-100,0,5,5,79/2,7)
  if gameoverReason == 1 then
    love.graphics.draw(reason1,w/2,h/2-50,0,2,2,36/2,7/2)
  elseif gameoverReason == 2 then
    love.graphics.draw(reason2,w/2,h/2-50,0,2,2,78/2,7/2)
  end
end

local tutorial = [[
You're the owner of a huge pet monster. It's constantly hungry.
Luckily you're also being attacked by hordes of undead.
If your pet dies, it's all over. You must feed it the gibs of the undead.
Your shotgun has a lot of force so you can launch the gibs 
into the mouth of your pet.

Hearts will sometimes drop from the undead and 
you can use them to heal yourself.

M1 = fire
WASD = move
P = pause/unpause
(Click anywhere to hide this)
]]

function love.draw()
  if paused then 
    love.graphics.setColor(.4,.4,.4)
  else
    love.graphics.setColor(1,1,1)
  end
  if not gameover then
    mainDraw()
  else
    drawGameOverScreen()
  end
  for i,v in pairs(buttons) do
    v:draw()
  end
  if tut then
    love.graphics.setColor(.4,.4,.4)
    love.graphics.rectangle("fill",30,45,w-60,350)
    love.graphics.setColor(1,1,1)
    local wi = font:getWidth(tutorial)
    love.graphics.printf(tutorial,w/2-wi/2,50,wi,"center")
  end
end