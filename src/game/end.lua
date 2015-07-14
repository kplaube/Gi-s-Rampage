-- luacheck: globals display, ignore event self
-----------------------------------------------------------------------------------------
--
-- end.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )

local TextDialog = require( "libs.dialog" )

local level = display.newGroup()
local scene = composer.newScene()

local sceneDialogs = {
    [1] = {
        "Essa história não acaba aqui... Na verdade, ela está apenas começando.",
        "O que ela escolheu? Entre casar-se ou juntar-se aos Vingadores?",
        "Só ela pode responder..."
    }
}

function level:startLevel()
    self.textDialog:startDialog()
end

function level:onDialogEnds()
    composer.gotoScene( "game.menu", "fade", 500 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level.textDialog = TextDialog.new()
    level.textDialog:setDialog( sceneDialogs[1], function()
        level:onDialogEnds()
    end)

    sceneGroup:insert( level.textDialog )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        return
    end

    level:startLevel()
end

function scene:destroy( event )
    level.textDialog = nil
    sceneDialogs = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
