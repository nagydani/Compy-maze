-- decorations.lua

-- Transpiled SVG sprites and backgrounds.
-- Each require(...) loads the module once; the
-- module returns a draw function that can be
-- called every frame without re-creating paths.

-- Player sprite parts drawn by draw_player_at.
-- All four rendered in the same PLAYER.sprite_w by
-- PLAYER.sprite_h box; caller centers, rotates and
-- scales. Drawn in z-order back -> tracks -> front.

robot_back = require("ROBOT_03_a")
robot_track_l = require("ROBOT_03_b1")
robot_track_r = require("ROBOT_03_b2")
robot_front = require("ROBOT_03_c")

-- Box sprite drawn by draw_boxes.
-- Rendered at origin of a BOX.sprite_w by
-- BOX.sprite_h box; caller positions and scales.

box_sprite = require("BOX_03")

-- Target sprite drawn by draw_goals.
-- Rendered at origin of a TARGET.sprite_w by
-- TARGET.sprite_h box; caller positions and scales.

target_sprite = require("TARGET_02")

-- Background draw functions. Each draws over the
-- whole screen. Assign one to a level's
-- `background` attribute in levels.lua. If a level
-- has no `background`, draw_walls falls back to a
-- solid blue fill.

bg1 = require("LABIRINT_NEW_01")
bg2 = require("LABIRINT_NEW_02")
bg3 = require("LABIRINT_NEW_03")
bg4 = require("LABIRINT_NEW_04")
bg5 = require("LABIRINT_NEW_05")
