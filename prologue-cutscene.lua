-----------------------------------------------------------------------------------------
--
-- prologue-cutscene.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
function levelIntro( sceneGroup )
    local sceneTitleText = display.newText{
        font="PressStart2P",
        fontSize=16,
        text="Cutscene",
        x=display.contentWidth * 0.5,
        y=display.contentHeight * 0.5
    }

    sceneGroup:insert( sceneTitleText )
end

function scene:create( event )
    local sceneGroup = self.view

    levelIntro( sceneGroup )
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )

---------------------------------------------------------------------------------

return scene
