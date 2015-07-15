-- luacheck: globals audio display, ignore event self
-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require( "widget" )

local playBtn
local backgroundMusic
local backgroundMusicChannel

local scene = composer.newScene()

local function onPlayBtnRelease()
    composer.gotoScene( "game.prologue-intro", "fade", 500 )
end

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    local background = display.newImageRect(
        "images/menu-background.png",
        display.contentWidth,
        display.contentHeight
    )
    background.anchorX = 0
    background.anchorY = 0
    background.x, background.y = 0, 0

    local titleLogo = display.newText{
        font="Adventure",
        fontSize=64,
        text="Gi's Rampage",
        x=display.contentWidth * 0.5,
        y=100
    }
    titleLogo:setFillColor( 254/255, 246/255, 81/255 )

    playBtn = widget.newButton{
        font="PressStart2P",
        fontSize=16,
        label="Começar aventura!",
        labelColor={ default={255}, over={128} },
        onRelease=onPlayBtnRelease
    }
    playBtn.x = display.contentWidth * 0.5
    playBtn.y = display.contentHeight - 125

    backgroundMusic = audio.loadStream( "musics/menu.mp3" )
    backgroundMusicChannel = audio.play( backgroundMusic, {
        channel=1,
        loops=-1
    } )

    sceneGroup:insert( background )
    sceneGroup:insert( titleLogo )
    sceneGroup:insert( playBtn )
end

function scene:hide( event )
    local phase = event.phase

    if phase == "will" then
        audio.stop( backgroundMusicChannel )
    end
end

function scene:destroy( event )
    if playBtn then
        playBtn:removeSelf()
    end

    if backgroundMusic then
        audio.dispose( backgroundMusic )
    end

    playBtn = nil
    backgroundMusic = nil
    backgroundMusicChannel = nil
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
