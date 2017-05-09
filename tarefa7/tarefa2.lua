-- verificar se os botões e led1s correspondem a esses pinos
pin1 = 1
pin2 = 2
led1 = 3
timepassed = 0
lasttime = 0
idlastinterrupt = 0
timer = tmr.create()
speed = 1000 -- in ms

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(pin1,gpio.INT,gpio.PULLUP)
gpio.mode(pin2, gpio.INT,gpio.PULLUP)

function updateSpeed(pin, diff, timepassed)
   speed = speed + diff

   -- 1000000us = 1s
   if timepassed <= 1000000 and idlastinterrupt ~= pin then
      timer:stop()
      gpio.write(led1, gpio.LOW)
   else
      timer:stop()
      speed = speed <= 0 and 1000 or speed
      timer:alarm(speed, tmr.ALARM_AUTO, function()
         local state = gpio.read(led1) == gpio.LOW and gpio.HIGH or gpio.LOW
         gpio.write(led1, state)
      end)
   end

   idlastinterrupt = pin
end

-- escopo lexico ( interrupcao 1 ) + rapido
do
   local function pincb(level, time)
      timepassed = time - lasttime
      
      print("pin1")
      print(time..'-'..lasttime..'='..timepassed)
      
      lasttime = time
      
      updateSpeed(pin1, -100, timepassed)
   end
   gpio.trig(pin1, "down", pincb)
end

-- escopo lexico ( interrupcao 2 ) + devagar
do
   local function pincb(level, time)
      timepassed = time - lasttime
      
      print("pin2")
      print(time..'-'..lasttime..'='..timepassed)

      lasttime = time
      updateSpeed(pin2, 100, timepassed)
   end
   gpio.trig(pin2, "down", pincb)
end

timer:alarm(speed, tmr.ALARM_AUTO, function()
   local state = gpio.read(led1) == gpio.LOW and gpio.HIGH or gpio.LOW
   gpio.write(led1, state)
end)
