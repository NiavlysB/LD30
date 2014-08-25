terrain = {}

--[[
  
  0 = vide
  1_ = plat, niveau 0
  1u = ◢
  1d = ◣
  1^ = ■ (plat, niveau 1)
  2u = ◢ (deux blocs)
  2d = ◣ (deux blocs)
  2^ = ■ (deux blocs)
  
--]]
--[[terrain.t = {
	[-4] = "2^",
	[-3] = "2d",
	[-2] = "1d",
	[-1] = "1_",
	[0]  = "1_",
	[1]  = "1_",
	[2]  = "1u",
	[3]  = "1^",
	[4]  = "1d",
}]]
function terrain.init()
	terrain.t = {
		[-1]  = "1_",
		[0]  = "1_",
		[1]  = "1_",
	}
	terrain.left = -1
	terrain.right = 1
	
	--terrain.genboth("gauche", 10)
	--terrain.gen(terrain.t, "droite", 10)

	terrain.tunder = {
		[-1]  = "1_",
		[0]  = "1_",
		[1]  = "1_",
	}
	--[[terrain.tunder = {
		[-3] = "1d",
		[-2] = "1u",
		[-1] = "1d",
		[0] = "1_",
		[1] = "1u",
		[2] = "2u",
		[3] = "2^",
	}--]]
	--terrain.left = -1
	--terrain.right = 1
	terrain.genboth("gauche", 20)
	terrain.right = 1
	terrain.genboth("droite", 20)
	--terrain.gen(terrain.tunder, "droite", 10)
	
end

terrain.orbs = {
	[1] = {},
	[-1] = {}
}

function terrain.height(pos,world)
	local tt
	if world == 1 then
		tt = terrain.t
	elseif world == -1 then
		tt = terrain.tunder
	end
	
	if tt[pos] == "1_" then
		return 0
	elseif tt[pos] == "1u" or tt[pos] == "1d" then
		return 0.5
	elseif tt[pos] == "1^" then
		return 1
	elseif tt[pos] == "2u" or tt[pos] == "2d" then
		return 1.5
	elseif tt[pos] == "2^" then
		return 2
	end
end
	
function terrain.extremes(tt)
	min = 0
	max = 0
	for i,_ in pairs(terrain.t) do
		if i<min then
			min = i
		elseif i>max then
			max = i
		end
	end
	return min, max
end

function terrain.genboth(dir, nb)
	local l = terrain.left
	local r = terrain.right
	local udir
	if dir == "gauche" then udir = "droite"
	else udir = "gauche" end
	--print(terrain.left, terrain.right)
	terrain.gen(terrain.t, dir, nb)
	--print(terrain.left, terrain.right)
	terrain.left = l
	terrain.right = r
	terrain.gen(terrain.tunder, udir, nb)
end

--[[ Règles de génération du terrain :
	
	  1_	gauche → "1_", "1d"
			droite → "1_", "1u"
	  
	  1u	gauche → "1_"
	  		droite → "2u", "1^"
	  
	  1d	gauche → "2d", "1^"
	  		droite → "1_"
	  
	  1^	gauche → "1^", "1u", "2d"
	  		droite → "1^", "1d", "2u"
	  
	  2u	gauche → "1u", "1^"
	  		droite → "2^", "2d"
	  
	  2d	gauche → "2^", "2u"
	  		droite → "1d", "1^"
	  
	  2^	gauche → "2^", "2u"
	  		droite → "2^", "2d"
	
--]]

gen_rules = {
	["1_"] = {gauche = {"1_", "1d"}, droite = {"1_", "1u"} },
	["1u"] = {gauche = {"1_"}, droite = {"2u", "1^"} }, 
	["1d"] = {gauche = {"2d", "1^"}, droite = {"1_"} },
	["1^"] = {gauche = {"1^", "1u", "2d"}, droite = {"1^", "1d", "2u"} },
	["2u"] = {gauche = {"1u", "1^"}, droite = {"2^", "2d"} },
	["2d"] = {gauche = {"2^", "2u"}, droite = {"1d", "1^"} },
	["2^"] = {gauche = {"2^", "2u"}, droite = {"2^", "2d"} }, 
}

function terrain.gen(tt, dir, nb)
	local restant = nb or 10
	local start, possibles
	local pos
	
	love.math.setRandomSeed(love.timer.getTime())
	print("_____")
	if dir == "gauche" then
		pos = terrain.left - 1
		
		while restant > 0 do
			possibles = gen_rules[tt[pos+1]].gauche
			tt[pos] = possibles[math.random(1,#possibles)]
			restant = restant-1
			pos = pos-1
		end
		terrain.left = pos+1
		
	elseif dir == "droite" then
		pos = terrain.right + 1
		
		while restant > 0 do
			print(pos-1)
			possibles = gen_rules[tt[pos-1]].droite
			tt[pos] = possibles[math.random(1,#possibles)]
			restant = restant-1
			pos = pos+1
		end
		terrain.right = pos-1
	end
end

function reverse(tt)
	-- Euh, pas fini et pas utile, je crois --
	local tmp
	for i,t in pairs(tt) do
		if i < 0 then
			tmp = tt[i]
		end
	end
end
		

function terrain.collisions(tt, x, y)
	local newX = x
	local newY = y
	
	-- TODO: Régler la rotation (NON)
	local r = 0
	
	if not g.pjumping then
	
		g.t = tt[math.floor(x)]
		g.rely = y-math.floor(y)
		g.relx = x-math.floor(x)
		if g.t == "1_" then
			if y < 0 then
				newY = 0
				stopY()
			end
		elseif g.t == "1^" then
			if y <= 1 then
				newY = 1
				stopY()
			end
			
		elseif g.t == "2^" then
			if y < 2 then
				newY = 2
				stopY()
			end
			
		elseif g.t == "1u" then
			if y <= g.relx then
				newY = g.relx
				stopY()
				r = -45
			else
				g.pstanding = false
			end
			
		elseif g.t == "1d" then
			if y <= 1-g.relx then
				newY = 1-g.relx
				stopY()
				r = 45
			else
				g.pstanding = false
			end
			
		elseif g.t == "2u" then
			if y < 1 or (y < 2 and g.rely <= g.relx) then
				--print("if")
				newY = g.relx+1
				stopY()
				r = -45
			else
				g.pstanding = false
			end
		elseif g.t == "2d" then
			if y < 1 or (y < 2 and g.rely <= 1-g.relx) then
				newY = 2-g.relx
				stopY()
				r = 45
			else
				g.pstanding = false
			end
		end
	end
	return newX, newY, r
end

function stopY()
	g.pstanding = true
	g.pjumping = false
	g.pvY = 0
end	

function terrain.draw(tt, under)
	under = under or false
	
	if under then
		invert = math.pi
	else
		invert = 0
	end
	
	for i,t in pairs(tt) do
		if t == "2^" or t == "2u" or t == "2d" then
			off = 2*g.tile
		else
			off = g.tile
		end
		if under then
			off = -off-2*g.marge_sol
			i = -i
		end
		--love.graphics.draw(imgs_terrain[t], (i*g.tile + g.offsetX), (g.offsetY-off), invert, g.zoom, g.zoom)
		if under then
		love.graphics.draw(img_terrain_global_under, coords_imgs_terrain[t], math.floor(i*g.tile + g.offsetX), math.floor(g.offsetY-off), invert, g.zoom, g.zoom)
		else
		love.graphics.draw(img_terrain_global, coords_imgs_terrain[t], math.floor(i*g.tile + g.offsetX), math.floor(g.offsetY-off), invert, g.zoom, g.zoom)
		end
	end
end
