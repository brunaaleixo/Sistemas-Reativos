

dev_addr = 0x68 --104
bus = 0
sda, scl = 3, 4

function init_I2C()
  i2c.setup(bus, sda, scl, i2c.SLOW)
end

function init_MPU(reg,val)  --(107) 0x6B / 0
   write_reg_MPU(reg,val)
end

function write_reg_MPU(reg,val)
  i2c.start(bus)
  i2c.address(bus, dev_addr, i2c.TRANSMITTER)
  i2c.write(bus, reg)
  i2c.write(bus, val)
  i2c.stop(bus)
end

function read_reg_MPU(reg)
  i2c.start(bus)
  i2c.address(bus, dev_addr, i2c.TRANSMITTER)
  i2c.write(bus, reg)
  i2c.stop(bus)
  i2c.start(bus)
  i2c.address(bus, dev_addr, i2c.RECEIVER)
  c=i2c.read(bus, 1)
  i2c.stop(bus)
  return c
end

local function roundToFirstDecimal(num)
  return math.floor(num * 10) / 10
end

function get_direction()
  if (Ay >= 3) then
    -- print("Turn left. Intensity:"..4-Ay)
    publish("left", 4-Ay)
  elseif (Ay > 0.1) then
    -- print("Turn right. Intensity:"..Ay)
    publish("right", Ay)
  end
end

function get_acceleration()
  if (Ax >= 3) then
    -- print("Speed up. Intensity:"..4-Ax)
    publish("up", 4-Ax)
  elseif (Ax > 0.2) then
    -- print("Slow down. Intensity:"..Ax)
    publish("down", Ax)
  end
end

function read_MPU_raw()
  i2c.start(bus)
  i2c.address(bus, dev_addr, i2c.TRANSMITTER)
  i2c.write(bus, 59)
  i2c.stop(bus)
  i2c.start(bus)
  i2c.address(bus, dev_addr, i2c.RECEIVER)
  c=i2c.read(bus, 14)
  i2c.stop(bus)

  Ax=bit.lshift(string.byte(c, 1), 8) + string.byte(c, 2)
  Ay=bit.lshift(string.byte(c, 3), 8) + string.byte(c, 4)
  Az=bit.lshift(string.byte(c, 5), 8) + string.byte(c, 6)

  Ax=roundToFirstDecimal(Ax/16384)
  Ay=roundToFirstDecimal(Ay/16384)
  Az=roundToFirstDecimal(Az/16384)

  get_direction()
  get_acceleration()

  -- print("Ax:"..Ax.."     Ay:"..Ay.."      Az:"..Az)

  return c, Ax, Ay, Az
end

function status_MPU(dev_addr)
     i2c.start(bus)
     c=i2c.address(bus, dev_addr ,i2c.TRANSMITTER)
     i2c.stop(bus)
     if c==true then
        print(" Device found at address : "..string.format("0x%X",dev_addr))
     else print("Device not found !!")
     end
end

function check_MPU(dev_addr)
   print("")
   status_MPU(0x68)
   read_reg_MPU(117) --Register 117 – Who Am I - 0x75
   if string.byte(c, 1) == 104 then print(" MPU6050 Device answered OK!")
   else print("  Check Device - MPU6050 NOT available!",c,string.byte(c, 1))
        return
   end
   read_reg_MPU(107) --Register 107 �� Power Management 1-0x6b
   if string.byte(c, 1)==64 then print(" MPU6050 in SLEEP Mode !")
   else print(" MPU6050 in ACTIVE Mode !")
   end
end

loadfile("mqtt.lua")
init_I2C()
check_MPU(0x68)
init_MPU(0x6B,0)

read_MPU_raw()

tmr.alarm(0, 1000, 1, function() read_MPU_raw() end)
