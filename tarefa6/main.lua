clock = 0

function newblip (vel)
  local x, y = 0, 0
  return {
    update = coroutine.wrap (function (self) 
      local width, height = love.graphics.getDimensions( )

      while (true) do
        x = x+1
        if x > width then
        -- volta Ã  esquerda da janela
          x = 0
        end

        wait(vel, self)
      end
    end),
    affected = function (pos)
      if pos>x and pos<x+10 then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
    draw = function ()
      love.graphics.rectangle("line", x, y, 10, 10)
    end
  }
end

function wait (vel, blip) 
  listawait[blip] = clock + vel
  coroutine.yield()
end

function newplayer ()
  local x, y = 0, 200
  local width, height = love.graphics.getDimensions( )
  return {
  try = function ()
    return x
  end,
  update = function (dt)
    x = x + 0.5
    if x > width then
      x = 0
    end
  end,
  draw = function ()
    love.graphics.rectangle("line", x, y, 30, 10)
  end
  }
end

function love.keypressed(key)
  if key == 'a' then
    pos = player.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(pos)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        return -- assumo que sÃ³ vai pegar um blip
      end
    end
  end
end

function love.load()
  player =  newplayer()
  listabls = {}
  listawait = {}
  for i = 1, 5 do
    listabls[i] = newblip(i/100)
    listawait[listabls[i]] = 0
  end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
end

function isBlipActive(blip)
  return (clock >= listawait[listabls[blip]])
end

function love.update(dt)
  player.update(dt)
  clock = clock + dt
  for i = 1,#listabls do
    if (isBlipActive(i)) then
      listabls[i]:update()
    end
    
  end
end
  