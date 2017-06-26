local start = 0
local finish = 0

gpio.mode(7, gpio.OUTPUT)
gpio.mode(8, gpio.INT)

local function interruptUP(level, when)
   print("gerou up")
   start_time = tmr.now()
   gpio.trig(8,  "down", interruptDOWN)
end

local function interruptDOWN(level, when)
   print("gerou down")
   finish = tmr.now()
   gpio.trig(8, "up")
   print(tmr.state(0))
   local distance = (finish - start_time)/5800 -- in cm
   if distance < 10 then
      -- block forward movement
      isBlocked = true
   end
   isBlocked = false
end

function pulse()
   gpio.trig(8, "up", interruptUP)
   gpio.write(7, gpio.LOW)
   tmr.delay(2)
   gpio.write(7, gpio.HIGH)
   tmr.delay(12)
   gpio.write(7, gpio.LOW)
   tmr.delay(2)
   tmr.alarm(0, 400, tmr.ALARM_SINGLE, interruptDOWN)
end
