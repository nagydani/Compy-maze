-- constants.lua

-- Animation durations in seconds

ANIM = {
  move_time = 1,
  turn_time = 1,
  bump_frac = 0.5,
  fail_pause = 0.5,
  win_time = 0.5
}

-- Player sprite box; cell_fill < 1 leaves room
-- for the bump animation to show movement.

PLAYER = {
  sprite_w = 100,
  sprite_h = 120,
  cell_fill = 0.56
}

-- Movement trail style

TRACE = {
  radius_frac = 0.08
}

-- Legends

LEGEND_FULL = readfile("legend.txt")

-- Keyboard macro limits

MAX_MACRO_LEN = 7

-- Primitive commands 

PRIMITIVES = {
  N = true,
  E = true,
  S = true,
  W = true,
  F = true,
  B = true,
  L = true,
  R = true,
  ["."] = true
}

-- Celebrate message

CELEBRATE_TEXT = "Congratulations! Press Enter to proceed."
