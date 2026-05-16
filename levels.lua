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
  grid = true,
  background = bg1
}

-- Level 2: one turn

one_turn = {
  "#####",
  "#  *#",
  "#   #",
  "#N  #",
  "#####",
  legend = LEGEND_FULL,
  background = bg2
}

-- Level 3: two turns, longer path

two_turns = {
  "#####",
  "#*  #",
  "# ###",
  "#   #",
  "### #",
  "#  N#",
  "#####",
  legend = LEGEND_FULL,
  background = bg3
}

two_turns2 = {
  "#####",
  "#*  #",
  "# ###",
  "#   #",
  "### #",
  "#  N#",
  "#####",
  controls = editor,
  progression = portal,
  legend = LEGEND_FULL,
  background = bg4
}

-- Level 4: longer path with dead ends

dead_ends = {
  "######",
  "# # *#",
  "#    #",
  "## # #",
  "#    #",
  "#N## #",
  "######",
  progression = celebrate,
  legend = LEGEND_FULL,
  background = bg2
}


maze5 = {
  "#########",
  "#   #   #",
  "# # # # #",
  "# #   # #",
  "# ### # #",
  "#N    #*#",
  "#########",
  legend = LEGEND_FULL,
  background = bg3
}

maze6 = {
  "#########",
  "#E      #",
  "### ### #",
  "#   #   #",
  "# ### ###",
  "#     * #",
  "#########",
  legend = LEGEND_FULL,
  background = bg5
}

maze7 = {
  "##########",
  "#   #    #",
  "# # # ## #",
  "# #   #W #",
  "# ########",
  "#       *#",
  "##########",
  legend = LEGEND_FULL,
  background = bg3
}

maze8 = {
  "##########",
  "#E   #   #",
  "# ## ### #",
  "#        #",
  "#### # ###",
  "#    # * #",
  "##########",
  legend = LEGEND_FULL,
  background = bg2
}

maze9 = {
  "###########",
  "#   #     #",
  "# # # ### #",
  "# #   #*  #",
  "# ### ### #",
  "#N  #     #",
  "###########",
  grid = false,
  controls = "editor",
  legend = LEGEND_FULL,
  background = bg1
}

maze10 = {
  "############",
  "#   #      #",
  "# # # #### #",
  "# #   #    #",
  "# ##### ####",
  "#E    #   *#",
  "############",
  legend = LEGEND_FULL,
  background = bg4
}

maze11 = {
  "################",
  "#       #      #",
  "# ##### # #### #",
  "#     # #    # #",
  "##### # #### # #",
  "#E    #      #*#",
  "################",
  legend = LEGEND_FULL,
  background = bg1
}

maze12 = {
  "###############",
  "#      #      #",
  "# #### # #### #",
  "#    # #    # #",
  "#### # #### # #",
  "#E B        #*#",
  "###############",
  legend = LEGEND_FULL,
  background = bg3
}

maze13 = {
  "########",
  "###G####",
  "### ####",
  "###B BG#",
  "#G BN###",
  "####B###",
  "####G###",
  "########",
  legend = LEGEND_FULL,
  progression = celebrate,
  background = bg2
}

maze14 = {
  "#########",
  "#E  #####",
  "# BB#####",
  "# B ###G#",
  "### ###G#",
  "###    G#",
  "##   #  #",
  "##   ####",
  "#########",
  legend = LEGEND_FULL,
  progression = celebrate,
  background = bg4
}

maze15 = {
  "##########",
  "##     ###",
  "##B###   #",
  "# N B  B #",
  "# GG# B ##",
  "##GG#   ##",
  "##########",
  legend = LEGEND_FULL,
  background = bg1
}

levels = {
  intro,
  one_turn,
  two_turns,
  two_turns2,
  dead_ends,
  maze5,
  maze6,
  maze7,
  maze8,
  maze9,
  maze10,
  maze11,
  maze12,
  maze13,
  maze14,
  maze15
}
