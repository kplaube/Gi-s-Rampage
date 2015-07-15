-- luacheck: globals audio display timer, ignore event self
-----------------------------------------------------------------------------------------
--
-- prologue.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local TextDialog = require( "libs.dialog" )
local blink = require( "libs.blink" )

local Fiance = require( "game.chars.fiance" )
local Giselli = require( "game.chars.giselli" )
local Guest = require( "game.chars.wedding_guest" )
local Priest = require( "game.chars.priest" )
local Unknown = require( "game.chars.unknown" )

local level = display.newGroup()

local scene = composer.newScene()
local sceneDialogs = {
    [1] = {
        "Padre: Estamos todos aqui reunidos para celebrar a união de Giselli e Klaus.",
        "Convidados: Viva!!!",
        "Padre: Vamos para a parte do beijo..."
    },
    [2] = {
        "Vilão: Este casamento abalará as estruturas de todos os multi-versos...",
        "Vilão: ... de uma forma que nem todos os vídeos de gatinhos da internet, juntos, abalarão!",
        "Vilão: Não posso permitir que isso aconteça!"
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

function level:setMap()
    display.setDefault("minTextureFilter", "nearest")
    display.setDefault("magTextureFilter", "nearest")

    local map = dusk.buildMap(
        "maps/prologue.json",
        display.contentWidth,
        display.contentHeight
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    self.map = map
end

function level:createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 227, 165
    gi:turnUp()

    self.map.layer["altar"]:insert(gi)

    self.gi = gi
end

function level:createFiance()
    local fiance = Fiance.new()
    fiance.x, fiance.y = 253, 165
    fiance:turnUp()

    self.map.layer["altar"]:insert(fiance)

    self.fiance = fiance
end

function level:createPriest()
    local priest = Priest.new()
    priest.x, priest.y = 240, 130

    self.map.layer["altar"]:insert(priest)

    self.priest = priest
end

function level:createGuests()
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

        self.map.layer["altar"]:insert(guest)
    end

    self.guests = guests
end

function level:createUnknown()
    local unknown = Unknown.new()
    unknown.x, unknown.y = 320, 140
    unknown.isVisible = false

    self.map.layer["altar"]:insert(unknown)

    self.unknown = unknown
end

function level:startLevel()
    timer.performWithDelay( 500, function () self.textDialog:startDialog() end )
end

function level:onFirstDialogEnds()
    self.gi:turnRight()
    self.fiance:turnLeft()

    blink.blinkScreen(function()
        self.unknown.isVisible = true

        self.textDialog = TextDialog.new()
        self.textDialog:setDialog( sceneDialogs[2], function()
            self:onSecondDialogEnds()
        end )

        timer.performWithDelay( 500, function ()
            self.fiance:turnRight()
            self.textDialog:startDialog()
        end )
    end)
end

function level:onSecondDialogEnds()
    self.unknown:turnLeft()

    timer.performWithDelay( 500, function ()

        blink.blinkScreen(function()
            self.fiance.isVisible = false
            self.unknown.isVisible = false

            self.gi:walkRight( 12, function ()
                self.gi:turnUp()

                self.textDialog = TextDialog.new()
                self.textDialog:setDialog( sceneDialogs[3], function()
                  level:onThirdDialogEnds()
                end )
                self.textDialog:startDialog()
            end )
        end )
    end )
end

function level:onThirdDialogEnds()
    self.gi:addEventListener( "sprite", function( event )
        if event.phase ~= "ended" then
            return
        end

        timer.performWithDelay( 500, function ()
            self.gi:turnUp()

            self.textDialog = TextDialog.new()
            self.textDialog:setDialog( sceneDialogs[4], function()
                self:onFourtyDialogEnds()
            end )
            self.textDialog:startDialog()
        end )
    end )

    self.gi:enableLasers()
end

function level:onFourtyDialogEnds()
    blink.blinkScreen(function()
        self.gi.isVisible = false

        self.textDialog = TextDialog.new()
        self.textDialog:setDialog( sceneDialogs[5], function()
            self.onFiftyDialogEnds()
        end )
        self.textDialog:startDialog()
    end )
end

function level.onFiftyDialogEnds()
    composer.gotoScene( "game.level6-intro", "fade", 500 )
end

---------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:setMap()
    level:createPriest()
    level:createFiance()
    level:createGiselli()
    level:createGuests()
    level:createUnknown()

    level.backgroundMusic = audio.loadStream( "musics/prologue.mp3" )
    level.textDialog = TextDialog.new()
    level.textDialog:setDialog( sceneDialogs[1], function()
        level:onFirstDialogEnds()
    end)

    sceneGroup:insert( level.map )
    sceneGroup:insert( level.textDialog )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        return
    end

    level.backgroundMusicChannel = audio.play( level.backgroundMusic, {
        channel=1,
        loops=-1
    } )

    level:startLevel()
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

    level.backgroundMusic = nil
    level.backgroundMusicChannel = nil
    level.textDialog = nil
    sceneDialogs = nil
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
