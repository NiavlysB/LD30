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
		[-1] = "1_",
		[0]  = "1_",
		[1]  = "1_",
	}
	terrain.left = -1
	terrain.right = 1
	
	terrain.gen("gauche", 30)
	terrain.gen("droite", 30)
	
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


function terrain.gen(dir, nb)
	local restant = nb or 10
	local start, possibles
	
	love.math.setRandomSeed(love.timer.getTime())
	
	if dir == "gauche" then
		pos = terrain.left - 1
		
		while restant > 0 do
			possibles = gen_rules[terrain.t[pos+1]].gauche
			terrain.t[pos] = possibles[math.random(1,#possibles)]
			restant = restant-1
			pos = pos-1
		end
		terrain.left = pos+1
		
	elseif dir == "droite" then
		pos = terrain.right + 1
		
		while restant > 0 do
			possibles = gen_rules[terrain.t[pos-1]].droite
			terrain.t[pos] = possibles[math.random(1,#possibles)]
			restant = restant-1
			pos = pos+1
		end
		terrain.right = pos-1
	end
	--elseif dir == "droite" then
	--	start = terrain.right + 1
		
	
end

function terrain.collision(x, y)
	
end

function terrain.draw()
	
	for i,t in pairs(terrain.t) do
		if t == "2^" or t == "2u" or t == "2d" then
			off = 100
		else
			off = 50
		end
		--print(t)
		love.graphics.draw(imgs_terrain[t], (i*50*g.zoom + g.offsetX), (g.offsetY-off), 0, g.zoom, g.zoom)
		--[[
		if t == 0 then
			--love.graphics.rectangle("fill", (i*50 + g.offsetX)*g.zoom, g.offsetY, 1*g.zoom, 2)
		elseif t == 1 then
			love.graphics.rectangle("fill", (i*50 + g.offsetX*g.zoom), g.offsetY, 50*g.zoom, 2)
		elseif t == 2 then
			love.graphics.rectangle("fill", (i*50 + g.offsetX*g.zoom), (g.offsetY*g.zoom-50), 50*g.zoom, 2)
		
		end
		]]
	end
	
	-- Sol --
	--love.graphics.rectangle("fill", g.offsetX - g.w/2, g.offsetY, g.w*g.zoom, 1)
	-- Origine --
	love.graphics.rectangle("fill", g.offsetX - (5/2)*g.zoom, g.offsetY -(5/2)*g.zoom, 5*g.zoom, 5*g.zoom)
end
