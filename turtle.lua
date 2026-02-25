-- turtle.lua

-- Compass directions

-- How each direction moves on the grid

DIR_DELTA = { }

DIR_DELTA.N = {
  x = 0,
  y = -1
}
DIR_DELTA.S = {
  x = 0,
  y = 1
}
DIR_DELTA.W = {
  x = -1,
  y = 0
}
DIR_DELTA.E = {
  x = 1,
  y = 0
}

-- N <-> S, E <-> W

OPPOSITE_DIR = {
  N = "S",
  S = "N",
  E = "W",
  W = "E"
}

-- N -> E -> S -> W (clockwise)

TURN_RIGHT = {
  N = "E",
  E = "S",
  S = "W",
  W = "N"
}

-- N -> W -> S -> E (counter-clockwise)

TURN_LEFT = {
  N = "W",
  W = "S",
  S = "E",
  E = "N"
}

-- Turn an absolute command into relative ones.

function compile_absolute(target, facing)
  if target == facing then
    return "F"
  elseif target == OPPOSITE_DIR[facing] then
    return "B"
  elseif target == TURN_RIGHT[facing] then
    return "R"
  else
    return "L"
  end
end

-- Turtle state

turtle = {
  col = 1,
  row = 1,
  dir = "N",
  queue = { },
  anim = nil,
  traces = { },
  color = nil
}

function turtle_reset(col, row, dir)
  turtle.col = col
  turtle.row = row
  turtle.dir = dir
  turtle.queue = { }
  turtle.anim = nil
  turtle.traces = { }
  turtle.color = nil
end

-- Command queue

function process_cmd(k)
  local cmd = string.upper(k)
  if DIR_DELTA[cmd]
       or cmd == "L"
       or cmd == "R"
       or cmd == "F"
       or cmd == "B"
  then
    table.insert(turtle.queue, cmd)
    return true
  end
  return false
end

-- Dequeue the next relative command

function dequeue()
  local cmd = table.remove(turtle.queue, 1)
  if not DIR_DELTA[cmd] then
    return cmd
  end
  local rel = compile_absolute(cmd, turtle.dir)
  if rel == "R" or rel == "L" then
    table.insert(turtle.queue, 1, "F")
  end
  return rel
end

-- Animation state

function start_anim(kind, duration)
  turtle.anim = {
    kind = kind,
    time = 0,
    duration = duration,
    from_col = turtle.col,
    from_row = turtle.row,
    from_dir = turtle.dir
  }
end

function anim_progress()
  return turtle.anim.time / turtle.anim.duration
end
