local x, y = love.graphics.getDimensions()

function initializeCar()
   car = {
     x = x/2 - carImage:getWidth()/2,
     y = y/2 - carImage:getHeight()/2,
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
   if joystick.acceleration ~= 0 then
    local increment = joystick.acceleration
    ACCELERATION = ACCELERATION + increment > 10 and 10 or ACCELERATION + increment
   end

   -- Determina a velocidade no eixo x
   car.xvel = car.xvel + ACCELERATION*dt * math.cos(car.rotation)
   if (car.rotation < 0 and car.xvel > 0) or (car.rotation > 0 and car.xvel < 0) then
      car.xvel = -car.xvel
   end

   -- Determina a posição no eixo x do carro
   car.x = car.x + car.xvel*dt


   -- Obtem a rotação do carro
   car.rotation = joystick.rotation

   -- Determina a velocidade do carro no eixo y baseado na sua rotação
   if (car.rotation == 0) then
     car.yvel = car.yvel + ACCELERATION*dt
   else
     car.yvel = car.yvel + ACCELERATION*dt * math.abs(math.sin(car.rotation))
   end


   car.xvel = car.xvel * 0.99
   car.yvel = car.yvel * 0.99


   -- Atualiza a posição do background de acordo com a velocidade no eixo y
   dy = math.abs(dy + car.yvel) > road:getHeight() and 0 or dy + car.yvel

end

function love.draw()
   -- Desenha uma imagem de uma estrada 3 vezes (posição das imagens é atualizada 
   -- de acordo com a velocidade no eixo y para criar uma ilusão de movimento)
   love.graphics.draw(road, 0, dy)
   love.graphics.draw(road, 0, -y + dy)
   love.graphics.draw(road, 0, y + dy)

   -- Desenha o carro
   love.graphics.draw(carImage, car.x, car.y, math.rad(car.rotation), 0.5)
end

function love.load()
   ACCELERATION = 2
   dy = 0

   -- Carrega as imagens
   road = love.graphics.newImage("road.png")
   carImage = love.graphics.newImage("car.png")

   -- Inicializa o carro no centro da tela
   initializeCar()

   -- Inicializa a aceleração e a rotação do carro
   joystick = {
      acceleration = 0,
      rotation = 0,
   }
   initializeJoystick()
end
