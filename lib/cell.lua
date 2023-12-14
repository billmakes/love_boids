local collision = require("lib.collision")

local Cell = class:extend()

function Cell:new(index, x, y, size, grid)
	self.index = index
	self.coords = vec(x, y)
	self.entities = {}
	self.size = size
	self.grid = grid
end

function Cell:inRect(entity)
	return collision.checkRectangles(
		{ x = entity.pos.x, y = entity.pos.y, w = entity.width, h = entity.height },
		{ x = self.coords.x, y = self.coords.y, w = self.size, h = self.size }
	)
end

function Cell:insert(entity)
	table.insert(self.entities, entity)
	entity.cell = self
end

function Cell:remove(entity)
	for i, e in ipairs(self.entities) do
		if e == entity then
			entity.cell = nil
			table.remove(self.entities, i)
		end
	end
end

function Cell:update(dt)
	for _, entity in ipairs(self.entities) do
		entity.cell = self

		local eRect = { x = entity.pos.x, y = entity.pos.y, w = entity.width, h = entity.height }

		if not self:inRect(entity) then
			self:remove(entity)
			self.grid:add(entity)
		else
			if entity.no_collide then
				return
			end
			for j, otherEntity in ipairs(self.entities) do
				if entity ~= otherEntity then
					local oRect =
						{ x = otherEntity.pos.x, y = otherEntity.pos.y, w = otherEntity.width, h = otherEntity.height }
					if collision.checkRectangles(eRect, oRect) then
						local result = collision.resolveCollision(eRect, oRect)
						entity.pos.x = result.x
						entity.pos.y = result.y
					end
				end
			end
		end
	end
end

function Cell:draw()
	lg.push()
	if show_grid then
		if #self.entities > 0 then
			lg.setColor(1, 0, 0, 1)
		end
		if #self.entities > 3 then
			lg.setColor(0, 1, 0, 1)
		end
		if #self.entities > 4 then
			lg.setColor(0, 0, 1, 1)
		end
		lg.rectangle("line", self.coords.x, self.coords.y, self.size, self.size)
		lg.print(self.index, self.coords.x, self.coords.y)
		lg.setColor(1, 1, 1, 1)
	end
	lg.pop()
	for _, enitity in ipairs(self.entities) do
		enitity:draw()
	end
end

return Cell
