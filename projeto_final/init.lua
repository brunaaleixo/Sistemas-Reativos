function init()
dofile("motor.lua")
setup()
end

tmr.create():alarm(5000, tmr.ALARM_SINGLE, init)
