local vector = {}
vector.__index = vector

local function new(x, y)
	return setmetatable({ x = x or 0, y = y or 0 }, vector)
end

function vector:__tostring()
	return "(" .. self.x .. ", " .. self.y .. ")"
end

function vector:unpack()
	return self.x, self.y
end

function vector.distance(a, b)
	return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

function vector:length()
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function vector.__unm(v)
	return new(-v.x, -v.y)
end

function vector.__add(a, b)
	return new(a.x + b.x, a.y + b.y)
end

function vector.__sub(a, b)
	return new(a.x - b.x, a.y - b.y)
end

function vector.__mul(a, b)
	if type(a) == "number" then
		return new(a * b.x, a * b.y)
	elseif type(b) == "number" then
		return new(a.x * b, a.y * b)
	else
		return new(a.x * b, a.y * b)
	end
end

function vector.__div(a, b)
	if type(a) == "number" then
		return new(a / b.x, a / b.y)
	elseif type(b) == "number" then
		return new(a.x / b, a.y / b)
	else
		return new(a.x / b, a.y / b)
	end
end

function vector.__eq(a, b)
	return a.x == b.x and a.y == b.y
end

vector.new = new

return setmetatable(vector, {
	__call = function(_, ...)
		return new(...)
	end,
})
