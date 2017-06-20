trig = 7 -- D7
echo = 8 -- D8

gpio.mode(trig, gpio.OUTPUT)
gpio.mode(echo, gpio.INT)

function echocb(level, when)
   print(level, when)
   if level == 1 then
      start = when
      gpio.trig(echo, "down")
   else
      finish = when
   end
end

function measure()
   gpio.trig(echo, "up", echocb)
   gpio.write(trig, gpio.HIGH)
   tmr.delay(100)
   gpio.write(trig, gpio.LOW)
   tmr.delay(100000)
   print(((finish - start)/2)/29.1 .. " cm")
end

tmr.create():alarm(10, tmr.ALARM_AUTO, measure)
