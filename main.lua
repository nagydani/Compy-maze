-- main.lua

-- Maze game: guide a player to the destination!

require("constants")
require("controls")
require("graphics")
require("levels")
require("player")
require("keyboard_graphics")
require("macro")
require("script")

sfx = compy.audio

-- Echo of entered commands (one line per Enter).

echo_lines = { }

-- Marker for queue entries with no source (keyboard
-- input on non-editor levels).

NO_REF = { }

-- Grid

GRID = { }

function init_grid(rows, cols)
  GRID.rows = rows
  GRID.cols = cols
  local w, h = gfx.getDimensions()
  GRID.cell = math.min(w / cols, h / rows)
  GRID.offset_x = (w - GRID.cell * cols) / 2
  GRID.offset_y = (h - GRID.cell * rows) / 2
  local long_side = math.max(PLAYER.sprite_w, PLAYER.sprite_h)
  GRID.scale = GRID.cell * PLAYER.cell_fill / long_side
  GRID.bump_dist = (GRID.cell - long_side * GRID.scale) / 2
  GRID.trace_r = GRID.cell * TRACE.radius_frac
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
level_index = 1
maze = levels[level_index]
cur_controls = editor
cur_progression = portal
cur_legend = nil
cur_grid = false
cur_background = nil

GS = {
  init = false,
  grid = nil,
  goal_map = { },
  box_map = { },
  box_goal_map = { },
  box_goal_count = 0,
  filled_count = 0,
  won = false,
  celebrating = false
}

-- Parsing: read the maze strings to find the player

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
    player_reset(c, r, ch)
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
  GS.won = false
  GS.celebrating = false
  echo_lines = { }
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
    return OPPOSITE_DIR[player.dir]
  end
  return player.dir
end

function can_push(col, row, dir)
  local d = DIR_DELTA[dir]
  local tc, tr = col + d.x, row + d.y
  return not is_wall(tc, tr)
       and not box_at(tc, tr)
end

function win_level(goal, sound)
  start_anim("win", ANIM.win_time)
  player.anim.goal = goal
  sound()
end

function check_goal()
  local k = pos_key(player.col, player.row)
  local g = GS.goal_map[k]
  if g and #player.queue == 0 then
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
       and #player.queue == 0
  then
    win_level(nil, sfx.wow)
  end
end

-- Init

