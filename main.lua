-- main.lua
-- Maze game: guide a turtle to the destination!

require("constants")
require("controls")
require("maze")
require("turtle")
require("graphics")
require("keyboard_graphics")
require("macro")
require("script")

sfx = compy.audio

-- Grid

GRID = {
  cell = 0,
  offset_x = 0,
  offset_y = 0,
  rows = 0,
  cols = 0,
  scale = 0,
  bump_dist = 0,
  trace_r = 0,
  push_path = 0
}

function init_grid(rows, cols)
  GRID.rows = rows
  GRID.cols = cols
  local w, h = gfx.getDimensions()
  GRID.cell = math.min(w / cols, h / rows)
  GRID.offset_x = (w - GRID.cell * cols) / 2
  GRID.offset_y = (h - GRID.cell * rows) / 2
  local ff = TURTLE.fit_factor
  GRID.scale = GRID.cell / (TURTLE.body_yr * ff)
  local full = TURTLE.body_yr + TURTLE.head_r
  GRID.bump_dist = GRID.cell / 2 - full * GRID.scale
  GRID.trace_r = TURTLE.head_r * GRID.scale
  GRID.push_path = GRID.bump_dist + GRID.cell + GRID.bump_dist
end

function cell_top_left(col, row)
  local x = GRID.offset_x + (col - 1) * GRID.cell
  local y = GRID.offset_y + (row - 1) * GRID.cell
  return x, y
end

function cell_center(col, row)
  local x, y = cell_top_left(col, row)
  local half = GRID.cell / 2
  return x + half, y + half
end

-- Game State

macros = { }

GS = {
  init = false,
  grid = nil,
  goal_map = { },
  box_map = { },
  box_goal_map = { },
  box_goal_count = 0,
  filled_count = 0
}

-- Parsing: read the maze strings to find the turtle

CELL_PARSERS = { }

function pos_key(col, row)
  return col + GRID.cols * row
end

CELL_PARSERS["*"] = function(c, r)
  GS.goal_map[pos_key(c, r)] = {
    col = c, row = r, radius = 1
  }
end

CELL_PARSERS["B"] = function(c, r)
  GS.box_map[pos_key(c, r)] = {
    col = c, row = r
  }
end

function CELL_PARSERS.G(c, r)
  GS.box_goal_map[pos_key(c, r)] = {
    col = c,
    row = r
  }
  GS.box_goal_count = GS.box_goal_count + 1
end

function parse_cell(ch, c, r)
  if DIR_DELTA[ch] then
    turtle_reset(c, r, ch)
    return 
  end
  local fn = CELL_PARSERS[ch]
  if fn then
    fn(c, r)
  end
end

function parse_maze()
  GS.grid = maze
  GS.goal_map = { }
  GS.box_map = { }
  GS.box_goal_map = { }
  GS.box_goal_count = 0
  GS.filled_count = 0
  for r, row in ipairs(maze) do
    for c = 1, #row do
      parse_cell(row:sub(c, c), c, r)
    end
  end
end

-- Check what is at a grid position

function is_wall(col, row)
  if row < 1 or GRID.rows < row
       or col < 1
       or GRID.cols < col
  then
    return true
  end
  local ch = GS.grid[row]:sub(col, col)
  return ch == "#"
end

function box_at(col, row)
  return GS.box_map[pos_key(col, row)]
end

function push_dir(cmd)
  if cmd == "B" then
    return OPPOSITE_DIR[turtle.dir]
  end
  return turtle.dir
end

function can_push(col, row, dir)
  local d = DIR_DELTA[dir]
  local tc, tr = col + d.x, row + d.y
  return not is_wall(tc, tr)
       and not box_at(tc, tr)
end

function win_level(goal, sound)
  start_anim("win", ANIM.win_time)
  turtle.anim.goal = goal
  sound()
end

function check_goal()
  local k = pos_key(turtle.col, turtle.row)
  local g = GS.goal_map[k]
  if g then
    win_level(g, sfx.win)
  end
end

function check_box_goals(old_key, new_key)
  if GS.box_goal_map[old_key] then
    GS.filled_count = GS.filled_count - 1
  end
  if GS.box_goal_map[new_key] then
    GS.filled_count = GS.filled_count + 1
  end
  if 0 < GS.box_goal_count
       and GS.filled_count == GS.box_goal_count
  then
    win_level(nil, sfx.wow)
  end
end

-- Init

