function initStation()
   wifi.setmode(wifi.STATION)
   wifi.sta.config ( "analar_arris", "1234567890")
   print(wifi.sta.getip())
end

function connected (client)
   print("conectou")
end 

function initMQTT()
   print("iniciando mqtt")
   client = mqtt.Client("nodemcu", 120)
   print(client:connect("192.168.0.41", connected, function(client, reason) print("failed reason: "..reason) end))
end

function publish(channel, msg)
   print(channel, msg)
   local callback = function(client)
      print("message sent")
   end
   client:publish(channel, msg, 0, 0, callback)
end

initStation()
initMQTT()
