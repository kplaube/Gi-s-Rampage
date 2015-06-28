-----------------------------------------------------------------------------------------
--
-- prologue.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )
local TextDialog = require( "libs.dialog" )
local Fiance = require( "game.chars.fiance" )
local Giselli = require( "game.chars.giselli" )
local Guest = require( "game.chars.wedding_guest" )
local Priest = require( "game.chars.priest" )

local backgroundMusic
local backgroundMusicChannel
local map
local priest
local fiance
local gi
local guests

local scene = composer.newScene()
local textDialog = TextDialog.new()
local sceneDialogs = {
    [1] = {
        "Padre: Estamos todos aqui reunidos para celebrar a união de Giselli e Klaus. (pressione)",
        "Convidados: Viva!!! (pressione)",
        "Padre: Vamos para a parte do beijo... (pressione)"
    }
}

function onFirstDialogEnd()
    gi:turnRight()
    fiance:turnLeft()
end

function createMap()
    local map = dusk.buildMap(
        "maps/prologue.json",
        display.contentWidth,
        display.contentHeight
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    return map
end

function createGiselli( map )
    local gi = Giselli.new()
    gi.x, gi.y = 227, 165
    gi:turnUp()

    map.layer["altar"]:insert(gi)

    return gi
end

function createFiance( map )
    local fiance = Fiance.new()
    fiance.x, fiance.y = 253, 165
    fiance:turnUp()

    map.layer["altar"]:insert(fiance)

    return fiance
end

function createPriest( map )
    local priest = Priest.new()
    priest.x, priest.y = 240, 130

    map.layer["altar"]:insert(priest)
end

function createGuests( map )
    local guests = Guest.guestsFactory()
    local guestsPosition = {
        { x=80, y=210},
        { x=80, y=280},
        { x=340, y=280},
        { x=110, y=210},
        { x=140, y=210},
        { x=340, y=210},
        { x=370, y=110},
        { x=140, y=280},
        { x=400, y=210},
        { x=400, y=280}
    }

    for i=1, table.getn(guests) do
        local guest = guests[i]
        local position = guestsPosition[i]
        guest.x, guest.y = position.x, position.y

        map.layer["altar"]:insert(guest)
    end

    return guests
end

function createLevel( sceneGroup )
    map = createMap()
    priest = createPriest( map )
    fiance = createFiance( map )
    gi = createGiselli( map )
    guests = createGuests( map )

    backgroundMusic = audio.loadStream( "musics/prologue.mp3" )
    textDialog:setDialog( sceneDialogs[1], onFirstDialogEnd )

    sceneGroup:insert( map )
    sceneGroup:insert( textDialog )
end

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    createLevel( sceneGroup )
end

function scene:show( event )
    if ( phase == "will" ) then
        return
    end

    --backgroundMusicChannel = audio.play( backgroundMusic, {
    --    channel=1,
    --    loops=-1
    --} )

    timer.performWithDelay( 500, textDialog:startDialogClosure() )
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        audio.stop( backgroundMusicChannel )
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    if backgroundMusic then
        audio.dispose( backgroundMusic )
    end

    backgroundMusic = nil
    backgroundMusicChannel = nil
    sceneDialogs = nil
    textDialog = nil
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
