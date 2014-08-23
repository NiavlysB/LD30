require("conf")
require("global")
require("game")
require("terrain")

-- TODO: - remplacer le gamestate "pause" par une simple variable
--         pour pouvoir mettre en pause dans n’importe quel gamestate ?
--       - faire que la pause volontaire (p) puisse cohabiter avec l’automatique
--
--       - avoir un système d’unités interne plus adapté, style 1 par bloc de terrain (et non 1 par pixel)

function love.load()
	--game.init() -- à déplacer dans update, if not game.initiated ?
end

function love.update(dt)
	if not game.initiated then
		game.init()
	end
	--[[
	if dt < 1/10 then
		love.timer.sleep(1/10 - dt)
	end
	]]--
	
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
	
	-- local delta = love.timer.getAverageDelta()
   	-- Display the frame time in milliseconds for convenience.
   	-- A lower frame time means more frames per second.
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
	elseif key == "+" then
		g.zoom = g.zoom + 0.1
	elseif key == "-" then
		g.zoom = g.zoom - 0.1
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
