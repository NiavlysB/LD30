game = {
initiated = false
}

function game.init()
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	
	g.pX = g.w/2
	g.pY = g.h/2 -20
	
	game.initiated = true
end

function game.update(dt)
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	
end

function game.draw()
	love.graphics.print(g.w.."×"..g.h)
	
	love.graphics.rectangle("fill",g.pX,g.pY,20,30)
end

---------------------------------

--function pause.update(dt)
	-- ... --
--end

function pause_draw()
	game.draw()
	love.graphics.setColor(128,128,128,128)
	love.graphics.rectangle("fill", 0, 0, g.w, g.h)
	b()
end
