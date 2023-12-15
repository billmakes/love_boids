---@diagnostic disable: lowercase-global
vec = require("lib.vector")
class = require("lib.third-party.classic")
Entity = require("lib.entity")
Cell = require("lib.cell")
Grid = require("lib.grid")

lg = love.graphics

game_scale = 1
ui_scale = 1
map_width, map_height = 320 * 6, 320 * 3
show_grid = true

local cell_size = 96

grid = Grid(cell_size)

entities = {}

function add_entity()
	local entity = Entity(100, 100)
	grid:add(entity)
	table.insert(entities, entity)
end

game_canvas = lg.newCanvas(map_width, map_height)
game_canvas:setFilter("nearest", "nearest")

update_start = 0
update_end = 0

draw_start = 0
draw_end = 0

options = {
	alignment_factor = 0.5,
	cohesion_factor = 0.5,
	separation_factor = 5.5,
}

selections = {
	"alignment_factor",
	"cohesion_factor",
	"separation_factor",
}

local selected_index = 1

function love.update(dt)
	update_start = love.timer.getTime()

	grid:update(dt)
	update_end = love.timer.getTime()

	if love.keyboard.isDown("right") then
		options[selections[selected_index]] = options[selections[selected_index]] + 0.1
	elseif love.keyboard.isDown("left") then
		options[selections[selected_index]] = options[selections[selected_index]] - 0.1
	elseif love.keyboard.isDown("space") then
		add_entity()
	end
end

function countOrphans()
	local count = 0
	for _, v in ipairs(entities) do
		if not v.cell then
			count = count + 1
		end
	end

	return count
end

function love.keypressed(key)
	if key == "down" then
		selected_index = selected_index - 1
		if selected_index < 1 then
			selected_index = 3
		end
	elseif key == "up" then
		selected_index = selected_index + 1
		if selected_index > 3 then
			selected_index = 1
		end
	elseif key == "g" then
		show_grid = not show_grid
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		add_entity()
	end
end

function draw_menu()
	-- Display the menu based on the selected index
	if selected_index == 1 then
		lg.setColor(1, 0, 0, 1)
		lg.print("ALIGNMENT_FACTOR: " .. options.alignment_factor, 10, lg.getHeight() - 20)
		lg.setColor(1, 1, 1, 1)
	else
		lg.print("alignment_factor: " .. options.alignment_factor, 10, lg.getHeight() - 20)
	end

	if selected_index == 2 then
		lg.setColor(1, 0, 0, 1)
		lg.print("COHESION_FACTOR: " .. options.cohesion_factor, 10, lg.getHeight() - 40)
		lg.setColor(1, 1, 1, 1)
	else
		lg.print("cohesion_factor: " .. options.cohesion_factor, 10, lg.getHeight() - 40)
	end

	if selected_index == 3 then
		lg.setColor(1, 0, 0, 1)
		lg.print("SEPARATION_FACTOR: " .. options.separation_factor, 10, lg.getHeight() - 60)
		lg.setColor(1, 1, 1, 1)
	else
		lg.print("separation_factor: " .. options.separation_factor, 10, lg.getHeight() - 60)
	end
end

function love.draw()
	draw_start = love.timer.getTime()
	lg.push("all")
	lg.setCanvas(game_canvas)
	lg.clear(lg.getBackgroundColor())

	grid:draw()

	lg.pop()
	lg.push("all")
	lg.draw(
		game_canvas,
		lg.getWidth() / 2 - map_width * game_scale / 2,
		lg.getHeight() / 2 - map_height * game_scale / 2,
		0,
		game_scale
	)
	lg.pop()
	draw_end = love.timer.getTime()
	local total_time = (update_end - update_start) + (draw_end - draw_start) + 1e-3 --for manual_gc time in main_loop

	lg.print(("frame time: %0.2fms (%d fps)"):format(total_time * 1000, 1 / math.max(0.001, total_time)), 10, 10)
	lg.print(
		("memory: %0.2fmb"):format(collectgarbage("count") / 1024, lg.getStats().texturememory / 1024 / 1024),
		10,
		20
	)
	lg.print("grid entities: " .. grid.count, 10, 30)
	lg.print("entities: " .. #entities, 10, 40)
	lg.print("orphans: " .. countOrphans(), 10, 50)
	lg.print("SPACE to add boids", 10, 70)
	lg.print("G to hide grid", 10, 90)

	draw_menu()
end
