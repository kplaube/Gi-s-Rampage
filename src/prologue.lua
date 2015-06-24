-----------------------------------------------------------------------------------------
--
-- prologue.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local dusk = require( "Dusk.Dusk" )

---------------------------------------------------------------------------------
function levelIntro( sceneGroup )
    local map = dusk.buildMap(
        "maps/prologue.json",
        display.contentWidth,
        display.contentHeight
    )
    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    sceneGroup:insert( map )
end

function scene:create( event )
    local sceneGroup = self.view

    levelIntro( sceneGroup )
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )

---------------------------------------------------------------------------------

return scene
