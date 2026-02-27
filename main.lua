-- main.lua
-- Maze game: guide a turtle to the destination!

require("constants")
require("maze")
require("turtle")
require("graphics")
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
  trace_r = 0
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

GS = {
  init = false,
  grid = nil,
  goals = { },
  input = user_input()
}

-- Parsing: read the maze strings to find the turtle

function parse_cell(ch, c, r)
  if DIR_DELTA[ch] then
    turtle_reset(c, r, ch)
  elseif ch == "*" then
    table.insert(GS.goals, {
      col = c,
      row = r,
      radius = 1
    })
  end
end

function parse_maze()
  GS.grid = maze
  GS.goals = { }
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

function check_goal()
  for _, g in ipairs(GS.goals) do
    if g.col == turtle.col
         and g.row == turtle.row
    then
      start_anim("win", ANIM.win_time)
      turtle.anim.goal = g
      sfx.win()
      return 
    end
  end
end

-- Init

function reset_level()
  parse_maze()
  init_grid(#maze, #(maze[1]))
end

function ensure_init()
  if not GS.init then
    reset_level()
    input_text("Commands:", string.lines(""))
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

function start_move(cmd)
  local tc, tr = move_cmd_target(cmd)
  if is_wall(tc, tr) then
    local t = ANIM.move_time * ANIM.bump_frac
    start_anim("bump", t)
    turtle.anim.move_cmd = cmd
    return 
  end
  start_anim("move", ANIM.move_time)
  turtle.anim.target_col = tc
  turtle.anim.target_row = tr
  turtle.anim.move_cmd = cmd
end

function execute_next()
  local cmd = dequeue()
  if cmd == "L" or cmd == "R" then
    start_turn(cmd)
  elseif cmd == "F" or cmd == "B" then
    start_move(cmd)
  end
end

ANIM_FINISHERS = { }

function ANIM_FINISHERS.turn(a)
  turtle.dir = a.target_dir
end

function ANIM_FINISHERS.move(a)
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
  check_goal()
end

function ANIM_FINISHERS.bump(a)
  turtle.color = Color.red
  sfx.lose()
  start_anim("fail", ANIM.fail_pause)
  turtle.anim.move_cmd = a.move_cmd
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
  if turtle.anim.kind == "win" then
    local p = anim_progress()
    turtle.anim.goal.radius = 1 - p
  end
  if turtle.anim.duration <= turtle.anim.time then
    finish_anim()
  end
end

function update_anim(dt)
  if not turtle.anim then
    execute_next()
  end
  if turtle.anim then
    advance_anim(dt)
  end
end

-- Main Loop

function love.update(dt)
  ensure_init()
  if not GS.input:is_empty() then
    local ret = GS.input()
    local text = string.unlines(ret)
    if process_input(string.lines(text)) then
      input_text("Commands:", string.lines(""))
    else
      sfx.wrong()
      input_text("Commands:", string.lines(text))
    end
  end
  update_anim(dt)
end

function love.draw()
  if GS.init then
    draw_scene()
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end
end

function love.resize()
  if GS.init then
    init_grid(GRID.rows, GRID.cols)
  end
end
