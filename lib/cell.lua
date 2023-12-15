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
			table.remove(self.entities, i)
			break
		end
	end
	for _, cell in ipairs(self.grid.cells) do
		if cell:inRect(entity) then
			entity.cell = cell
			cell:insert(entity)
			break
		end
	end
end

function Cell:update(dt)
	local to_remove = {}
	for _, entity in ipairs(self.entities) do
		entity.cell = self

		local eRect = { x = entity.pos.x, y = entity.pos.y, w = entity.width, h = entity.height }

		if not self:inRect(entity) then
			table.insert(to_remove, entity)
		else
			for _, other_entity in ipairs(self.entities) do
				if entity ~= other_entity then
					local oRect = {
						x = other_entity.pos.x,
						y = other_entity.pos.y,
						w = other_entity.width,
						h = other_entity.height,
					}
					if collision.checkRectangles(eRect, oRect) then
						local result = collision.resolveCollision(eRect, oRect)
						entity.pos.x = result.x
						entity.pos.y = result.y
					end
				end
			end
		end
	end
	for _, entity in ipairs(to_remove) do
		self:remove(entity)
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
		lg.print(tostring(#self.entities), self.coords.x, self.coords.y)
		lg.setColor(1, 1, 1, 1)
	end
	lg.pop()
	for _, enitity in ipairs(self.entities) do
		enitity:draw()
	end
end

return Cell
