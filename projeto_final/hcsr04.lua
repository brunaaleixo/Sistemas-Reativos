local start = 0
local finish = 0

gpio.mode(7, gpio.OUTPUT)
gpio.mode(8, gpio.INT)

function interruptUP(level, when)
   start_time = tmr.now()
   print("START " .. start_time)
   gpio.trig(8,  "down", interruptDOWN)
end

function interruptDOWN(level, when)
   finish = tmr.now()
   print("FINISH " .. finish)
   gpio.trig(8, "up")
   print(((finish - start_time)/5800))
   tmr.create():alarm(1500, tmr.ALARM_SINGLE, pulse)
end

function pulse()
   gpio.trig(8, "up", interruptUP)
   gpio.write(7, gpio.HIGH)
   tmr.delay(10)
   gpio.write(7, gpio.LOW)
   tmr.alarm(0, 200, tmr.ALARM_SINGLE, interruptDOWN)
end

pulse()
