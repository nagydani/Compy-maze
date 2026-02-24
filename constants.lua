-- constants.lua

-- Animation durations in seconds

ANIM = {
  move_time = 1,
  turn_time = 1,
  bump_frac = 0.5,
  fail_pause = 0.5,
  win_time = 0.5
}

-- Turtle drawing sizes 

TURTLE = {
  head_r = 8,
  leg_xr = 5,
  leg_yr = 10,
  body_xr = 15,
  body_yr = 20,
  neck = 5,
  leg_angle = math.pi / 4,
  fit_factor = 5
}

LEGEND = readfile("legend.txt")
