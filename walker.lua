local walker = {}

local function vec2(x, y)
  return {x = x, y = y}
end

function walker:add(x, y, width, height)
	self.x, self.y, self.width, self.height = x, y, width, height

	self.p1_detector, self.p2_detector = self:getDetecterPoints()

  self.vx, self.vy = 0, 0
  self.speed = 200
  -- 0 for left, 1 for right
  self.dir = 0
  world:add(self, self.x, self.y, self.width, self.height)
end

function walker:getDetecterPoints()
  local detectorY = self.y + self.height + self.height / 2
  return vec2(self.x - self.width / 2, detectorY),
    vec2(self.x + self.width + self.width / 2, detectorY)
end

function walker:update(dt)
  self:collide(dt)
end

function walker:move(dt)
  -- local len1, len2 = world:queryPoint
end

function walker:collide(dt)
  local futureX, futureY = self.x + self.vx * dt, self.y + self.vy * dt
  local nextX, nextY, cols, len = world:move(self, futureX, futureY)

  for i = 1, len do
    local col = cols[i]
    if col.normal.y ~= 0 then
      self.vy = 0
    end
  end

  self.x, self.y = nextX, nextY
end

return walker