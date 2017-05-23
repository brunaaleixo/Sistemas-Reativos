
x, y = love.graphics.getDimensions()
function initializeCar() 
   car = {
     x = x/2 - carWidth/2,
     y = y/2 - carHeight/2,
     xvel = 0,
     yvel = 0,
     rotation = 0
   }
end

local ANGACCEL      = 4
local ACCELERATION  = 4

function love.update(dt)
    local increment = ACCELERATION == 0 and 0.2 or ACCELERATION*0.02
    ACCELERATION = ACCELERATION + increment > 10 and 10 or ACCELERATION + increment

   print("dt", dt)
   print("xvel", car.xvel)
   print("yvel", car.yvel)
   print("rotation", car.rotation)

   

   if love.keyboard.isDown"right" then
    -- rotate clockwise
    car.rotation = car.rotation + ANGACCEL*dt
   end
   if love.keyboard.isDown"left" then
    -- rotate counter-clockwise
    car.rotation = car.rotation - ANGACCEL*dt
   end
   if love.keyboard.isDown"down" then
    -- decelerate / accelerate backwards

      car.xvel = car.xvel - ACCELERATION*dt * math.cos(car.rotation)
      car.yvel = car.yvel - ACCELERATION*dt * math.abs(math.sin(car.rotation))
   end
   if love.keyboard.isDown"up" then
      -- accelerate
      car.xvel = car.xvel + ACCELERATION*dt * math.cos(car.rotation)
      if (car.rotation < 0 and car.xvel > 0) or (car.rotation > 0 and car.xvel < 0) then
          car.xvel = -car.xvel
      end
      
      car.yvel = car.yvel + ACCELERATION*dt * math.abs(math.sin(car.rotation))
   end
   car.x = car.x + car.xvel*dt

   car.xvel = car.xvel * 0.99
   car.yvel = car.yvel * 0.99

   dy = math.abs(dy + car.yvel) > roadHeight and 0 or dy + car.yvel

end

function love.draw()
   love.graphics.draw(road, 0, dy)
   love.graphics.draw(road, 0, -y + dy)
   love.graphics.draw(road, 0, y + dy)
   love.graphics.draw(carImage, car.x, car.y, math.rad(car.rotation), 0.5)
end


function love.load()
   inclination = 0
   speed = 0
   dy = 0

   road = love.graphics.newImage("road.png")
   carImage = love.graphics.newImage("car.png")

   roadHeight = road:getHeight()
   carWidth = carImage:getWidth()
   carHeight = carImage:getHeight()
   initializeCar()
end
