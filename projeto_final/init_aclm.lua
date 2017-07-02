function init()
dofile("mqtt_aclm.lua")
end

tmr.create():alarm(5000, tmr.ALARM_SINGLE, init)

