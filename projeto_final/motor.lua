local function parseMsg(client, topic, message)
   if topic == "up" then
      forward(tonumber(message))
   elseif topic == "down" then
      backward(tonumber(message))
   elseif topic == "left" then
      turnLeft(tonumber(message))
   elseif topic == "right" then
      turnRight(tonumber(message))
   end
end

local function checkSurroundings()
   if isBlocked then
      publish("blocked", "true")
   end
   publish("blocked", "false")
end

function carSetup()
   client:on("message", parseMsg)
   -- movements
   subscribe("up")
   subscribe("down")
   subscribe("left")
   subscribe("right")
   -- signal love that car is blocked
   subscribe("blocked")
   tmr.create(410, tmr.ALARM_AUTO, checkSurroundings)
end

function setup()
   dofile("mqtt.lua")
   dofile("hcsr04.lua")
end


function forward(v)
   -- pwm logic to move forward
   if not isBlocked then
   end
end

function backward(v)
   -- pwm logic to move backward
end

function turnLeft(v)
   -- pwm logic to turn left
end

function turnRight(v)
   -- pwm logic to turn right
end
