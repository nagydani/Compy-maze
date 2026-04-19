-- decorations.lua

-- Transpiled SVG sprites and backgrounds.
-- Each require(...) loads the module once; the
-- module returns a draw function that can be
-- called every frame without re-creating paths.

-- Player sprite drawn by draw_player_at.
-- Rendered at origin of a PLAYER.sprite_w by
-- PLAYER.sprite_h box; caller centers, rotates
-- and scales.

player_sprite = require("turtle")

-- Background draw functions. Each draws over the
-- whole screen. Assign one to a level's
-- `background` attribute in levels.lua. If a level
-- has no `background`, draw_walls falls back to a
-- solid blue fill.

bg1 = require("BACKGROUND_DRAFT_001")
bg2 = require("BACKGROUND_DRAFT_002")
bg3 = require("BACKGROUND_DRAFT_003")
bg4 = require("BACKGROUND_DRAFT_04")
