-- graphics.lua

-- All drawing code lives here.

gfx = love.graphics

-- Maze drawing

function draw_walls()
  local w, h = gfx.getDimensions()
  gfx.setColor(Color[Color.blue + Color.bright])
  gfx.rectangle("fill", 0, 0, w, h)
end

function draw_cells()
  gfx.setColor(Color[Color.white])
  for r, row in ipairs(GS.grid) do
    for c = 1, #row do
      if row:sub(c, c) ~= "#" then
        local x, y = cell_top_left(c, r)
        gfx.rectangle("fill", x, y, GRID.cell, GRID.cell)
      end
    end
  end
end

-- Destinations are red circles

function draw_goals()
  gfx.setColor(Color[Color.red])
  for _, g in ipairs(GS.goals) do
    local x, y = cell_center(g.col, g.row)
    local r = (GRID.cell / 2) * g.radius
    gfx.circle("fill", x, y, r)
  end
end

-- Cyan trace left by the turtle when moving forward.

function draw_active_trace()
  local a = turtle.anim
  if a and a.kind == "move"
       and a.move_cmd == "F"
  then
    local x1, y1 = cell_center(a.from_col, a.from_row)
    local x2, y2 = current_pos()
    gfx.line(x1, y1, x2, y2)
  end
end

function draw_traces()
  gfx.setColor(Color[Color.cyan])
  gfx.setLineWidth(GRID.trace_r * 2)
  for _, t in ipairs(turtle.traces) do
    local x1, y1 = cell_center(t.c1, t.r1)
    local x2, y2 = cell_center(t.c2, t.r2)
    gfx.line(x1, y1, x2, y2)
    gfx.circle("fill", x1, y1, GRID.trace_r)
    gfx.circle("fill", x2, y2, GRID.trace_r)
  end
  draw_active_trace()
end

-- Turtle drawing

function draw_leg(scale, sx, sy)
  local xr = TURTLE.body_xr * scale
  local yr = TURTLE.body_yr * scale
  local lxr = TURTLE.leg_xr * scale
  local lyr = TURTLE.leg_yr * scale
  gfx.push("all")
  gfx.translate(sx * xr, sy * (yr / 2 + lxr))
  gfx.rotate(sx * sy * TURTLE.leg_angle)
  gfx.ellipse("fill", 0, 0, lxr, lyr)
  gfx.pop()
end

-- Four legs

function draw_legs(scale)
  draw_leg(scale, -1, -1)
  draw_leg(scale, 1, -1)
  draw_leg(scale, -1, 1)
  draw_leg(scale, 1, 1)
end

-- Body ellipse and round head

function draw_body(scale)
  local xr = TURTLE.body_xr * scale
  local yr = TURTLE.body_yr * scale
  local hr = TURTLE.head_r * scale
  local neck = TURTLE.neck * scale
  gfx.ellipse("fill", 0, 0, xr, yr)
  gfx.circle("fill", 0, (-yr - hr) + neck, hr)
end

-- Angle for each compass direction

DIR_ANGLES = {
  N = 0,
  E = math.pi / 2,
  S = math.pi,
  W = -math.pi / 2
}

-- Draw the turtle at screen position (x, y)

function draw_turtle_at(x, y, angle, scale)
  local body_c = turtle.color or Color.green
  local limb_c = body_c + Color.bright
  gfx.push("all")
  gfx.translate(x, y)
  gfx.rotate(angle)
  gfx.setColor(Color[limb_c])
  draw_legs(scale)
  gfx.setColor(Color[body_c])
  draw_body(scale)
  gfx.pop()
end

-- Turtle position during movement animation

function anim_move_pos()
  local a = turtle.anim
  local p = anim_progress()
  local x1, y1 = cell_center(a.from_col, a.from_row)
  local x2, y2 = cell_center(a.target_col, a.target_row)
  return x1 + (x2 - x1) * p, y1 + (y2 - y1) * p
end

-- Position near the wall edge.

function bump_pos(p)
  local a = turtle.anim
  local dir = turtle.dir
  if a.move_cmd == "B" then
    dir = OPPOSITE_DIR[dir]
  end
  local d = DIR_DELTA[dir]
  local cx, cy = cell_center(turtle.col, turtle.row)
  return cx + d.x * GRID.bump_dist * p, cy + d.y * GRID.
      bump_dist * p
end

-- Smoothly rotate between two directions

function lerp_angle(from_dir, to_dir, t)
  local from = DIR_ANGLES[from_dir]
  local to = DIR_ANGLES[to_dir]
  local diff = to - from
  if math.pi < diff then
    diff = diff - 2 * math.pi
  elseif diff < -math.pi then
    diff = diff + 2 * math.pi
  end
  return from + diff * t
end

-- Turtle position for the current frame

ANIM_DRAW_POS = { }
ANIM_DRAW_POS.move = anim_move_pos

function ANIM_DRAW_POS.bump()
  return bump_pos(anim_progress())
end

function ANIM_DRAW_POS.fail()
  return bump_pos(1)
end

function current_pos()
  local a = turtle.anim
  local fn = a and ANIM_DRAW_POS[a.kind]
  if fn then
    return fn()
  end
  return cell_center(turtle.col, turtle.row)
end

-- Turtle angle for the current frame

function current_angle()
  local a = turtle.anim
  if a and a.kind == "turn" then
    return lerp_angle(a.from_dir, a.target_dir, anim_progress())
  end
  return DIR_ANGLES[turtle.dir]
end

-- Show controls legend in the bottom right corner

function draw_legend()
  local w, h = gfx.getDimensions()
  local font = gfx.getFont()
  local fh = font:getHeight()
  local fw = font:getWidth(LEGEND)
  local _, n = LEGEND:gsub("\n", "")
  local th = fh * (n + 1)
  gfx.setColor(Color[Color.white])
  gfx.print(LEGEND, (w - fw) - fh, ((h - th) - fh) - fh)
end

-- Draw everything on screen

function draw_scene()
  draw_walls()
  draw_cells()
  draw_goals()
  draw_traces()
  local x, y = current_pos()
  local angle = current_angle()
  draw_turtle_at(x, y, angle, GRID.scale)
  draw_legend()
end
