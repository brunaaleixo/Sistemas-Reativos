function player(side)
   local x, y = love.graphics.getDimensions()
   local width, height = x, y

   if side == 'left' then
      x = 50
      y = y / 2
   else
      x = x - 50
      y = y / 2
   end

   return {
      update = function (direction)
         if direction == 'down' and y < height - 50 then
            y = y + 20
         elseif direction == 'up' and y > 50 then
            y = y - 20
         end
      end,
      draw = function (score)
         local dx = x == 50 and 100 or 200
         love.graphics.rectangle("fill", x, y, 10, 30)
         love.graphics.print(side .. " :" .. tostring(score),
         dx, 10)
      end,
      getY = function () return y end
   }

end

function pingpong()
   local x, y = love.graphics.getDimensions()
   local R = math.random(10, 255)
   local G = math.random(20, 255)
   local B = math.random(30, 255)
   local velocity = 2.5
   local collisions = 0
   local thepast = 1
   local direction = math.random(0,1)
   local sinMultiplier = math.random(-10, 10)
   local ox, oy = x / 2, y / 2
   x = ox
   y = oy

   -- heavy update calculation
   local _update = function ()
      if collisions > thepast then
         velocity = velocity + 0.5
         thepast = collisions
      end
      local p1 = player1.getY()
      local p2 = player2.getY()
      if (x <= 60 and y >= p1 and p1 <= y ) or 
         (x >= 740 and y >= p2 and p2 <= y )
         then
         direction = direction == 0 and 1 or 0
         collissions = collisions + 1
         sinMultiplier = math.random(-10, 10)
      end

      x = x + (direction == 0 and -velocity or velocity)
      y = y + (5*math.sin(math.rad(sinMultiplier)))

      if (x <= 10 or x > (love.graphics.getWidth() - 10)) or
         (y <= 60 or y > (love.graphics.getHeight() - 10)) then
         if x < love.graphics.getWidth() / 2 then
            score.right = score.right + 1
         else
            score.left = score.left + 1
         end
         x = ox
         y = oy
         start = false
         velocity = 2.3
         goto done
      end

      ::done::
      return x, y
   end

   return {
      update = function()
         x, y = _update()
      end,
      draw = function ()
         love.graphics.setColor(R, G, B)
         love.graphics.circle("fill", x, y, 5, 50)
         love.graphics.setColor(255, 255, 255)
      end

   }
end

function love.draw()
   love.graphics.line({ 0, 30, love.graphics.getWidth(), 30})
   love.graphics.setLineStyle("rough")
   love.graphics.line({love.graphics.getWidth()/2, 30, love.graphics.getWidth()/2, love.graphics.getHeight()})
   pong.draw()
   player1.draw(score.left)
   player2.draw(score.right)
end

function love.keypressed(key)
   if key == "space" then
      start = true
   end
   if key == "up" then
      player2.update("up")
   elseif key == "down" then
      player2.update("down")
   end
   if key == "w" then
      player1.update("up")
   elseif key == "s" then
      player1.update("down")
   end
end

function love.update(dt)
   math.randomseed(dt)
   if start then
      pong.update()
   end
end

function love.load()
   player1 = player("left")
   player2 = player("right")
   score = { left = 0, right = 0 }
   pong = pingpong()
   start = false
end
