-- luacheck: globals audio display, ignore event self
-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require( "widget" )

local level = {}
local scene = composer.newScene()

function level.onPlayBtnRelease()
    composer.gotoScene( "game.prologue-intro", "fade", 500 )
end

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level.background = display.newImageRect(
        "images/menu-background.png",
        display.contentWidth,
        display.contentHeight
    )
    level.background.anchorX = 0
    level.background.anchorY = 0
    level.background.x, level.background.y = 0, 0

    level.titleLogo = display.newText{
        font="PressStart2P",
        fontSize=32,
        text="Gi's Rampage",
        x=display.contentWidth * 0.5,
        y=100
    }
    level.titleLogo:setFillColor( 254/255, 246/255, 81/255 )


    level.playBtn = display.newText{
        font="PressStart2P",
        fontSize=16,
        text="Começar aventura!",
    }
    level.playBtn.x = display.contentWidth * 0.5
    level.playBtn.y = display.contentHeight - 125
    level.playBtn:addEventListener( "tap", level.onPlayBtnRelease)

    level.backgroundMusic = audio.loadStream( "musics/menu.mp3" )
    level.backgroundMusicChannel = audio.play( level.backgroundMusic, {
        channel=1,
        loops=-1
    } )

    sceneGroup:insert( level.background )
    sceneGroup:insert( level.titleLogo )
    sceneGroup:insert( level.playBtn )
end

function scene:hide( event )
    local phase = event.phase

    if phase == "will" then
        audio.stop( level.backgroundMusicChannel )
    end
end

function scene:destroy( event )
    if level.backgroundMusic then
        audio.dispose( level.backgroundMusic )
    end

    level = nil
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
