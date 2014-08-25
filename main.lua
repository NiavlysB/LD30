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

--       -


-- Priorités :
--  	* But, victoire avec un minimum de difficulté
--		/ Graphismes potables
--		* Monde auto-générant à mesure qu’on l’explore (ou *au pire* mettre une limite)
--		* Boussole ! (ou vent poussant le personnage dans la bonne direction pdt 1 sec)
--		* Menu, écrans…
--		* Animations
--		* Caméra plus fluide
--		* soleil qui tourne ?

--		Avant le packaging, penser à enlever tous les print et les touches de debug

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
	
	img_terrain_global = love.graphics.newImage("img/terrainglobal.png")
	img_terrain_global_under = love.graphics.newImage("img/terrainglobal_under.png")
	coords_imgs_terrain = {
		["1^"] = love.graphics.newQuad(0, 50, 50, 55, 350, 105),
		["1_"] = love.graphics.newQuad(50, 50, 50, 55, 350, 105),
		["1u"] = love.graphics.newQuad(100, 50, 50, 55, 350, 105),
		["1d"] = love.graphics.newQuad(150, 50, 50, 55, 350, 105),
		["2u"] = love.graphics.newQuad(200, 0, 50, 105, 350, 105),
		["2d"] = love.graphics.newQuad(250, 0, 50, 105, 350, 105),
		["2^"] = love.graphics.newQuad(300, 0, 50, 105, 350, 105),
	}
	img_player = {
		["normal"] = love.graphics.newImage("img/player.png"),
		["aplati"] = love.graphics.newImage("img/player_aplati.png")
	}
	img_bg = love.graphics.newImage("img/background.jpg")
	img_ov = love.graphics.newImage("img/overlay.jpg")
	img_orbe = love.graphics.newImage("img/orbe.png")
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	game.init()
end

function love.update(dt)
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
		if not game.initiated then
			game.init()
		end
	
		game.update(dt)
	--elseif g.state == "pause" then
	--	pause.update(dt)
	end
end

function love.draw()
	if g.state == "menu" then
		love.graphics.print("Press a key…", 10, 10)
	elseif g.state == "game" then
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
	if g.state == "game" then
		if key == "tab" then
			toggleFullscreen()
		elseif key == "p" then
			togglePause()
		--elseif key == "r" then
		--	game.init()
		
		--elseif key == "kp+" then
		--	g.zoom = g.zoom + 0.1
		--elseif key == "kp-" then
		--	g.zoom = g.zoom - 0.1
	
		--elseif key == " " then
			--g.power = g.power + 1
		---elseif key == "t" then
		--	toggleWorld()
		--elseif key == "g" then
		--	game.newlevel()	
	
		elseif key == "escape" then
			g.state = "menu"
		end
	elseif g.state == "menu" then
		if key == "escape" then
			love.event.quit()
		else
			g.state = "game"
		end
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
	-- g.pY reste identique, le draw se charge de dessiner en bas et à l'envers
	if g.pworld == 1 then -- (overworld) → Underworld
		g.pworld = -1
		
	elseif g.pworld == -1 then -- (underworld) → Overworld
		g.pworld = 1
	end
	g.pX = -g.pX
	g.pY = (g.h/2)/g.tile
	g.pvY = 0
	g.pstanding = false
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
