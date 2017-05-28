function initStation()
   wifi.sta.config{
      ssid = "analar_arris",
      pwd = "1234567890",
      save = false
   }
   wifi.setmode(wifi.STATION)
end

function initMQTT()
   client = mqtt.Client("nodemcu", 120)

   if not client:connect("192.168.0.41", 1883) then
      print("failed to set mqtt connection")
   end
end

function publish(channel, msg)
   local callback = function(client)
      print("message sent")
   end
   client:publish(channel, msg, callback)
end

initStation()
initMQTT()
