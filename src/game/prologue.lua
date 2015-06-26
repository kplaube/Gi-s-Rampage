-----------------------------------------------------------------------------------------
--
-- prologue.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local backgroundMusic
local backgroundMusicChannel

local Fiance = require( "game.chars.fiance" )
local Giselli = require( "game.chars.giselli" )
local Guest = require( "game.chars.wedding_guest" )
local Priest = require( "game.chars.priest" )

local scene = composer.newScene()

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
    gi:turnUp()
    gi:move({ x=227, y=165 })

    map.layer["altar"]:insert(gi.rect)

    return gi
end

function createFiance( map )
    local fiance = Fiance.new()
    fiance:turnUp()
    fiance:move({ x=253, y=165 })

    map.layer["altar"]:insert(fiance.rect)

    return fiance
end

function createPriest( map )
    local priest = Priest.new()
    priest:move({ x=240, y=130 })

    map.layer["altar"]:insert(priest.rect)
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

        map.layer["altar"]:insert(guest.rect)

        guest:move( position )
    end

    return guests
end

function createLevel( sceneGroup )
    local map = createMap()
    local priest = createPriest( map )
    local finance = createFiance( map )
    local gi = createGiselli( map )
    local guests = createGuests( map )

    backgroundMusic = audio.loadStream( "musics/prologue.mp3" )

    sceneGroup:insert( map )
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

    backgroundMusicChannel = audio.play( backgroundMusic, {
        channel=1,
        loops=-1
    } )
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
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
