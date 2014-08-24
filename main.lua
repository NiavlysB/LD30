require("conf")
require("global")
require("game")
require("terrain")

-- TODO: - remplacer le gamestate "pause" par une simple variable
--         pour pouvoir mettre en pause dans n’importe quel gamestate ?
--       - faire que la pause volontaire (p) puisse cohabiter avec l’automatique
--

--		 - Delay pour le saut, histoire d’éviter les sauts consécutifs
--       - Au bout de trois rebonds *consécutifs*, faire que le perso se ramasse par terre ?
--       - Cycle jour/nuit. Faire que le jour de l’un soit la nuit de l’autre, et inversement ?
--       - Plusieurs règles de génération de terrain + thème
--		    (par exemple un terrain plus accidenté et gris)
--       - Maîtriser mieux g.power
--       - Se débarrasser peut-être de ces g.blabla, un jour ?
		   

function love.load()
	--game.init() -- à déplacer dans update, if not game.initiated ?
	imgs_terrain = {
		["1_"] = love.graphics.newImage("img/terrain1_.png"),
		["1u"] = love.graphics.newImage("img/terrain1u.png"),
		["1d"] = love.graphics.newImage("img/terrain1d.png"),
		["1^"] = love.graphics.newImage("img/terrain1^.png"),
		["2u"] = love.graphics.newImage("img/terrain2u.png"),
		["2d"] = love.graphics.newImage("img/terrain2d.png"),
		["2^"] = love.graphics.newImage("img/terrain2^.png"),
	}
	img_player = love.graphics.newImage("img/player.png")
end

function love.update(dt)
	if not game.initiated then
		game.init()
	end
	--[[
	if dt < 1/5 then
		love.timer.sleep(1/5 - dt)
	end
	--]]--
	
	if not love.window.hasFocus() then
		g.state = "pause"
	elseif g.state == "pause" then
		g.state = "game"
	end
	
	if g.state == "game" then

		game.update(dt)
	--elseif g.state == "pause" then
	--	pause.update(dt)
	end
end

function love.draw()
	if g.state == "game" then
		game.draw(dt)
	elseif g.state == "pause" then
		pause_draw()
	end
	
	-- Display the frame time in milliseconds for convenience.
   	-- A lower frame time means more frames per second.
   	--local delta = love.timer.getAverageDelta()
   	--love.graphics.print(string.format("%.3f ms", 1000 * delta), 10, 60)
end

------------------------------

function love.keypressed(key)
	if key == "tab" then
		toggleFullscreen()
	elseif key == "p" then
		togglePause()
	elseif key == "r" then
		game.init()
		
	elseif key == "kp+" then
		g.zoom = g.zoom + 0.1
	elseif key == "kp-" then
		g.zoom = g.zoom - 0.1
	
	elseif key == " " then
		g.power = g.power + 1
	elseif key == "t" then
		toggleWorld()
		
	elseif key == "escape" then
		love.event.quit()
	end
end

function toggleFullscreen()
	if not love.window.getFullscreen() then
		love.window.setFullscreen(true, "desktop")
	else
		love.window.setFullscreen(false)
	end
end

function togglePause()
	if g.state == "pause" then
		g.state = "game"
	elseif g.state == "game" then
		g.state = "pause"
	end
end

function toggleWorld()
	-- Double check volontaire
	if g.pworld == 1 and g.pY > 0 then
		g.pworld = -1
		g.offsetrot = 3.1415926535898
		g.pY = -g.pY
		g.pvY = -g.pvY
	elseif g.pworld == -1 and g.pY < 0 then
		g.pworld = 1
		g.offsetrot = 0
		g.pY = -g.pY
		g.pvY = -g.pvY
	end
end

----------------------------------------

function b()
	love.graphics.setColor(255,255,255,255)
end

function _(b)
	if b then
		return "true"
	else
		return "false"
	end
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end
