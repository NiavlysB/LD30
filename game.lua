game = {
initiated = false
}

function game.init()
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	g.offsetY = g.h/2
	g.offsetX = g.w/2
	
	g.pX = 0
	g.pY = 50
	
	g.pvX = 0
	g.pvY = 0
	g.paX = 0
	g.paY = 0
	g.pstanding = false
	
	g.pW = 20
	g.pH = 30
	
	g.pworld = "over"
	
	game.initiated = true
end

function game.update(dt)
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	g.offsetY = g.h/2
	g.offsetX = g.w/2
	
	keysDown()
	if left then
		g.pvX = -1
	elseif right then
		g.pvX = 1
	else
		g.pvX = 0
	end
	
	-- Gravité --
	if (not g.pstanding) and ((g.pworld == "over" and g.pY <=0) or (g.pworld == "under" and g.pY >= -1)) then
		g.pstanding = true
		g.pvY = 0
		g.paY = 0
		g.pY = 0
	end
	if not g.pstanding then
		if g.pworld == "over" then -- TODO: peut-être remplacer "over"/"under" par 1/-1 pour éviter un if inutile
			g.paY = -1
		elseif g.pworld == "under" then
			g.paY = 1
		end
	else
		g.paY = 0
	end
	
	g.pvX = g.pvX + g.paX
	g.pvY = g.pvY + g.paY * 9.81
	
	g.pX = g.pX + g.pvX * dt *140
	g.pY = g.pY + g.pvY * dt
	
	
end

function game.draw()
	-- Infos --
	love.graphics.print(g.w.."×"..g.h)
	love.graphics.print("Player: "..g.pX..","..g.pY.." ("..g.pW.."×"..g.pH..")", 0, 14)
	love.graphics.print("Offset: "..g.offsetX..","..g.offsetY, 0, 28)
	if g.pstanding then
		love.graphics.print("Standing.", 0, 42)
	else
		love.graphics.print("Not standing.", 0, 42)
	end
	
	-- Sol --
	love.graphics.rectangle("fill", 0, g.h/2, g.w, 3)
	
	-- le point de référence sur le joueur est en bas au centre
	-- (entre ses deux pieds quoi)
	love.graphics.rectangle("fill", g.offsetX + g.pX-g.pW-2, g.offsetY + (-g.pY)-g.pH, g.pW, g.pH)
	-- à adapter pour prendre en compte la conversion de l’unité interne vers les pixels
	-- (+ scrolling et zoom éventuel)
end

---------------------------------

function keysDown()
	left = love.keyboard.isDown("left")
	right = love.keyboard.isDown("right")
	up = love.keyboard.isDown("up")
end

---------------------------------

function pause_draw()
	game.draw()
	love.graphics.setColor(128,128,128,128)
	love.graphics.rectangle("fill", 0, 0, g.w, g.h)
	b()
end
