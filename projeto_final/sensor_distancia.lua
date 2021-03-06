-- Código que mede distância em centimetro utilizando sensor de distância ultrassônico HC-SR04
-- Trigger (otuput) em D2 e Echo (input e interrupção) em D1 no mini nodeMCU
-- adaptado de https://github.com/sza2/node_hcsr04

pin_trigger = 7 -- manda sinal, fio azul
pin_echo = 8 -- recebe sinal, fio branco

function init()
	local self = {}
	self.time_start = 0
	self.time_end = 0
	gpio.mode(pin_trigger, gpio.OUTPUT) -- pino trigger como saida
	gpio.mode(pin_echo, gpio.INT, gpio.PULLUP) -- pino echo como interrupção

	function self.echo_callback(level, when)
		-- se pino echo foi pra HIGH, começa a medir o tempo
		if level == gpio.HIGH then
			--print("ECHO High: Iniciando contagem")
			self.time_start = when
		-- se pino echo foi pra LOW, termina de medir o tempo (microsegundos) e calcula distancia (cm)
		elseif level == gpio.LOW then
			--print("ECHO Low: Finalizando contagem")
			self.time_end = when

			if (self.time_end - self.time_start) < 0 then
			else
				local distance_cm = (self.time_end - self.time_start) / 29.4 / 2;
				if distance_cm < 12 then
					print("Distancia:   "..distance_cm)
                    client:publish("blocked", 1, 0, 0)
                else
                    client:publish("blocked", 0, 0, 0)
                end
			end
		else
			return;
		end
	end

	function self.measure()
		-- define interrupção para pino echo pra ambas voltagens (HIGH e LOW)
		gpio.trig(pin_echo, "both", self.echo_callback)
		gpio.write(pin_trigger, gpio.HIGH)
		tmr.delay(10) --10us
		gpio.write(pin_trigger, gpio.LOW)
		tmr.delay(2) --2us
	end

	return self
end

device = init()
--mede de 10 em 10s
tmr.create():alarm(1800, tmr.ALARM_AUTO, device.measure)
