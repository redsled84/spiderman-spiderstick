local bump = require "bump"
world = bump.newWorld()
local map = require "map"
local Camera = require "camera"

math.randomseed(os.time())

local player = require "player"
local Walker = require "walker"
local Perlin = require "perlin"

local solids = {}
local lavas = {}
local walkers = {}

local tileSize = 32
local perlin = Perlin(256)
local perlinWidth, perlinHeight = 64, 64
local background = perlin:generate(perlinWidth, perlinHeight)

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

function drawBackground()
	for y = 1, perlinHeight do
		for x = 1, perlinWidth do
			local n = background[y][x]
			if n < .02 and n > -.3 then
				love.graphics.setColor(75, 75, 75)
				love.graphics.rectangle("fill", (x - 1) * tileSize, (y - 1) * tileSize, tileSize, tileSize)
			elseif n < -.3 then
				love.graphics.setColor(55, 55, 55)	
				love.graphics.rectangle("fill", (x - 1) * tileSize, (y - 1) * tileSize, tileSize, tileSize)
			end
		end
	end
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

	love.graphics.setBackgroundColor(100, 100, 105)
	player:add(32, 32)
	-- player:add(1980, 1800)
	cam = Camera(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	min_x, min_y = cam:cameraCoords(0, 0)
	max_x, max_y = cam:cameraCoords(map.width * map.tilewidth, map.height * map.tileheight)
	cam:zoomTo(.75)
	windowWidth, windowHeight = love.graphics.getWidth() * cam.scale,
		love.graphics.getHeight() * cam.scale
	print(cam.scale, windowWidth, windowHeight)
end

-- camera lock
function love.update(dt)
	player:update(dt)
	-- cam:lockWindow(player.x, player.y, min_x + cam.x, min_y + cam.y, max_x, max_y, Camera.smooth.damped(12))
	cam:lockX(player.x, Camera.smooth.damped(10))
	cam:lockY(player.y, Camera.smooth.damped(12))

	local multiplier = .89
	if cam.x - windowWidth * multiplier < min_x then
		cam.x = min_x + windowWidth * multiplier
	elseif cam.x + windowWidth * multiplier > max_x then
		cam.x = max_x - windowWidth * multiplier
	end

	if cam.y - windowHeight * multiplier < min_y then
		cam.y = min_y + windowHeight * multiplier
	elseif cam.y + windowHeight * multiplier > max_y then
		cam.y = max_y - windowHeight * multiplier
	end

	for i = #walkers, 1, -1 do
		local walker = walkers[i]
		if not walker.dead then
			walker:update(dt)
		else
			world:remove(walker)
			table.remove(walkers, i)
		end
	end
end

function love.draw()
	cam:attach()

	drawBackground()

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