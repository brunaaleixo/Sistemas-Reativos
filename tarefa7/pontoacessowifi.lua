-- Conexao na rede Wifi
wifi.setmode(wifi.SOFTAP)
wifi.ap.config({ssid="bruna",pwd="bruna123"})
wifi.ap.setip({ip="192.168.0.33",netmask="255.255.255.0",gateway="192.168.0.33"})
print(wifi.ap.getip())
