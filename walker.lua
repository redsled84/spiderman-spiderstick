local graphics
graphics = love.graphics
local collisionFilter
collisionFilter = function(item, other)
  if item.name == "walker" and (other.name == "l_detector" or other.name == "r_detector") then
    return "cross"
  end
  return "slide"
end
local Walker
do
  local _class_0
  local _base_0 = {
    getDetecterPoints = function(self)
      local detectorY, x1, x2
      detectorY = self.y + self.height + self.height / 2
      x1, x2 = self.x - self.width / 2, self.x + self.width + self.width / 2
      return self:vec2(x1, detectorY), self:vec2(x2, detectorY)
    end,
    vec2 = function(self, x, y)
      return {
        x = x,
        y = y
      }
    end,
    update = function(self, dt)
      self.p1_detector, self.p2_detector = self:getDetecterPoints()
      self:move(dt)
      return self:collide(dt)
    end,
    move = function(self, dt)
      local len1, len2
      local _
      _, len1 = world:queryPoint(self.p1_detector.x, self.p1_detector.y)
      _, len2 = world:queryPoint(self.p2_detector.x, self.p2_detector.y)
      if len1 == 0 then
        self.dir = 1
      end
      if len2 == 0 then
        self.dir = 0
      end
      if not self.stop then
        if self.dir > 0 then
          self.vx = self.speed
        else
          self.vx = -self.speed
        end
      else
        self.vx = 0
      end
    end,
    engage = function(self)
      self.stop = true
    end,
    speedyMcSpeedster = function(self)
      self.stop = false
      self.potentiallyDead = true
      self.speed = self.speed * 3
    end,
    kill = function(self)
      self.dead = true
    end,
    collide = function(self, dt)
      local futureX, futureY, nextX, nextY, cols, len
      futureX, futureY = self.x + self.vx * dt, self.y + self.vy * dt
      nextX, nextY, cols, len = world:move(self, futureX, futureY, collisionFilter)
      for i = 1, len do
        local col
        col = cols[i]
        if col.other.name == "solid" or col.other.name == "lava" then
          if col.normal.x == 1 then
            self.dir = 1
          elseif col.normal.x == -1 then
            self.dir = 0
          end
          if col.normal.y ~= 0 then
            self.vy = 0
          end
        end
      end
      self.x, self.y = nextX, nextY
    end,
    draw = function(self)
      graphics.setColor(255, 0, 255)
      return graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, width, height)
      self.x, self.y, self.width, self.height = x, y, width, height
      self.x, self.y, self.width, self.height = x, y, width, height
      self.p1_detector, self.p2_detector = self:getDetecterPoints()
      self.vx, self.vy = 0, 0
      self.speed = 160
      self.dir = 0
      self.name = "walker"
      self.dead = false
      self.potentiallyDead = false
      return world:add(self, x, y, width, height)
    end,
    __base = _base_0,
    __name = "Walker"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Walker = _class_0
end
return Walker
