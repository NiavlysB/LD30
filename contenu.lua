Candy = {
	x = 0,
	born = false,
	dead = false,
}
	
candies = {}

function Candy:new(x)
	if not x then
		x = math.rand(0,#terrain.t)
	end
	o = {}
	setmetatable(o, self)
	self.__index = self
	candies.add(o)
	return o
end
