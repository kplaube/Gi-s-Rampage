-- luacheck: globals display, ignore event self
-----------------------------------------------------------------------------------------
--
-- end.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local TextDialog = require( "libs.dialog" )

local level = {}
local scene = composer.newScene()

level.sceneDialogs = {
    [1] = {
        "Essa história não acaba aqui... Na verdade, ela está apenas começando.",
        "O que ela escolheu? Entre casar-se ou juntar-se aos Vingadores?",
        "Só ela pode responder..."
    }
}

function level.setDialog( dialog, callback )
    level.textDialog = TextDialog.new()
    level.textDialog:setDialog( dialog, callback )
end

function level.startLevel()
    level.textDialog:startDialog()
end

function level.onDialogEnds()
    composer.gotoScene( "game.menu", "fade", 1000 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level.setDialog( level.sceneDialogs[1], level.onDialogEnds )

    sceneGroup:insert( level.textDialog )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        return
    end

    level.startLevel()
end

function scene:destroy( event )
    level = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
