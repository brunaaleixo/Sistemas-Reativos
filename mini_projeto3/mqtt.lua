local function station(tmr)
   if wifi.sta.getip() then
      tmr:stop()
      hasip = true
      print(hasip)
   end
end

local function conmqtt(tmr)
   print(hasconnected)
   if not hasconnected then
      client:connect("192.168.123.112", 1234, 0)
   else
      tmr:stop()
   end
end

local function initStation()
   wifi.setmode(wifi.STATION)
   wifi.sta.config("", "")
   tmr.create():alarm(200, tmr.ALARM_AUTO, station)
end

local function initMQTT(timer)
   if hasip then
      timer:stop()
      hasconnected = false
      client = mqtt.Client("nodemcu", 120)
      client:on("connect", function(c) print("connected") hasconnected = true end)
      client:on("offline", function(c) print("disconnected") end)
      tmr.create():alarm(200, tmr.ALARM_AUTO, conmqtt)
   end
end

function publish(channel, msg)
   print(channel, msg)
   local callback = function(client)
      print("message sent")
   end
   client:publish(channel, msg, 0, 0, callback)
end

initStation()
tmr.create():alarm(1000, tmr.ALARM_AUTO, initMQTT)
