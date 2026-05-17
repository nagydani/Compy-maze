-- graphics.lua

-- All drawing code lives here.

gfx = love.graphics

require("decorations")

function draw_walls()
  if cur_background then
    cur_background()
    return
  end
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

-- Grid crosses in center of passable squares

function draw_cross(cx, cy, s)
  gfx.line(cx - s, cy, cx + s, cy)
  gfx.line(cx, cy - s, cx, cy + s)
end

function draw_grid()
  if not cur_grid then
    return 
  end
  gfx.setColor(Color[Color.white + Color.bright])
  gfx.setLineWidth(1)
  for r, row in ipairs(GS.grid) do
    for c = 1, #row do
      if row:sub(c, c) ~= "#" then
        local cx, cy = cell_center(c, r)
        draw_cross(cx, cy, GRID.cell / 4)
      end
    end
  end
end

-- Destination targets

function draw_goals()
  for _, g in pairs(GS.goal_map) do
    local x, y = cell_center(g.col, g.row)
    local fill = TARGET.cell_fill * g.radius
    local w, h = TARGET.sprite_w, TARGET.sprite_h
    local s = sprite_scale(w, h, fill)
    gfx.push("all")
    gfx.translate(x, y)
    gfx.scale(s, s)
    gfx.translate(-w / 2, -h / 2)
    target_sprite()
    gfx.pop()
  end
end

-- Cyan trace left by the player when moving forward.

function draw_active_trace()
  local a = player.anim
  if a and a.move_cmd == "F"
       and (a.kind == "move" or a.kind == "push")
  then
    local x1, y1 = cell_center(a.from_col, a.from_row)
    local x2, y2 = current_pos()
    gfx.circle("fill", x1, y1, GRID.trace_r)
    gfx.line(x1, y1, x2, y2)
  end
end

function draw_traces()
  gfx.setColor(Color[Color.cyan])
  gfx.setLineWidth(GRID.trace_r * 2)
  for _, t in ipairs(player.traces) do
    local x1, y1 = cell_center(t.c1, t.r1)
    local x2, y2 = cell_center(t.c2, t.r2)
    gfx.line(x1, y1, x2, y2)
    gfx.circle("fill", x1, y1, GRID.trace_r)
    gfx.circle("fill", x2, y2, GRID.trace_r)
  end
  draw_active_trace()
end

-- Angle for each compass direction

DIR_ANGLES = {
  N = 0,
  E = math.pi / 2,
  S = math.pi,
  W = -math.pi / 2
}

-- Draw one track layer with vertical offset, wrapped.

function draw_track(sprite, off)
  local step = TRACK.bar_step
  local half = step / 2
  local dy = (off + half) % step - half
  gfx.translate(0, dy)
  sprite()
  gfx.translate(0, -step)
  sprite()
  gfx.translate(0, step - dy)
end

-- Draw the player sprite at screen position (x, y).

function draw_player_at(x, y, angle, scale)
  gfx.push("all")
  gfx.translate(x, y)
  gfx.rotate(angle)
  gfx.scale(scale, scale)
  gfx.translate(-PLAYER.sprite_w / 2, -PLAYER.sprite_h / 2)
  robot_back()
  draw_track(robot_track_l, player.track_offset_l)
  draw_track(robot_track_r, player.track_offset_r)
  robot_front()
  gfx.pop()
end

-- Compute scale to fit sprite into cell with fill ratio

function sprite_scale(sw, sh, fill)
  local long_side = math.max(sw, sh)
  return GRID.cell * fill / long_side
end

-- Player position during movement animation

function anim_move_pos()
  local a = player.anim
  local p = anim_progress()
  local x1, y1 = cell_center(a.from_col, a.from_row)
  local x2, y2 = cell_center(a.target_col, a.target_row)
  return x1 + (x2 - x1) * p, y1 + (y2 - y1) * p
end

-- Position near the wall edge.

function bump_pos(p)
  local a = player.anim
  local dir = player.dir
  if a.move_cmd == "B" then
    dir = OPPOSITE_DIR[dir]
  end
  local d = DIR_DELTA[dir]
  local cx, cy = cell_center(player.col, player.row)
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

-- Player position for the current frame

ANIM_DRAW_POS = { }

ANIM_DRAW_POS.move = anim_move_pos

function ANIM_DRAW_POS.bump()
  return bump_pos(anim_progress())
end

function ANIM_DRAW_POS.fail()
  return bump_pos(1)
end

function push_offset(p)
  local peak = GRID.push_path - GRID.bump_dist
  local dist = GRID.push_path * p
  if dist < peak then
    return dist
  end
  return peak - (dist - peak)
