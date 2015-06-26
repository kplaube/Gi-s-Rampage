-----------------------------------------------------------------------------------------
--
-- prologue.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local Fiance = require( "characters.fiance" )
local Giselli = require( "characters.giselli" )
local Guest = require( "characters.wedding_guest" )
local Priest = require( "characters.priest" )

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

    sceneGroup:insert( map )
end

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    createLevel( sceneGroup )
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )

---------------------------------------------------------------------------------

return scene
