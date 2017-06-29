isBlocked = false

local pwmMotorA = 1
local pwmMotorB = 2
local dirMotorA = 3
local dirMotorB = 4

local dirForwardA = 1
local dirForwardB = 0
local dirBackwardA = 0
local dirBackwardB = 1

local function parseMsg(client, topic, message)
   print(topic)
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
   client:subscribe("up", 0)
   client:subscribe("down", 0)
   client:subscribe("left", 0)
   client:subscribe("right", 0)
   -- signal love that car is blocked
   client:subscribe("blocked", 0)
--   tmr.create(410, tmr.ALARM_AUTO, checkSurroundings)
   pwm.setup(pwmMotorA, 100, 512)
   pwm.setup(pwmMotorB, 100, 512)
   gpio.mode(dirMotorA, gpio.INPUT)
   gpio.mode(dirMotorB, gpio.INPUT)
   gpio.write(dirMotorA, dirForwardA)
   gpio.write(dirMotorB, dirForwardB)
end

function setup()
   dofile("mqtt.lua")
--   dofile("hcsr04.lua")
end

local function chg_direction(dirMotor)
   gpio.write(dirMotor, gpio.read(dirMotor) == 0 and 1 or 0)
end

local function get_direction(dirMotor)
   return gpio.read(dirMotor)
end

function forward(v)
   print("forward")
   -- pwm logic to move forward
   if get_direction(dirMotorA) == dirBackwardA then
      chg_direction(dirMotorA)
   end
   if get_direction(dirMotorB) == dirBackwardB then
      chg_direction(dirMotorB)
   end

   pwm.start(pwmMotorA)
   pwm.start(pwmMotorB)
end

function backward(v)
   -- pwm logic to move backward
   if get_direction(dirMotorA) == dirForwardA then
      chg_direction(dirMotorA)
   end
   if get_direction(dirMotorA) == dirForwardB then
      chg_direction(dirMotorB)
   end
end

function turnLeft(v)
   -- pwm logic to turn left
   pwm.stop(pwmMotorB)
end

function turnRight(v)
   -- pwm logic to turn right
   pwm.stop(pwmMotorA)
end
