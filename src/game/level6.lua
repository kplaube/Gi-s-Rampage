-----------------------------------------------------------------------------------------
--
-- level6.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local scene = composer.newScene()

function createMap()
    local map = dusk.buildMap(
        "maps/level6.json",
        display.contentWidth,
        display.contentHeight
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    return map
end

function createLevel( sceneGroup )
    map = createMap()

    sceneGroup:insert( map )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    createLevel( sceneGroup )
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )

-----------------------------------------------------------------------------------------

return scene
