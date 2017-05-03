-- SWITCH --
sw1 = 1
sw2 = 2

gpio.mode(sw1, gpio.INPUT)
gpio.mode(sw2, gpio.INPUT)

local sw={}
sw[1]="OFF"
sw[0]="ON_"



-- LED --

led1 = 3
led2 = 6

-- set LED mode
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

-- initialize LED state
gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

function createLED(numero)
  local led = numero
  local timer = tmr.create()

  return 
  {
    blink = function ()
      timer:alarm(1000, tmr.ALARM_AUTO, function()
        local state = gpio.read(led) == gpio.LOW and gpio.HIGH or gpio.LOW
        gpio.write(led, state)
      end)
    end,
    stop = function ()
      timer:stop()
    end,
    getTimerState = function ()
      return timer:state() == true and 'Piscando' or 'Desligado'
    end
  }
end

-- create LEDs
led1 = createLED(3)
led2 = createLED(6)



-- TEMPERATURE SENSOR -- 

local lasttemp = 0

function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end



local actions = {
  LERTEMP = readtemp,
  PISCAR1 = led1.blink,
  PARAR1 = led1.stop,
  PISCAR2 = led2.blink,
  PARAR2 = led2.stop,
}

srv = net.createServer(net.TCP)

function receiver(sck, request)

  -- analisa pedido para encontrar valores enviados
  local _, _, method, path, vars = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP");
  -- se não conseguiu casar, tenta sem variáveis
  if(method == nil)then
    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
  end
  
  local _GET = {}
  
  if (vars ~= nil)then
    for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
      _GET[k] = v
    end
  end


  local action = actions[_GET.pin]
  if action then action() end

  local vals = {
    --TEMP = string.format("%2.1f",adc.read(0)*(3.3/10.24)),
    TEMP =  string.format("%2.1f", lasttemp),
    CHV1 = gpio.LOW,
    CHV2 = gpio.LOW,
    LED1 = led1.getTimerState(),
    LED2 = led2.getTimerState(),
  }

  local buf = [[
<h1><u>PUC Rio - Sistemas Reativos</u></h1>
<h2><i>ESP8266 Web Server</i></h2>
        <p>Temperatura: $TEMP oC <a href="?pin=LERTEMP"><button><b>REFRESH</b></button></a>
        <p>LED 1: $LED1  :  <a href="?pin=PISCAR1"><button><b>ON</b></button></a>
                            <a href="?pin=PARAR1"><button><b>OFF</b></button></a></p>
        <p>LED 2: $LED2  :  <a href="?pin=PISCAR2"><button><b>ON</b></button></a>
                            <a href="?pin=PARAR2"><button><b>OFF</b></button></a></p>
]]

  buf = string.gsub(buf, "$(%w+)", vals)
  sck:send(buf, function() print("respondeu") end)
end

if srv then
  srv:listen(80,"192.168.0.33", function(conn)
      print("estabeleceu conexão")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")