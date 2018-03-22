local bump = require "bump"
world = bump.newWorld()
local map = require "map"
local Camera = require "camera"

local player = require "player"
local Walker = require "walker"

local solids = {}
local lavas = {}
local walkers = {}

function newObject(objTable, x, y, width, height, name)
	local obj = {
		x = x,
		y = y,
		width = width,
		height = height,
		name = name
	}
	world:add(obj, x, y, width, height)
	objTable[#objTable+1] = obj
end

local blocks
function love.load()
	-- solids layer
	for i = 1, #map.layers[1].objects do
		local obj = map.layers[1].objects[i]
		newObject(solids, obj.x, obj.y, obj.width, obj.height, "solid")
	end
	-- lava layer
	for i = 1, #map.layers[2].objects do
		local obj = map.layers[2].objects[i]
		newObject(lavas, obj.x, obj.y, obj.width, obj.height, "lava")
	end
	-- walker layer
	for i = 1, #map.layers[3].objects do
		local obj = map.layers[3].objects[i]

		-- print(obj.x, obj.y, obj.width, obj.height)
		walkers[i] = Walker(obj.x, obj.y, 48, 32)
	end

	-- player:add(32, 32)
	player:add(1980, 1800)
	cam = Camera(player.x, player.y)
end

function love.update(dt)
	player:update(dt)
	cam:lockX(player.x, Camera.smooth.damped(12))
	cam:lockY(player.y, Camera.smooth.damped(12))

	for i = #walkers, 1, -1 do
		local walker = walkers[i]
		if not walker.dead then
			walker:update(dt)
		else
			print(true)
			world:remove(walker)
			table.remove(walkers, i)
		end
	end
end

function love.draw()
	cam:attach()

	player:draw()

	for i = 1, #solids do
		local block = solids[i]
		love.graphics.setColor(200, 200, 200)
		love.graphics.rectangle('fill', block.x, block.y, block.width, block.height)
	end
	for i = 1, #lavas do
		local block = lavas[i]
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle('fill', block.x, block.y, block.width, block.height)
	end
	for i = 1, #walkers do
		local walker = walkers[i]
		walker:draw()
	end

	cam:detach()
end

function love.keypressed(key)
	player:jump(key)
	if key == "escape" then
		love.event.quit()
	end
end