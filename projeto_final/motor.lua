isBlocked = 0 -- false

local pwmMotorA = 1
local pwmMotorB = 2
local dirMotorA = 3
local dirMotorB = 4

local dirForwardA = 0
local dirForwardB = 0
local dirBackwardA = 1
local dirBackwardB = 1

local dutyA = 525
local dutyB = 855


accelerationA = 1000
accelerationB = 1000

accelerationFactor = 0
deaccelerationFactor = 0
turnRightFactor = 0
turnLeftFactor = 0

local function parseMsg(client, topic, message)
   print(topic)
   local intensity = tonumber(message)
   print(intensity)

   if topic == "up" then
      accelerate(intensity)

   elseif topic == "down" then
      deaccelerate(intensity)

   elseif topic == "left" then
      turnLeft(intensity)

   elseif topic == "right" then
      turnRight(intensity)

   elseif topic == "blocked" then
      handleDistanceSensor(intensity)
   end
end

function handleDistanceSensor(newState)
   if (isBlocked == 0 and newState == 1) then
      pwm.stop(pwmMotorA)
      pwm.stop(pwmMotorB)
   elseif (isBlocked == 1 and newState == 0) then
      accelerationA = 1000
      accelerationB = 1000
      pwm.setup(pwmMotorA, accelerationA, 512)
      pwm.setup(pwmMotorB, accelerationB, 512)
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

   --   tmr.create(410, tmr.ALARM_AUTO, checkSurroundings)

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
   
   tmr.create():alarm(5000, tmr.ALARM_AUTO, function() print(countB) countB = 0 end)
   tmr.create():alarm(5000, tmr.ALARM_AUTO, function() print(countA) countA = 0 end) 
end


function setup()
   dofile("mqtt.lua")
   --   dofile("sensor_distancia.lua")
end


function slowDown(factor, acceleration) 
   local acceleration = acceleration * (1 + factor)
   acceleration = acceleration > 1000 and 1000 or acceleration

   print(acceleration)
   return acceleration
end


function speedUp(factor, acceleration)
   local acceleration = 1000 - factor*acceleration
   acceleration = acceleration < 100 and 100 or acceleration

   print(acceleration)
   return acceleration
end


function speedUpIf(condition, factor)
   prevAccelerationA = accelerationA
   prevAccelerationB = accelerationB

   if (condition) then
      accelerationA = speedUp(factor, accelerationA)
      accelerationB = speedUp(factor, accelerationB)
   else
      accelerationA = slowDown(factor, accelerationA)
      accelerationB = slowDown(factor, accelerationB)
   end

   pwm.setclock(pwmMotorA, accelerationA)
   pwm.setclock(pwmMotorB, accelerationB)
   
   -- aumento unitario na velocidade -> diminui em 0.02% a frequencia de rotacao de A e aumenta 0.02% a frequencia de rotacao de 2
   dutyA = dutyA * (1 + (accelerationA-prevAccelerationA)*0.0002)
   dutyB = dutyB * (1 - (accelerationA-prevAccelerationA)*0.0002)
   pwm.setduty(pwmMotorA, dutyA)
   pwm.setduty(pwmMotorA, dutyB)
end


function accelerate(factor)
   print("accelerate")

   speedUpIf(factor > accelerationFactor, factor)
   accelerationFactor = factor
end


function deaccelerate(factor)
   -- pwm logic to move deaccelerate
   print("slowdown")

   speedUpIf(factor < deaccelerationFactor, factor)
   deaccelerationFactor = factor
end


function turnLeft(factor)
   -- pwm logic to turn left
   if (factor > turnLeftFactor) then
      accelerationB = slowDown(factor, accelerationB)
   else
      accelerationB = speedUp(factor, accelerationB)
   end
   turnRightFactor = 0
   turnLeftFactor = factor

   pwm.setclock(pwmMotorB, accelerationB)
end



function turnRight(factor)
   -- pwm logic to turn right
   if (factor > turnRightFactor) then
      accelerationA = slowDown(factor, accelerationA)
   else
      accelerationA = speedUp(factor, accelerationA)
   end
   turnLeftFactor = 0
   turnRightFactor = factor

   pwm.setclock(pwmMotorA, accelerationA)
end

