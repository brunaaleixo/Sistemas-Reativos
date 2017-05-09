local m = mqtt.Client("clientid", 133)

-- Leitura e publicação da temperatura
local function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end

function publicaTemperatura(c)
  readtemp()
  string.format("%2.1f", lasttemp)
  c:publish("temperatura","Bruna: "..lasttemp,0,0, 
            function(client) print("mandou!") end)
end


-- Recebe mensagens do canal
function inscricao (c)
  local msgsrec = 0
  local function novamsg (c, t, m)
    if (t == "temperatura") then
      print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
      msgsrec = msgsrec + 1
    elseif (t == "controle") then
      print(m)
      velocidade = tonumber(m) * 1000
      timer:stop()
      timer:alarm(velocidade, tmr.ALARM_AUTO, function()
         publicaTemperatura(c)
      end)
    end 
  end
  c:on("message", novamsg)
end


-- Manda periodicamente a leitura de temperatura
function conectado (client)
  timer = tmr.create()
  timer:alarm(10000, tmr.ALARM_AUTO, function()
     publicaTemperatura(client)
  end)
  client:subscribe("temperatura", 0, inscricao)
  client:subscribe("controle", 0, inscricao)
end 


-- Registra botão
pin1 = 1
gpio.mode(pin1,gpio.INT,gpio.PULLUP)

-- Manda a temperatura no clique do botao
do
   local function pincb(level, time)
      publicaTemperatura(m)
   end
   gpio.trig(pin1, "down", pincb)
end


m:connect("192.168.43.136", 1883, 0, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)