function reset_level()
  init_grid(#maze, #(maze[1]))
  parse_maze()
end

function apply_attrs()
  if maze.controls ~= nil then
    cur_controls = maze.controls
  end
  if maze.progression ~= nil then
    cur_progression = maze.progression
  end
  cur_legend = maze.legend
  if maze.grid ~= nil then
    cur_grid = maze.grid
  end
  cur_background = maze.background
end

function start_level()
  apply_attrs()
  reset_level()
  cur_controls()
end

function ensure_init()
  if not GS.init then
    start_level()
    GS.init = true
  end
end

-- Animation execution

function start_turn(cmd, ref)
  start_anim("turn", ANIM.turn_time, ref)
  if cmd == "R" then
    player.anim.target_dir = TURN_RIGHT[player.dir]
  else
    player.anim.target_dir = TURN_LEFT[player.dir]
  end
  player.last_turn = cmd
end

function move_cmd_target(cmd)
  local dir = player.dir
  if cmd == "B" then
    dir = OPPOSITE_DIR[dir]
  end
  local d = DIR_DELTA[dir]
  return player.col + d.x, player.row + d.y
end

function start_bump(cmd, ref)
  local t = ANIM.move_time * ANIM.bump_frac
  start_anim("bump", t, ref)
  player.anim.move_cmd = cmd
end

function start_forward(cmd, ref, tc, tr)
  start_anim("move", ANIM.move_time, ref)
  player.anim.target_col = tc
  player.anim.target_row = tr
  player.anim.move_cmd = cmd
end

function push_duration()
  return GRID.push_path * ANIM.move_time / GRID.cell
end

function start_push(cmd, ref, box)
  local d = DIR_DELTA[push_dir(cmd)]
  start_anim("push", push_duration(), ref)
  sfx.jump()
  local anim = player.anim
  local col, row = box.col, box.row
  anim.move_cmd = cmd
  anim.target_col = col
  anim.target_row = row
  anim.box = box
  anim.box_tc = col + d.x
  anim.box_tr = row + d.y
end

function try_push(cmd, ref, box)
  if can_push(box.col, box.row, push_dir(cmd)) then
    start_push(cmd, ref, box)
  else
    start_bump(cmd, ref)
  end
end

function start_move(cmd, ref)
  local tc, tr = move_cmd_target(cmd)
  if is_wall(tc, tr) then
    start_bump(cmd, ref)
  else
    local box = box_at(tc, tr)
    if box then
      try_push(cmd, ref, box)
    else
      start_forward(cmd, ref, tc, tr)
    end
  end
end

function finish_move(a)
  player.col = a.target_col
  player.row = a.target_row
  if a.move_cmd == "F" then
    table.insert(player.traces, {
      c1 = a.from_col,
      r1 = a.from_row,
      c2 = a.target_col,
      r2 = a.target_row
    })
  end
end

ANIM_FINISHERS = { }

function ANIM_FINISHERS.turn(a)
  player.dir = a.target_dir
  check_goal()
end

function ANIM_FINISHERS.move(a)
  finish_move(a)
  check_goal()
end

function ANIM_FINISHERS.bump(a)
  sfx.lose()
  start_anim("fail", ANIM.fail_pause)
  player.anim.move_cmd = a.move_cmd
  player.anim.line = a.line
  player.anim.col_from = a.col_from
  player.anim.col_to = a.col_to
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
  if not player.anim then
    check_box_goals(old, new)
  end
end

-- Level progression

function next_level()
  level_index = level_index + 1
  if #levels < level_index then
    love.event.quit()
  else
    maze = levels[level_index]
    local saved_q = player.queue
    local saved_r = player.queue_refs
    start_level()
    player.queue = saved_q
    player.queue_refs = saved_r
  end
end

CMD_HANDLERS = {
  ["."] = next_level,
  L = start_turn,
  R = start_turn,
  F = start_move,
  B = start_move
}

function on_win()
  cur_progression()
end

function execute_next()
  local cmd, ref = dequeue()
  local fn = CMD_HANDLERS[cmd]
  if fn then
    fn(cmd, ref)
  end
end

function on_fail()
  if GS.won then
    player.queue = { }
    next_level()
  else
    reset_level()
  end
end

ANIM_FINISHERS.fail = on_fail
ANIM_FINISHERS.win = on_win

function finish_anim()
  local a = player.anim
  player.anim = nil
  ANIM_FINISHERS[a.kind](a)
end

-- Update

function advance_anim(dt)
  player.anim.time = player.anim.time + dt
  if player.anim.kind == "win"
       and player.anim.goal
  then
    player.anim.goal.radius = 1 - anim_progress()
  end
  if player.anim.duration <= player.anim.time then
    finish_anim()
  end
end

-- Track offset updaters, one per animation kind.
-- Each adds a delta to player.track_offset_l/r
-- based on the animation's duration and direction.

TRACK_UPDATE = { }

function TRACK_UPDATE.move(a, dt)
  local sign = (a.move_cmd == "F") and -1 or 1
  local d = sign * GRID.cell * dt / (a.duration * GRID.scale)
  player.track_offset_l = player.track_offset_l + d
  player.track_offset_r = player.track_offset_r + d
end

TRACK_UPDATE.push = TRACK_UPDATE.move

function TRACK_UPDATE.turn(a, dt)
  local right = a.target_dir == TURN_RIGHT[a.from_dir]
  local sign = right and 1 or -1
  local d = TRACK.radius * (math.pi / 2) * dt / a.duration
  player.track_offset_l = player.track_offset_l - sign * d
  player.track_offset_r = player.track_offset_r + sign * d
end

function update_track_offsets(dt)
  local fn = TRACK_UPDATE[player.anim.kind]
  if fn then
    fn(player.anim, dt)
  end
end

-- Editor input processing

function record_echo(lines)
  for _, line in ipairs(lines) do
    table.insert(echo_lines, line)
  end
end

function rearm_input()
  if not player.anim and #(player.queue) == 0 then
    input_text("Commands:", string.lines(""))
  end
end

function process_user_input()
  if GS.input:is_empty() then
    rearm_input()
    return 
  end
  local text = string.unlines(GS.input())
  local lines = string.lines(text)
  local offset = #echo_lines
  if process_input(lines, offset) then
    record_echo(lines)
  else
    sfx.wrong()
    input_text("Commands:", string.lines(text))
  end
end

-- Main Loop

tab_was_down = false

function poll_tab_progression()
  local down = love.keyboard.isDown("tab")
  local edge = down and not tab_was_down
  if edge and (GS.celebrating or GS.won) then
    next_level()
  elseif edge then
    sfx.lose()
    reset_level()
  end
  tab_was_down = down
end

function love.update(dt)
  ensure_init()
  poll_tab_progression()
  if player.anim then
    advance_anim(dt)
  end
  if player.anim then
    update_track_offsets(dt)
  elseif not GS.celebrating then
    execute_next()
  end
  if ctrl_update then
    ctrl_update()
  end
end

function love.draw()
  if GS.init then
    draw_scene()
  end
end

SYSTEM_KEYS = { }

function SYSTEM_KEYS.escape()
  love.event.quit()
end

function SYSTEM_KEYS.menu()
  cur_grid = not cur_grid
  sfx.sword()
end

love.mousepressed = SYSTEM_KEYS.menu

function is_shift_down()
  local d = love.keyboard.isDown
  return d("lshift") or d("rshift")
end

function love.keypressed(k)
  if k == "escape" and not is_shift_down() then
    return 
  end
  local fn = SYSTEM_KEYS[k]
  if fn then
    fn()
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
