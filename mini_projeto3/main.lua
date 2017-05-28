local x, y = love.graphics.getDimensions()

function initializeCar()
   car = {
     x = x/2 - carWidth/2,
     y = y/2 - carHeight/2,
     xvel = 0,
     yvel = 0,
     rotation = 0
   }
end

function initializeJoystick()
   mqtt = require("mqtt_library")

   updateDirection = function(topic, msg)
      if topic == "up" then
         joystick.acceleration = msg
      elseif topic == "down" then
         joystick.acceleration = -msg
      elseif topic == "left" then
         joystick.rotation = -msg
      else
         joystick.rotation = msg
      end
   end

   local __joystick = mqtt.client.create("127.0.0.1", 1883, updateDirection)

   __joystick:connect("love")
   __joystick:subscribe({"up", "down", "left", "right"})

   joystick.joystick = __joystick
end

function love.update(dt)
   local increment = joystick.acceleration == 0 and 0.2 or joystick.acceleration
   ACCELERATION = ACCELERATION + increment > 10 and 10 or ACCELERATION + increment

   print("dt", dt)
   print("xvel", car.xvel)
   print("yvel", car.yvel)
   print("rotation", car.rotation)

   car.rotation = joystick.rotation

   car.xvel = car.xvel + ACCELERATION*dt * math.cos(car.rotation)
   if (car.rotation == 0) then
     car.yvel = car.yvel + ACCELERATION*dt
   else
     car.yvel = car.yvel + ACCELERATION*dt * math.abs(math.sin(car.rotation))
   end

   if (car.rotation < 0 and car.xvel > 0) or (car.rotation > 0 and car.xvel < 0) then
      car.xvel = -car.xvel
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
   ACCELERATION = 4
   ANGACCEL = 4
   inclination = 0
   speed = 0
   dy = 0

   road = love.graphics.newImage("road.png")
   carImage = love.graphics.newImage("car.png")

   roadHeight = road:getHeight()
   carWidth = carImage:getWidth()
   carHeight = carImage:getHeight()
   initializeCar()
   joystick = {
      acceleration = 0,
      rotation = 0,
   }
   initializeJoystick()
end
