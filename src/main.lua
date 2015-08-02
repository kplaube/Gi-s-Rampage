-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

display.setDefault("minTextureFilter", "nearest")
display.setDefault("magTextureFilter", "nearest")

-- load menu screen
composer.gotoScene( "game.level5-intro" )
