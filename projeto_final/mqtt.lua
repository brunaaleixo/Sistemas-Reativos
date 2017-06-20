local function station(tmr)
   if wifi.sta.getip() then
      tmr:stop()
      hasip = true
   end
end

local function conmqtt(tmr)
   if not hasconnected then
      client:connect("", 1883, 0)
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
      client = mqtt.Client("carro", 120)
      client:on("connect", function(c) print("connected") hasconnected = true end)
      client:on("offline", function(c) print("disconnected") end)
      tmr.create():alarm(200, tmr.ALARM_AUTO, conmqtt)
   end
end

function publish(channel, msg)
   local callback = function(client)
      print("message sent")
   end
   client:publish(channel, msg, callback)
end

initStation()
tmr.create():alarm(1000, tmr.ALARM_AUTO, initMQTT)
