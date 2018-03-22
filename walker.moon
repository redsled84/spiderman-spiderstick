{graphics: graphics} = love

collisionFilter = (item, other) ->
  if item.name == "walker" and (other.name == "l_detector" or other.name == "r_detector")
    return "cross"
  return "slide"

class Walker
  new: (@x, @y, @width, @height) =>
    @x, @y, @width, @height = x, y, width, height

    @p1_detector, @p2_detector = @getDetecterPoints!

    @vx, @vy = 0, 0
    @speed = 100
    -- 0 for left, 1 for right
    @dir = 0
    @name = "walker"
    @dead = false

    world\add self, x, y, width, height

  getDetecterPoints: =>
    local detectorY, x1, x2
    detectorY = @y + @height + @height / 2
    x1, x2 = @x - @width / 2, @x + @width + @width / 2
    return @vec2(x1, detectorY), @vec2(x2, detectorY)

  vec2: (x, y) =>
    return {x: x, y: y}

  update: (dt) =>
    @p1_detector, @p2_detector = @getDetecterPoints!
    @move dt
    @collide dt

    -- print @dir

  move: (dt) =>
    local len1, len2
    _, len1 = world\queryPoint(@p1_detector.x, @p1_detector.y)
    _, len2 = world\queryPoint(@p2_detector.x, @p2_detector.y)

    if len1 == 0
      @dir = 1
    if len2 == 0
      @dir = 0

    if @dir > 0
      @vx = @speed
    else
      @vx = -@speed
    -- print len1, len2

  kill: =>
    @dead = true

  collide: (dt) =>
    local futureX, futureY, nextX, nextY, cols, len
    futureX, futureY = @x + @vx * dt, @y + @vy * dt
    nextX, nextY, cols, len = world\move(self, futureX, futureY, collisionFilter)

    for i = 1, len do
      local col
      col = cols[i]

      if col.other.name == "solid" or col.other.name == "lava"
        if col.normal.x == 1
          @dir = 1
        elseif col.normal.x == -1
          @dir = 0

        if col.normal.y ~= 0
          @vy = 0

    @x, @y = nextX, nextY

  draw: =>
    graphics.setColor 255, 0, 255
    graphics.rectangle "fill", @x, @y, @width, @height

return Walker