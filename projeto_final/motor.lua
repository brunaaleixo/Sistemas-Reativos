isBlocked = 0 -- false

local pwmMotorA = 1
local pwmMotorB = 2
local dirMotorA = 3
local dirMotorB = 4

local dirForwardA = 0
local dirForwardB = 0
local dirBackwardA = 1
local dirBackwardB = 1

local dutyA = 525 -- 0.6140
local dutyB = 855


local accelerationA = 750
local accelerationB = 750

local function parseMsg(client, topic, message)
   local intensity = tonumber(message)

   if topic == "up" and intensity >= 0.6 then
      accelerate()

   elseif topic == "down" and intensity >= 0.6 then
      deaccelerate()

   elseif topic == "left" and intensity >= 0.6 then
      turnLeft()

   elseif topic == "right" and intensity >= 0.6 then
      turnRight()

   elseif topic == "blocked" then
      handleDistanceSensor(intensity)
   end
end

function handleDistanceSensor(newState)
   if (isBlocked == 0 and newState == 1) then
      pwm.stop(pwmMotorA)
      pwm.stop(pwmMotorB)
   elseif (isBlocked == 1 and newState == 0) then
      accelerationA = 750
      accelerationB = 750
      pwm.setup(pwmMotorA, accelerationA, dutyA)
      pwm.setup(pwmMotorB, accelerationB, dutyB)
      pwm.start(pwmMotorA)
      pwm.start(pwmMotorB)
   end

   isBlocked = newState
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

   client:subscribe("vA" ,0)
   client:subscribe("vB", 0)

   pwm.setup(pwmMotorA, accelerationA, dutyA)
   pwm.setup(pwmMotorB, accelerationB, dutyB)

   gpio.mode(dirMotorA, gpio.INPUT)
   gpio.mode(dirMotorB, gpio.INPUT)

   countA = 0
   countB = 0

   gpio.mode(5, gpio.INT)
   gpio.mode(6, gpio.INT)

   function contaA(l, v)
      countA = countA + 1
   end
   function contaB(l, v)
      countB = countB + 1
   end

   gpio.trig(6, "down", contaA)
   gpio.trig(5, "down", contaB)

   gpio.write(dirMotorA, dirForwardA)
   gpio.write(dirMotorB, dirForwardB)

   pwm.start(pwmMotorA)
   pwm.start(pwmMotorB)

   tmr.create():alarm(5000, tmr.ALARM_AUTO, function() client:publish("vB", countB, 0, 0) countB = 0 end)
   tmr.create():alarm(5000, tmr.ALARM_AUTO, function() client:publish("vA", countA, 0, 0) countA = 0 end)
end


function setup()
   dofile("mqtt.lua")
   dofile("sensor_distancia.lua")
end

function accelerate()
   pwm.setduty(pwmMotorA, 621)
   pwm.setduty(pwmMotorB, 1010)
end

function deaccelerate()
   pwm.setduty(pwmMotorA, dutyA)
   pwm.setduty(pwmMotorB, dutyB)
end

function turnRight()
   pwm.setduty(pwmMotorA, dutyA)
   pwm.setduty(pwmMotorB, pwmMotorB - 200)
end

function turnLeft()
   pwm.setduty(pwmMotorB, dutyB)
   pwm.setduty(pwmMotorA, pwmMotorA - 200)
end

