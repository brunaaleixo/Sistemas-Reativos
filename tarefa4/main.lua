function naimagem (mx, my, x, y, w, h)
   return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
end

function retangulo(x ,y, w, h)
   local dx, dy = x, y
   local ox, oy = x, y
   return {
      draw =
            function ()
                love.graphics.rectangle("line", dx, dy, w, h)
            end,
      keypressed =
            function (k)
                local mx, my = love.mouse.getPosition()
                if love.keyboard.isDown(k) and naimagem(mx, my, dx, dy, w, h) then
                   if k == "down" then dy = dy + 10 end
                   if k == "right" then dx = dx + 10 end
                   if k == "b" then x = ox; y = oy end
                end
            end
   }
end

function love.load()
   tb = {}
   for i = 1, 10 do
      local x = math.random(100, 400)
      local y = math.random(100, 400)
      tb[i] = retangulo(x, y, 120, 150)
   end
end

function love.keypressed(k)
   for _,v in pairs(tb) do
      v.keypressed(k)
   end
end

function love.draw()
   for _,v in pairs(tb) do
      v.draw()
   end
end
