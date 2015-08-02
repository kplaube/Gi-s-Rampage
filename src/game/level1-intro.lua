-- luacheck: globals display timer, ignore event self
-----------------------------------------------------------------------------------------
--
-- level1-intro.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local StartLevel = require( "libs.start-level" )

local level = {}
local scene = composer.newScene()

function level.startLevel()
    timer.performWithDelay( 2000, level.gotoNextLevel, 1 )
end

function level.gotoNextLevel()
    composer.gotoScene( "game.level1", "fade", 500 )
end

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level.sceneTitleText = StartLevel.newStartText( "A Praia" )
    level.startLevel()

    sceneGroup:insert(level.sceneTitleText)
end

function scene:destroy( event )
    level = nil
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
