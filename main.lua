-- main.lua
-- Maze game: guide a turtle to the destination!

require("constants")
require("maze")
require("turtle")
require("graphics")

sfx = compy.audio

-- Grid

GRID = {
  cell = 0,
  offset_x = 0,
  offset_y = 0,
  rows = 0,
  cols = 0,
  scale = 0,
  bump_dist = 0
}

function init_grid(rows, cols)
  GRID.rows = rows
  GRID.cols = cols
  local cw = GAME.width / cols
  local ch = GAME.height / rows
  GRID.cell = math.min(cw, ch)
  local total_w = GRID.cell * cols
  local total_h = GRID.cell * rows
  GRID.offset_x = (GAME.width - total_w) / 2
  GRID.offset_y = (GAME.height - total_h) / 2
  GRID.scale = GRID.cell / (TURTLE.body_yr * TURTLE.fit_factor)
  local half = (TURTLE.body_yr + TURTLE.head_r) * GRID.scale
  GRID.bump_dist = GRID.cell / 2 - half
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
  tf = nil
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

-- Scale to fit window

function update_scale()
  local w, h = gfx.getDimensions()
  GS.tf = love.math.newTransform()
  GS.tf:scale(w / GAME.width, h / GAME.height)
end

-- Init

function reset_level()
  parse_maze()
  init_grid(#maze, #(maze[1]))
end

function ensure_init()
  if not GS.init then
    update_scale()
    reset_level()
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

function finish_move_anim(a)
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

function finish_bump_anim(a)
  turtle.color = Color.red
  sfx.lose()
  start_anim("fail", ANIM.fail_pause)
  turtle.anim.move_cmd = a.move_cmd
end

function finish_anim()
  local a = turtle.anim
  turtle.anim = nil
  if a.kind == "move" then
    finish_move_anim(a)
  elseif a.kind == "bump" then
    finish_bump_anim(a)
  elseif a.kind == "turn" then
    turtle.dir = a.target_dir
  elseif a.kind == "fail" then
    reset_level()
  elseif a.kind == "win" then
    love.event.quit()
  end
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
  update_anim(dt)
end

function love.draw()
  if GS.init then
    gfx.push()
    gfx.applyTransform(GS.tf)
    draw_scene()
    gfx.pop()
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  elseif process_key(k) then
    sfx.ping()
  end
end

function love.resize()
  if GS.init then
    update_scale()
  end
end
