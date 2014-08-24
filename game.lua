game = {
initiated = false
}

function game.init()
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	g.offsetY = g.h/2
	g.offsetX = g.w/2
	g.zoom = 1
	g.camvX = 0
	
	g.pX = 0
	g.pY = 50
	g.r = 0
	
	g.pvX = 0
	g.pvY = 0
	g.pstanding = false
	g.pjumping = false
	g.prunning = false
	g.power = 1
	g.pcoeffvitesse = 300
	
	g.pW = 20
	g.pH = 30
	
	g.pworld = 1
	g.tile = 50
	
	terrain.init()
	
	game.initiated = true
end

function game.update(dt)
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	g.offsetY = g.h/2
	
	keysDown()
	
	-- Déplacement --
	if left --[[and g.pstanding]] then
		g.pvX = -1
	elseif right --[[and g.pstanding]] then
		g.pvX = 1
	else
		-- Décélération --
		local decel = 0
		if g.pstanding then
			decel = 0.1
		else
			decel = 0.01
		end
		
		if g.pvX > 0 then
			g.pvX = g.pvX - decel
		elseif g.pvX < 0 then
			g.pvX = g.pvX + decel
		end
	end
	
	-- Saut --
	if up and not g.pjumping and g.pstanding then
		g.pjumping = true
		g.pstanding = false
		g.pvY = 300*g.pworld*g.power
	else
		g.pjumping = false
	end
	
	-- Course --
	if shift and g.pstanding then
		g.pcoeffvitesse = 400
	else
		g.pcoeffvitesse = 300
	end

	
	-- Gravité --
	if not g.pstanding then
		g.const = -g.pworld
	else
		g.const = 0
	end

	
	-- Scrolling --
	local marge = 200
	local decalage = 500
	if g.offsetX + (g.pX-g.pW/2)*g.zoom < marge then
		goalOffset = g.offsetX + decalage
	elseif g.offsetX + (g.pX-g.pW/2)*g.zoom > g.w-marge then
		goalOffset = g.offsetX - decalage
		g.camvX = g.pvX *1.2 ---
	else
		goalOffset = g.offsetX
	end
	if goalOffset < g.offsetX then
		g.camvX = -1.5
	elseif goalOffset > g.offsetX then
		g.camvX = 1.5
	else
		g.camvX = 0
	end
	
	-- Scrolling --
	-- TODO: à améliorer
	g.offsetX = g.offsetX + g.camvX * dt * 200	
	
	g.pvY = g.pvY + 9.81 * dt * g.const * 180
	
	-- Mouvement personnage --
	newX = g.pX + g.pvX * dt * g.pcoeffvitesse
	newY = g.pY + g.pvY * dt
	
	-- Stabilisation si presque arrêté --
	if math.abs(g.pvX) < 0.1 then
		g.pvX = 0
	end
	
	--[[ Collision sol --
	-- TODO: à remplacer par une détection de collisions en fonction du terrain
	if (not g.pstanding and not g.pjumping)
	   and ((g.pworld == 1 and g.pY <=0) or (g.pworld == -1 and g.pY >= g.pH)) then
		g.pstanding = true
		g.pjumping = false
		g.pvY = 0
		if g.pworld == 1 then
			newY = 0
		else
			newY = -g.pH*g.zoom
		end
	end
	]]
	
	-- Collisions terrain
	-- TODO: rajouter la rotation pour mieux rendre sur les pentes
	newX, newY = terrain.collisions(newX,newY)
	
	
	g.pX = newX
	g.pY = newY
	
	--[[
	if g.pY < 0 then
		g.pworld = -1
	else
		g.pworld = 1
	end]]
end

function game.draw()
	-- Infos --
	love.graphics.print(g.w.."×"..g.h)
	love.graphics.print("Player: "..g.pX..","..g.pY.." ("..g.pW.."×"..g.pH..")", 0, 14)
	--love.graphics.print("Vitesse: "..g.pvX..","..g.pvY, 250, 14)
	love.graphics.print("Offset: "..g.offsetX..","..g.offsetY.." (vitesse : "..g.camvX..")", 0, 28)
	if g.pstanding then
		love.graphics.print("Standing.", 0, 42)
	else
		love.graphics.print("Not standing.", 0, 42)
	end
	if g.pjumping then
		love.graphics.print("Jumping.", 100, 42)
	else
		love.graphics.print("Not jumping.", 100, 42)
	end
	local marge = 0
	love.graphics.print("Pos X écran : "..g.offsetX + (g.pX-g.pW/2)*g.zoom.."\n (".._(g.offsetX + (g.pX-g.pW/2)*g.zoom < marge).."/".._(g.offsetX + (g.pX-g.pW/2)*g.zoom > g.w-marge)..")", 0, 56)
	if g.t and g.relx and g.rely then
		love.graphics.print("Terrain : "..g.t..". Rel X/Y : "..g.relx..","..g.rely, 0, 84)
	end
	
	-- Terrain --
	terrain.draw()
	
	-- Ancien sol --
	--love.graphics.rectangle("fill", g.offsetX - g.w/2, g.offsetY, g.w*g.zoom, 1)
	-- Origine --
	--love.graphics.rectangle("fill", g.offsetX - (5/2)*g.zoom, g.offsetY -(5/2)*g.zoom, 5*g.zoom, 5*g.zoom)
	
	-- Joueur --
	-- (le point de référence sur le joueur est en bas au centre)
	-- (entre ses deux pieds quoi)
	love.graphics.draw(img_player, g.offsetX + (g.pX-g.pW/2)*g.zoom, g.offsetY + ((-g.pY)-g.pH)*g.zoom)
	
	--love.graphics.rectangle("fill", g.offsetX + (g.pX-g.pW/2)*g.zoom, g.offsetY + ((-g.pY)-g.pH)*g.zoom, g.pW*g.zoom, g.pH*g.zoom)
	--love.graphics.setColor(255,0,0,255)
	--love.graphics.rectangle("fill", g.offsetX + g.pX*g.zoom, g.offsetY + (-g.pY)*g.zoom, 1, 1)
	--b()
end

---------------------------------

function keysDown()
	left = love.keyboard.isDown("left")
	right = love.keyboard.isDown("right")
	up = love.keyboard.isDown("up")
	shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

---------------------------------

function pause_draw()
	game.draw()
	love.graphics.setColor(128,128,128,128)
	love.graphics.rectangle("fill", 0, 0, g.w, g.h)
	b()
end
