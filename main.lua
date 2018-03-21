local bump = require "bump"
world = bump.newWorld()
local map = require "map"
local Camera = require "camera"

local player = require "player"

local solids = {}
local lavas = {}

function newSolid(x, y, width, height)
	local solid = {
		x = x,
		y = y,
		width = width,
		height = height,
		name = "solid"
	}
	world:add(solid, x, y, width, height)
	solids[#solids+1] = solid
end

function newLava(x, y, width, height)
	local lava = {
		x = x,
		y = y,
		width = width,
		height = height,
		name = "lava"
	}
	world:add(lava, x, y, width, height)
	lavas[#lavas+1] = lava
end

local blocks
function love.load()
	-- solids layer
	for i = 1, #map.layers[1].objects do
		local obj = map.layers[1].objects[i]
		newSolid(obj.x, obj.y, obj.width, obj.height)
	end
	-- lava layer
	for i = 1, #map.layers[2].objects do
		local obj = map.layers[2].objects[i]
		newLava(obj.x, obj.y, obj.width, obj.height)
	end

	player:add(32, 32)
	cam = Camera(player.x, player.y)
end

function love.update(dt)
	player:update(dt)
	cam:lookAt(player.x, player.y)
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

	cam:detach()
end

function love.keypressed(key)
	player:jump(key)
	if key == "escape" then
		love.event.quit()
	end
end