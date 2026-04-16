-- levels.lua

-- Each level is an array of strings with attributes.

-- Level 1: straight line, 2-3 moves
intro = {
  "####",
  "#* #",
  "#  #",
  "#N #",
  "####",
  controls = keys,
  progression = celebrate,
  legend = LEGEND_FULL,
  grid = true
}

-- Level 2: one turn
one_turn = {
  "#####",
  "#  *#",
  "#   #",
  "#N  #",
  "#####",
  legend = LEGEND_FULL,
  grid = false
}

-- Level 3: two turns, longer path
two_turns = {
  "#####",
  "#*  #",
  "# # #",
  "#   #",
  "# # #",
  "#  N#",
  "#####",
  legend = LEGEND_FULL
}

two_turns2 = {
  "#####",
  "#*  #",
  "# # #",
  "#   #",
  "# # #",
  "#  N#",
  "#####",
  controls = editor,
  progression = portal,
  legend = LEGEND_FULL
}

-- Level 4: moderate complexity
moderate_complexity = {
  "######",
  "#*## #",
  "#    #",
  "# ## #",
  "#    #",
  "#N   #",
  "######",
  legend = LEGEND_FULL
}

-- Level 5: longer path with dead ends
dead_ends = {
  "######",
  "# # *#",
  "#    #",
  "## # #",
  "#    #",
  "#N## #",
  "######",
  progression = continue,
  legend = LEGEND_FULL
}

levels = {
  intro,
  one_turn,
  two_turns,
  two_turns2,
  moderate_complexity,
  dead_ends
}
