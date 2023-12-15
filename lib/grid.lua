local Grid = class:extend()

function Grid:new(cell_size)
	self.cells = {}
	self.cell_size = cell_size
	self.count = 0

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
	if entity.cell then
		entity.cell:remove(entity)
	end
	for _, cell in ipairs(self.cells) do
		if cell:inRect(entity) then
			entity.cell = cell
			cell:insert(entity)
			break
		end
	end
end

function Grid:update(dt)
	local count = 0
	for _, cell in ipairs(self.cells) do
		cell:update(dt)
		count = count + #cell.entities
	end
	self.count = count
end

function Grid:draw()
	for _, cell in ipairs(self.cells) do
		cell:draw()
	end
end

return Grid
