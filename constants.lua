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
  sprite_h = 100,
  cell_fill = 0.56
}

-- Track animation parameters. All measurements in
-- ROBOT_03 sprite coordinates (viewBox 800 by 800).
-- radius: distance from track center to robot
-- rotation center. left track center x ~ 113,
-- robot center x = 400, so radius ~ 287.
-- bar_step: vertical distance between adjacent
-- bars in a track.

TRACK = {
  radius = 287,
  bar_step = 116
}

-- Box sprite box. cell_fill = 1: box fully covers
-- its cell, matching the current rectangle behavior.

BOX = {
  sprite_w = 100,
  sprite_h = 100,
  cell_fill = 1
}

-- Target sprite box. cell_fill controls the size of
-- the destination star inside its cell.

TARGET = {
  sprite_w = 100,
  sprite_h = 100,
  cell_fill = 0.9
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
