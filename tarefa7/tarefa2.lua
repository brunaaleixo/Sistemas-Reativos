-- verificar se os botões e leds correspondem a esses pinos
pin1 = 1
pin2 = 2
led1 = 1
lastinterrupt = tmr.now()
idlastinterrupt = 0
timer = timer.create()
speed = 1000 -- in ms

gpio.mode(pin1, gpio.INT)
gpio.mode(pin2, gpio.INT)
gpio.mode(led1, gpio.OUTPUT)

-- escopo lexico ( interrupcao 1 ) + rapido
do
   local function pincb(level, time)
      local lastpulse = time - lastinterrupt
      if lastpulse <= 500 and idlastinterrupt ~= 1 and idlastinterrup ~= 0 then
         gpio.write(led1, gpio.LOW)
      else
         timer:alarm(speed - 50, tmr.ALARM_AUTO, function()
               local state = gpio.read(led) == gpio.LOW and gpio.HIGH or gpio.LOW
               gpio.write(led, state)
            end)

      end
      lastinterrupt = tmr.now()
      idlastinterrupt = 1
   end
   gpio.trig(pin1, "down", pincb)
end

-- escopo lexico ( interrupcao 2 ) + devagar
do
   local function pincb(level, time)
      local lastpulse = time - lastinterrupt
      if lastpulse <= 500 and idlastinterrupt ~= 2 and idlastinterrupt ~= 0 then
            gpio.write(led1, gpio.LOW)
      else
         timer:alarm(speed + 50, tmr.ALARM_AUTO, function()
               local state = gpio.read(led) == gpio.LOW and gpio.HIGH or gpio.LOW
               gpio.write(led, state)
            end)

      end
      lastinterrupt = tmr.now()
      idlastinterrupt = 2
   end
   gpio.trig(pin2, "down", pincb)
end

timer:alarm(speed, tmr.ALARM_AUTO, function()
   local state = gpio.read(led) == gpio.LOW and gpio.HIGH or gpio.LOW
   gpio.write(led, state)
end)
