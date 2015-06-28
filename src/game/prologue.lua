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
local Unknown = require( "game.chars.unknown" )

local backgroundMusic
local backgroundMusicChannel
local map
local priest
local fiance
local gi
local guests
local unknown

local scene = composer.newScene()
local textDialog = TextDialog.new()
local sceneDialogs = {
    [1] = {
        "Padre: Estamos todos aqui reunidos para celebrar a união de Giselli e Klaus.",
        "Convidados: Viva!!!",
        "Padre: Vamos para a parte do beijo..."
    },
    [2] = {
        "Desconhecido: Este casamento abalará as estruturas de todos os multi-versos...",
        "Desconhecido: ... de uma forma que nem todos os vídeos de gatinhos da internet, juntos, abalarão!",
        "Desconhecido: Não posso permitir que isso aconteça!"
    },
    [3] = {
        "Padre: Giselli, minha filha!",
        "Padre: Você não pode permitir que isso aconteça!",
        "Padre: Pelos poderes a mim investidos, eu lhe concedo...",
        "Padre: VISÃO DE RAIO LASER."
    },
    [4] = {
        "Padre: Filha, tome esse livro de física quântica, e teleporte-se atrás de seu guri!",
        "Giselli pegou o livro \"A vida explicada pela física quântica\"",
        "Giselli aprendeu teleporte."
    },
    [5] = {
        "Padre: Que a força esteja com você!"
    }
}

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

    return priest
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

function createUnknown()
    local unknown = Unknown.new()
    unknown.x, unknown.y = 320, 140
    unknown.isVisible = false

    map.layer["altar"]:insert(unknown)

    return unknown
end

function createLevel( sceneGroup )
    map = createMap()
    priest = createPriest( map )
    fiance = createFiance( map )
    gi = createGiselli( map )
    guests = createGuests( map )
    unknown = createUnknown( map )

    backgroundMusic = audio.loadStream( "musics/prologue.mp3" )
    textDialog:setDialog( sceneDialogs[1], onFirstDialogEnds )

    sceneGroup:insert( map )
    sceneGroup:insert( textDialog )
end

function startScene()
    timer.performWithDelay( 500, function () textDialog:startDialog() end )
end

function onFirstDialogEnds()
    gi:turnRight()
    fiance:turnLeft()

    unknown.isVisible = true

    textDialog = TextDialog.new()
    textDialog:setDialog( sceneDialogs[2], onSecondDialogEnds )

    timer.performWithDelay( 500, function ()
        fiance:turnRight()
        textDialog:startDialog()
    end )
end

function onSecondDialogEnds()
    unknown:turnLeft()

    timer.performWithDelay( 500, function ()
        fiance.isVisible = false
        unknown.isVisible = false

        gi:walkRight( 12, function ()
            gi:turnUp()

            textDialog = TextDialog.new()
            textDialog:setDialog( sceneDialogs[3], onThirdDialogEnds )
            textDialog:startDialog()
        end )
    end )
end

function onThirdDialogEnds()
    gi:turnDown()

    timer.performWithDelay( 500, function ()
        gi:turnUp()

        textDialog = TextDialog.new()
        textDialog:setDialog( sceneDialogs[4], onFourtyDialogEnds )
        textDialog:startDialog()
    end)
end

function onFourtyDialogEnds()
    gi.isVisible = false

    textDialog = TextDialog.new()
    textDialog:setDialog( sceneDialogs[5], onFiftyDialogEnds )
    textDialog:startDialog()
end

function onFiftyDialogEnds()
    composer.gotoScene( "game.level6-intro", "fade", 500 )
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

    startScene()
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
