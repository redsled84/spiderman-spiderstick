local bump = require "bump"
local world = bump.newWorld()

local frc, acc, dec, top, low = 700, 500, 6000, 350, 50
local player = {
	x = 0,
	y = 0,
	width = 32,
	height = 32,
	onGround = false,
	vx = 0,
	vy = 0,
	terminalVelocity = 650,
	jumpVelocity = -550,
	gravity = 880,
	leftDetector = {width = 6, height = 0, x = 0, y = 0, name = 'l_detector'},
	rightDetector = {width = 6, height = 0, x = 0, y = 0, name = 'r_detector'},
	name = 'player',
	wallJumpVelocity = 0
}

function collisionFilter(item, other)
	if item.name == 'player'
	and (other.name == 'l_detector' or other.name == 'r_detector') then
		return "cross"
	end
	return "slide"
end

function player:add(x, y)
	self.x, self.y = x, y
	self.leftDetector.x = self.x - self.leftDetector.width
	self.rightDetector.x = self.x + self.width
	self.leftDetector.height, self.rightDetector.height = self.height, self.height
	self.leftDetector.y, self.rightDetector.y = self.y, self.y

	world:add(self, self.x, self.y, self.width, self.height)
	world:add(self.leftDetector, self.leftDetector.x, self.leftDetector.y,
		self.leftDetector.width, self.leftDetector.height)
	world:add(self.rightDetector, self.rightDetector.x, self.rightDetector.y,
		self.rightDetector.width, self.rightDetector.height)
end

function player:updateDetectors()
	self.leftDetector.x, self.leftDetector.y = self.x - self.leftDetector.width, self.y
	self.rightDetector.x, self.rightDetector.y = self.x + self.width, self.y

	world:update(self.leftDetector, self.leftDetector.x, self.leftDetector.y)
	world:update(self.rightDetector, self.rightDetector.x, self.rightDetector.y)
end	

function player:move(dt)
	local lk = love.keyboard
  local vx, vy = self.vx, self.vy

  if lk.isDown('right') then
    if vx < 0 then
      vx = vx + dec * dt
    elseif vx < top then
      vx = vx + acc * dt
    end
  elseif lk.isDown('left') then
    if vx > 0 then
    	vx = vx - dec * dt
    elseif vx > -top then
      vx = vx - acc * dt
    end
  else
    if math.abs(vx) < low then
    	vx = 0
    elseif vx > 0 then
      vx = vx - frc * dt
    elseif vx < 0 then
      vx = vx + frc * dt
    end
  end

	self.vx, self.vy = vx, vy
end

function player:collide(dt)
	local futureX, futureY = self.x + self.vx * dt, self.y + self.vy * dt
	local nextX, nextY, cols, len = world:move(self, futureX, futureY, collisionFilter)

	self.onGround = false
	for i = 1, len do
		local col = cols[i]
		if col.other.name ~= 'l_detector' and col.other.name ~= 'r_detector' then
			if col.normal.x ~= 0 then
				self.vx = 0
			end
			if col.normal.y ~= 0 then
				self.vy = 0
			end
			if col.normal.y == -1 then
				self.onGround = true
			end
		end
	end

	local _, _, cols, len = world:check(self.leftDetector,
		self.leftDetector.x, self.leftDetector.y)
	local leftSide = false
	local rightSide = false
	for i = 1, len do
		local col = cols[i]
		if col.other.name ~= "player" then
			leftSide = true
		end
	end

	local _, _, cols, len = world:check(self.rightDetector,
		self.rightDetector.x, self.rightDetector.y)
	for i = 1, len do
		local col = cols[i]
		if col.other.name ~= "player" then
			rightSide = true
		end
	end

	if leftSide and rightSide then
		self.wallJumpVelocity = 0
	elseif leftSide then
		self.wallJumpVelocity = 550
	elseif rightSide then
		self.wallJumpVelocity = -550
	else
		self.wallJumpVelocity = 0
	end

	if leftSide or rightSide then
		self.onGround = true
	end

	self.x, self.y = nextX, nextY
end

function player:applyGravity(dt)
	if self.vy < self.terminalVelocity then
		self.vy = self.vy + self.gravity * dt 
	else
		self.vy = self.terminalVelocity
	end
end

function player:update(dt)
	self:applyGravity(dt)
	self:move(dt)
	self:collide(dt)
	self:updateDetectors()
end

function player:jump(key)
	if key == "up" and self.onGround then
		self.vy = self.jumpVelocity
		self.vx = self.wallJumpVelocity
	end
end

function player:draw()
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)


	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("line", self.leftDetector.x, self.leftDetector.y,
		self.leftDetector.width, self.leftDetector.height)
	love.graphics.rectangle("line", self.rightDetector.x, self.rightDetector.y,
		self.rightDetector.width, self.rightDetector.height)
	love.graphics.setColor(255, 255, 255)
end

local blocks
function love.load()
	blocks = {
		{
			x = 0,
			y = love.graphics.getHeight() - 20,
			width = love.graphics.getWidth(),
			height = 20
		},
		{
			x = 300,
			y = love.graphics.getHeight() - 460,
			width = 20,
			height = 440
		},
		{
			x = 45,
			y = love.graphics.getHeight() - 460,
			width = 20,
			height = 440
		}
	}
	for i = 1, #blocks do
		local block = blocks[i]
		world:add(block, block.x, block.y, block.width, block.height)
	end
	player:add(love.graphics.getWidth()/2, 100)
end

function love.update(dt)
	player:update(dt)
end

function love.draw()
	player:draw()
	for i = 1, #blocks do
		local block = blocks[i]
		love.graphics.rectangle('line', block.x, block.y, block.width, block.height)
	end
end

function love.keypressed(key)
	player:jump(key)
	if key == "escape" then
		love.event.quit()
	end
end