function reset_level()
  init_grid(#maze, #(maze[1]))
  parse_maze()
end

function ensure_init()
  if not GS.init then
    reset_level()
    maze.controls()
    GS.init = true
  end
end

-- Animation execution

function start_turn(cmd)
  start_anim("turn", ANIM.turn_time)
  if cmd == "R" then
    turtle.anim.target_dir = TURN_RIGHT[turtle.dir]
  else
    turtle.anim.target_dir = TURN_LEFT[turtle.dir]
  end
end

function move_cmd_target(cmd)
  local dir = turtle.dir
  if cmd == "B" then
    dir = OPPOSITE_DIR[dir]
  end
  local d = DIR_DELTA[dir]
  return turtle.col + d.x, turtle.row + d.y
end

function start_bump(cmd)
  local t = ANIM.move_time * ANIM.bump_frac
  start_anim("bump", t)
  turtle.anim.move_cmd = cmd
end

function start_forward(cmd, tc, tr)
  start_anim("move", ANIM.move_time)
  turtle.anim.target_col = tc
  turtle.anim.target_row = tr
  turtle.anim.move_cmd = cmd
end

function push_duration()
  return GRID.push_path * ANIM.move_time / GRID.cell
end

function start_push(cmd, box)
  local d = DIR_DELTA[push_dir(cmd)]
  start_anim("push", push_duration())
  sfx.jump()
  local anim = turtle.anim
  local col, row = box.col, box.row
  anim.move_cmd = cmd
  anim.target_col = col
  anim.target_row = row
  anim.box = box
  anim.box_tc = col + d.x
  anim.box_tr = row + d.y
end

function try_push(cmd, box, tc, tr)
  if can_push(tc, tr, push_dir(cmd)) then
    start_push(cmd, box)
  else
    start_bump(cmd)
  end
end

function start_move(cmd)
  local tc, tr = move_cmd_target(cmd)
  if is_wall(tc, tr) then
    start_bump(cmd)
  else
    local box = box_at(tc, tr)
    if box then
      try_push(cmd, box, tc, tr)
    else
      start_forward(cmd, tc, tr)
    end
  end
end

function execute_next()
  local cmd = dequeue()
  if cmd == "L" or cmd == "R" then
    start_turn(cmd)
  elseif cmd == "F" or cmd == "B" then
    start_move(cmd)
  end
end

function finish_move(a)
  turtle.col = a.target_col
  turtle.row = a.target_row
  if a.move_cmd == "F" then
    table.insert(turtle.traces, {
      c1 = a.from_col,
      r1 = a.from_row,
      c2 = a.target_col,
      r2 = a.target_row
    })
  end
end

ANIM_FINISHERS = { }

function ANIM_FINISHERS.turn(a)
  turtle.dir = a.target_dir
end

function ANIM_FINISHERS.move(a)
  finish_move(a)
  check_goal()
end

function ANIM_FINISHERS.bump(a)
  turtle.color = Color.red
  sfx.lose()
  start_anim("fail", ANIM.fail_pause)
  turtle.anim.move_cmd = a.move_cmd
end

function ANIM_FINISHERS.push(a)
  finish_move(a)
  local old = pos_key(a.box.col, a.box.row)
  GS.box_map[old] = nil
  a.box.col = a.box_tc
  a.box.row = a.box_tr
  local new = pos_key(a.box_tc, a.box_tr)
  GS.box_map[new] = a.box
  check_goal()
  if not turtle.anim then
    check_box_goals(old, new)
  end
end

ANIM_FINISHERS.fail = reset_level
ANIM_FINISHERS.win = love.event.quit

function finish_anim()
  local a = turtle.anim
  turtle.anim = nil
  ANIM_FINISHERS[a.kind](a)
end

-- Update

function advance_anim(dt)
  turtle.anim.time = turtle.anim.time + dt
  if turtle.anim.kind == "win"
       and turtle.anim.goal
  then
    turtle.anim.goal.radius = 1 - anim_progress()
  end
  if turtle.anim.duration <= turtle.anim.time then
    finish_anim()
  end
end

-- Editor input processing

function process_user_input()
  if GS.input:is_empty() then
    return 
  end
  local text = string.unlines(GS.input())
  if process_input(string.lines(text)) then
    text = ""
  else
    sfx.wrong()
  end
  input_text("Commands:", string.lines(text))
end

-- Main Loop

function love.update(dt)
  ensure_init()
  if ctrl_update then
    ctrl_update()
  end
  if turtle.anim then
    advance_anim(dt)
  else
    execute_next()
  end
end

function love.draw()
  if GS.init then
    draw_scene()
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  elseif ctrl_pressed then
    ctrl_pressed(k)
  end
end

function love.keyreleased(k)
  release_shift(k)
end

function love.resize()
  if GS.init then
    init_grid(GRID.rows, GRID.cols)
  end
end
