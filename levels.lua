-- levels.lua

-- Each level is an array of strings with attributes.

corridor = {
  "######",
  "#N  *#",
  "######",
  controls = editor,
  progression = celebrate,
  legend = LEGEND_FULL,
  grid = true
}

sokoban = {
  "  ###   ",
  "  #G#   ",
  "  # ####",
  "###B BG#",
  "#G BN###",
  "####B#  ",
  "   #G#  ",
  "   ###  ",
  controls = keys,
  progression = portal,
  legend = LEGEND_FULL
}

levels = {
  corridor,
  sokoban
}
