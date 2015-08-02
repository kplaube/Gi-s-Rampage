-- luacheck: globals display timer, ignore event
-----------------------------------------------------------------------------------------
--
-- level4-intro.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local function gotoNextLevel()
    composer.gotoScene( "game.level4", "fade", 500 )
end

---------------------------------------------------------------------------------
function scene:create( event )
    local sceneGroup = self.view

    local sceneTitleText = display.newText{
        font="PressStart2P",
        fontSize=16,
        text="A eleição",
        x=display.contentWidth * 0.5,
        y=display.contentHeight * 0.5
    }

    sceneGroup:insert( sceneTitleText )

    timer.performWithDelay( 2000, gotoNextLevel, 1 )
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )

---------------------------------------------------------------------------------

return scene
