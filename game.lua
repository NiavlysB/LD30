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
	g.marge_sol = 5
	
	g.tile = 50
	
	g.pX = 0.5
	g.pY = 10
	g.r = 0
	
	
	g.pvX = 0
	g.pvY = 0
	g.pstanding = false
	g.pjumping = false
	g.prunning = false
	g.power = 1
	g.pcoeffvitesse = 3
	g.etat = "normal"
	
	g.pW = 20/g.tile
	g.pH = 30/g.tile
	
	g.offsetrot = 0
	g.pworld = 1
	
	terrain.init()
	
	-- Test Underworld --
	--g.pworld = -1
	--g.pY = 3
	
	game.initiated = true
	delay = 0
end

function game.update(dt)
	g.w = love.window.getWidth()
	g.h = love.window.getHeight()
	g.offsetY = g.h/2
	
	keysDown()
	
	-- Déplacement --
	if left --[[and g.pstanding]] then
		g.pvX = -g.pworld
	elseif right --[[and g.pstanding]] then
		g.pvX = g.pworld
	else
		-- [[ Décélération --
		local decel = 0
		if g.pstanding then
			decel = 0.1
		else
			decel = 0.01
		end
		--decel = 0.5 -- tmp
		
		if g.pvX > 0 then
			g.pvX = g.pvX - decel
		elseif g.pvX < 0 then
			g.pvX = g.pvX + decel
		end
		--]]
		--g.pvX = 0
	end
	
	-- Saut --
	if up and not g.pjumping and g.pstanding then
		g.etat = "aplati"
		delay = 0.2
		g.pjumping = true
		g.pstanding = false
		g.pvY = 15*g.power
	else
		g.pjumping = false
	end
	
	if delay > 0 then
		delay = delay - dt
	else
		g.etat = "normal"
		delay = 0
	end
	
	-- Course --
	if shift and g.pstanding then
		g.pcoeffvitesse = 8
	else
		g.pcoeffvitesse = 5
	end

	
	-- Gravité --
	if not g.pstanding then
		g.const = -1
	else
		g.const = 0
	end
	--print(g.const)
	g.pvY = g.pvY + 9.81 * dt * g.const * 10
	
	-- Scrolling --
	local marge = 200
	local decalage = 5
	if g.offsetX + (g.pX*g.pworld-g.pW/2)*g.tile < marge then
		goalOffset = g.offsetX + decalage
	elseif g.offsetX + (g.pX*g.pworld-g.pW/2)*g.tile > g.w-marge then
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
	-- TODO: à améliorer (goalOffset plus loin et vitesse camvX progressive)
	g.offsetX = g.offsetX + g.camvX * dt * 200	
	
	
	-- Mouvement personnage --
	newX = g.pX + g.pvX * dt * g.pcoeffvitesse
	newY = g.pY + g.pvY * dt
	
	
	-- Collisions terrain
	-- TODO: rajouter la rotation pour mieux rendre sur les pentes
	if g.pworld == 1 then
		newX, newY, r = terrain.collisions(terrain.t, newX,newY)
	else
		newX, newY, r = terrain.collisions(terrain.tunder, newX,newY)
	end
	--g.r = r
	
	g.pX = newX
	g.pY = newY
	
	if g.pY > 21 then -- 42/2
		--toggleWorld()
	end
	
	-- Stabilisation si presque arrêté --
	if math.abs(g.pvX) < 0.1 then
		g.pvX = 0
	end
end

function game.draw()
	-- [[ Infos --
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
	--]]
	
	-- Fond --
	love.graphics.draw(img_bg, g.w/2, g.h/2, 0, 1, 1, 800, 450)
	
	-- Terrain --
	terrain.draw(terrain.t)
	terrain.draw(terrain.tunder, true)
	
	-- Joueur --
	-- (le point de référence sur le joueur est en bas au centre)
	-- (entre ses deux pieds quoi)
	
	--local finalX = g.offsetX + (g.pX-g.pW/2)*g.tile
	--local finalY = g.offsetY + ((-g.pY)-g.pH)*g.tile
	local finalX = g.offsetX + g.pX*g.tile
	local finalY = g.offsetY - g.pY*g.tile
	if g.pworld == -1 then
		finalY = g.offsetY + g.pY*g.tile + 2*g.marge_sol
		finalX = g.offsetX - g.pX*g.tile
		g.offsetrot = math.pi
	else
		g.offsetrot = 0
	end
	love.graphics.draw(img_player[g.etat], finalX, finalY, g.offsetrot, 1, 1, (g.pW/2)*g.tile, g.pH*g.tile)
	-- TODO: Régler la rotation								math.rad(g.r)
	
	-- Overlay --
	love.graphics.setBlendMode("subtractive")
	love.graphics.draw(img_ov, 0, 0, 0, g.w/1600, g.h/900)
	love.graphics.setBlendMode("alpha")
	
	
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
