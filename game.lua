game = {
initiated = false
}

function game.init()
	g.offsetY = g.h/2
	g.offsetX = g.w/2
	g.zoom = 1
	g.camvX = 0
	g.marge_sol = 5
	
	g.tile = 50
	
	g.pX = 0.5
	g.pY = 10
	g.r = 0
	
	g.level = 0
	
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
	g.pworld = -1
	
	terrain.init()
	
	-- Test Underworld --
	--g.pworld = -1
	--g.pY = 3
	
	game.initiated = true
	delay = 0
	g.goalworld = -g.pworld
	game.newlevel()
	forcejump = false
	genorbs()
end

function game.newlevel()
	g.goal = math.random(-(g.level+3), g.level+3)
	g.level = g.level + 1
	--toggleWorld()
	g.goalworld = -g.goalworld
end

function genorbs()
	for pos,_ in pairs(terrain.t) do
		terrain.orbs[1][pos] = (math.random()>0.5)
	end
	for pos,_ in pairs(terrain.tunder) do
		terrain.orbs[-1][pos] = (math.random()>0.5)
		--terrain.orbs[-1][pos] = true
	end
	terrain.orbs[1][0] = false
	terrain.orbs[-1][0] = false
	terrain.orbs[1][-1] = false
	terrain.orbs[-1][-1] = false
	terrain.orbs[1][1] = false
	terrain.orbs[-1][1] = false
end

function game.update(dt)
	g.w = love.graphics.getWidth()
	g.h = love.graphics.getHeight()
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
	if (up or forcejump) and not g.pjumping and g.pstanding then
		g.etat = "aplati"
		delay = 0.2
		g.pjumping = true
		g.pstanding = false
		g.pvY = 15*g.power
		forcejump = false
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
	if g.pX-(g.w/g.tile) < terrain.left then
		--terrain.gen(terrain.t, "gauche", 5)
		--terrain.gen(terrain.tunder, "gauche", 5)
	end
	
	-- Mouvement personnage --
	newX = g.pX + g.pvX * dt * g.pcoeffvitesse
	newY = g.pY + g.pvY * dt
	
	-- Collisions terrain
	if g.pworld == 1 then
		newX, newY, r = terrain.collisions(terrain.t, newX,newY)
	else
		newX, newY, r = terrain.collisions(terrain.tunder, newX,newY)
	end
	--g.r = r
	
	g.pX = newX
	g.pY = newY
	
	if g.pY > (g.h/2)/g.tile then -- 42/2
		toggleWorld()
		g.power = 1
	end
	
	-- Stabilisation si presque arrêté --
	if math.abs(g.pvX) < 0.1 then
		g.pvX = 0
	end
	
	if math.floor(g.pX) == g.goal and g.pY < 8 and g.pY >=0 and g.pworld == g.goalworld then
		game.newlevel()
	end
	
	if g.pworld == 1 and terrain.orbs[1][math.floor(g.pX)] then
		terrain.orbs[1][math.floor(g.pX)] = false
		--if g.power == 1 then forcejump = true end
		g.power = g.power+.5
	end
	if g.pworld == -1 and terrain.orbs[-1][math.floor(g.pX)] then
		terrain.orbs[-1][math.floor(g.pX)] = false
		--if g.power == 1 then forcejump = true end
		g.power = g.power+.5
		
	end
	
end

function game.draw()

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
	
	-- But --
	-- Le but est de l’autre côté du monde --
	love.graphics.setBlendMode("add")
	love.graphics.setColor(math.random(255),math.random(255),math.random(255),math.random(100,255))
	local heightgoal = terrain.height(g.goal, g.pworld)
	local finalHeight, finalXGoal, ystart
	if g.goalworld == -1 then
		ystart = g.h/2+5
		heightgoal = -heightgoal-1
		finalXGoal = g.offsetX-(g.goal+1)*g.tile
		--finalXGoal = g.offsetX-g.goal*g.tile+(-g.tile)+g.tile/2
		finalHeight = g.offsetY-heightgoal*g.tile-g.tile/2
	else
		ystart = 0
		finalXGoal = g.offsetX+g.goal*g.tile
		finalHeight = g.offsetY-heightgoal*g.tile-g.tile/2
	end
	--love.graphics.circle("fill", finalXGoal,finalHeight,g.tile/2-g.tile/20)
	love.graphics.rectangle("fill", finalXGoal , ystart, g.tile-g.tile/20, g.h/2)
	b()
	love.graphics.setBlendMode("alpha")
	
	-- Orbes --
	for pos,v in pairs(terrain.orbs[1]) do
		if v then
			love.graphics.draw(img_orbe, g.offsetX+pos*g.tile+g.tile/2, g.offsetY-terrain.height(pos, 1)*g.tile-g.tile/2, 0, 1, 1, 5, 5)
		end
	end	
	for pos,v in pairs(terrain.orbs[-1]) do
		if v then
			love.graphics.draw(img_orbe, g.offsetX+(-pos-1)*g.tile+g.tile/2, g.offsetY+(terrain.height(pos, -1)+1)*g.tile-g.tile/2, 0, 1, 1, 5, 5)
		end
	end
	
	-- Overlay --
	love.graphics.setBlendMode("subtract")
	love.graphics.draw(img_ov, 0, 0, 0, g.w/1600, g.h/900)
	love.graphics.setBlendMode("alpha")
	
	--drawInfos()
end

function drawInfos()
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
