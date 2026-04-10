-- levels.lua

-- Each level is an array of strings with a controls field.

corridor = {
  "######",
  "#N  *#",
  "######",
  controls = keys
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
  controls = editor
}

levels = { 
  corridor, 
  sokoban 
}
