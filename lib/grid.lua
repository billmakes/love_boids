local Grid = class:extend()

function Grid:new(cell_size)
	self.cells = {}
	self.cell_size = cell_size

	for y = 1, map_height / cell_size do
		for x = 1, map_width / cell_size do
			local cx = (x - 1) * cell_size
			local cy = (y - 1) * cell_size
			local index = math.floor(x + (y - 1) * (map_width / cell_size))

			table.insert(self.cells, Cell(index, math.floor(cx), math.floor(cy), cell_size, self))
		end
	end
end

function Grid:add(entity)
	for _, cell in ipairs(self.cells) do
		if cell:inRect(entity) then
			entity.cell = cell
			cell:insert(entity)
		end
	end
end

function Grid:update(dt)
	for _, cell in ipairs(self.cells) do
		cell:update(dt)
	end
end

function Grid:countEntities()
	local count = 0
	for _, cell in ipairs(self.cells) do
		count = count + #cell.entities
	end
	return count
end

function Grid:draw()
	for _, cell in ipairs(self.cells) do
		cell:draw()
	end
end

return Grid
