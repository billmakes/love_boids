local Entity = class:extend()
function Entity:new()
	self.pos = vec(love.math.random(50, 200), love.math.random(50, 200))
	self.prev_pos = vec(self.pos.x, self.pos.y)
	self.stuck_timer = 0
	self.velocity = vec(love.math.random(-100, 100), love.math.random(-100, 100))
	self.width = 8
	self.height = 8
	self.speed = 175
	self.cell = nil
end

function Entity:move(dt)
	local new_pos = vec(self.pos.x + self.velocity.x * dt, self.pos.y + self.velocity.y * dt)
	new_pos.x = math.max(self.width, math.min(new_pos.x, map_width - self.width))
	new_pos.y = math.max(self.height, math.min(new_pos.y, map_height - self.height))

	self.pos = new_pos
end

local margin = 32
local turnfactor = 50

function Entity:steerMargins()
	if self.pos.x < margin then
		self.velocity.x = self.velocity.x + turnfactor
	elseif self.pos.x > map_width - margin then
		self.velocity.x = self.velocity.x - turnfactor
	end

	if self.pos.y < margin then
		self.velocity.y = self.velocity.y + turnfactor
	elseif self.pos.y > map_height - margin then
		self.velocity.y = self.velocity.y - turnfactor
	end
end

function Entity:update(dt)
	if self.pos.x == self.prev_pos.x and self.pos.y == self.prev_pos.y then
		self.stuck_timer = self.stuck_timer + dt
	end
	self.prev_pos = vec(self.pos.x, self.pos.y)
	if self.cell then
		local alignment, cohesion, separation = self:calculateRules(self.cell.entities)
		self.velocity.x = self.velocity.x + alignment.x + cohesion.x + separation.x
		self.velocity.y = self.velocity.y + alignment.y + cohesion.y + separation.y
	end
	local speed = math.sqrt(self.velocity.x ^ 2 + self.velocity.y ^ 2)
	if speed > self.speed then
		local factor = self.speed / speed
		self.velocity.x = self.velocity.x * factor
		self.velocity.y = self.velocity.y * factor
	end

	self:steerMargins()
	self:move(dt)

	if self.stuck_timer > 5 then
		print("STUCK!")
		self.pos = vec(love.math.random(50, 200), love.math.random(50, 200))
		self.velocity = vec(love.math.random(-100, 100), love.math.random(-100, 100))
		self.stuck_timer = 0
	end
end

function Entity:calculateRules(boids)
	local alignment = { x = 0, y = 0 }
	local cohesion = { x = 0, y = 0 }
	local separation = { x = 0, y = 0 }
	local alignment_distance = 16
	local cohesion_distance = 16
	local separation_distance = 16

	local count_alignment = 0
	local count_cohesion = 0
	local count_separation = 0

	local alignment_factor = options.alignment_factor
	local cohesion_factor = options.cohesion_factor
	local separation_factor = options.separation_factor

	for _, other in ipairs(boids) do
		if other ~= self then
			local distance = math.sqrt((other.pos.x - self.pos.x) ^ 2 + (other.pos.y - self.pos.y) ^ 2)

			if distance < alignment_distance then
				alignment.x = alignment.x + other.velocity.x
				alignment.y = alignment.y + other.velocity.y
				count_alignment = count_alignment + 1
			end

			if distance < cohesion_distance then
				cohesion.x = cohesion.x + other.pos.x
				cohesion.y = cohesion.y + other.pos.y
				count_cohesion = count_cohesion + 1
			end

			if distance < separation_distance then
				local diff_x = self.pos.x - other.pos.x
				local diff_y = self.pos.y - other.pos.y
				local diffLength = math.sqrt(diff_x ^ 2 + diff_y ^ 2)
				separation.x = separation.x + diff_x / diffLength
				separation.y = separation.y + diff_y / diffLength
				count_separation = count_separation + 1
			end
		end
	end

	if count_alignment > 0 then
		alignment.x = alignment.x / count_alignment * alignment_factor
		alignment.y = alignment.y / count_alignment * alignment_factor
	end

	if count_cohesion > 0 then
		cohesion.x = ((cohesion.x / count_cohesion) - self.pos.x) * cohesion_factor
		cohesion.y = ((cohesion.y / count_cohesion) - self.pos.y) * cohesion_factor
	end

	if count_separation > 0 then
		separation.x = separation.x / count_separation * separation_factor
		separation.y = separation.y / count_separation * separation_factor
	end

	return vec(alignment.x, alignment.y), vec(cohesion.x, cohesion.y), vec(separation.x, separation.y)
end

function Entity:draw()
	lg.push()
	lg.circle("fill", self.pos.x, self.pos.y, 4)
	local vx, vy = (self.velocity / 32):unpack()
	lg.line(self.pos.x, self.pos.y, self.pos.x + vx, self.pos.y + vy)
	lg.pop()
end

return Entity