end

function push_player_pos()
  local a = player.anim
  local dir = push_dir(a.move_cmd)
  local d = DIR_DELTA[dir]
  local cx, cy = cell_center(a.from_col, a.from_row)
  local f = push_offset(anim_progress())
  return cx + (d.x * f), cy + (d.y * f)
end

function push_box_offset(p)
  local dist = GRID.push_path * p - GRID.bump_dist
  if dist < 0 then
    return 0
  end
  if GRID.cell < dist then
    return GRID.cell
  end
  return dist
end

ANIM_DRAW_POS.push = push_player_pos

function current_pos()
  local a = player.anim
  local fn = a and ANIM_DRAW_POS[a.kind]
  if fn then
    return fn()
  end
  return cell_center(player.col, player.row)
end

-- Player angle for the current frame

function current_angle()
  local a = player.anim
  if a and a.kind == "turn" then
    local p = anim_progress()
    return lerp_angle(a.from_dir, a.target_dir, p)
  end
  return DIR_ANGLES[player.dir]
end

-- Show controls legend in the bottom right corner

function draw_legend()
  if not cur_legend then
    return 
  end
  local w, h = gfx.getDimensions()
  local font = gfx.getFont()
  local fh = font:getHeight()
  local fw = font:getWidth(cur_legend)
  local _, n = cur_legend:gsub("\n", "")
  local th = fh * (n + 1)
  gfx.setColor(Color[Color.black])
  gfx.print(cur_legend, (w - fw) - fh, (h - th) - fh)
end

-- Dim overlay for macro recording

function draw_dim()
  local w, h = gfx.getDimensions()
  gfx.setColor(0, 0, 0, 0.5)
  gfx.rectangle("fill", 0, 0, w, h)
end

function draw_macro_name(x, y)
  local name = macro_state.name:lower()
  key_bg[name] = Color[Color.blue]
  draw_key(x, y, name)
end

function draw_macro_body(x, y)
  key_bg = { }
  local w = gfx.getDimensions()
  local start_x = x
  for _, k in ipairs(macro_state.body) do
    local lk = k:lower()
    if w < x + width[lk] then
      x = start_x
      y = y + height[lk] + SCALE
    end
    draw_key(x, y, lk)
    x = x + width[lk] + SCALE
  end
end

function draw_macro_ui()
  if macro_state.shift_held then
    draw_dim()
  end
  if not macro_state.recording then
    return 
  end
  local _, h = gfx.getDimensions()
  local name = macro_state.name:lower()
  local m = STD_H * SCALE
  local y = (h - height[name]) / 2
  draw_macro_name(m, y)
  draw_macro_body(m, y + height[name] + SCALE)
end

-- Box drawing

function box_draw_pos(b)
  local a = player.anim
  if not a or a.kind ~= "push"
       or a.box ~= b
  then
    return cell_top_left(b.col, b.row)
  end
  local dir = push_dir(a.move_cmd)
  local d = DIR_DELTA[dir]
  local x, y = cell_top_left(b.col, b.row)
  local f = push_box_offset(anim_progress())
  return x + (d.x * f), y + (d.y * f)
end

function draw_box_goals()
  gfx.setColor(Color[Color.cyan])
  for _, g in pairs(GS.box_goal_map) do
    local x, y = cell_top_left(g.col, g.row)
    gfx.rectangle("fill", x, y, GRID.cell, GRID.cell)
  end
end

function draw_boxes()
  for _, b in pairs(GS.box_map) do
    local x, y = box_draw_pos(b)
    local w, h = BOX.sprite_w, BOX.sprite_h
    local s = sprite_scale(w, h, BOX.cell_fill)
    gfx.push("all")
    gfx.translate(x, y)
    gfx.scale(s, s)
    box_sprite()
    gfx.pop()
  end
end

-- Celebrate message

function draw_celebrate()
  if not GS.celebrating then
    return 
  end
  local w, h = gfx.getDimensions()
  local font = gfx.getFont()
  local fw = font:getWidth(CELEBRATE_TEXT)
  local fh = font:getHeight()
  gfx.setColor(Color[Color.white + Color.bright])
  gfx.print(CELEBRATE_TEXT, (w - fw) / 2, (h - fh) / 2)
end

-- Draw everything on screen

function draw_scene()
  draw_walls()
  draw_cells()
  draw_grid()
  draw_box_goals()
  draw_goals()
  draw_traces()
  draw_boxes()
  local x, y = current_pos()
  local angle = current_angle()
  draw_player_at(x, y, angle, GRID.scale)
  draw_legend()
  draw_macro_ui()
  draw_celebrate()
end
