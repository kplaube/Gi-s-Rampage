-- luacheck: globals audio blink display timer, ignore event self
-----------------------------------------------------------------------------------------
--
-- level6.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local TextDialog = require( "libs.dialog" )
local blink = require( "libs.blink" )

local Giselli = require( "game.chars.giselli" )
local Fiance = require( "game.chars.fiance" )
local Fury = require( "game.chars.fury" )

local level = display.newGroup()
local scene = composer.newScene()
local sceneDialogs = {
    [1] = {
        "Noivo: Endlich habe ich Dich gefunden!",
        "Noivo: Espero que tenha gostado da aventura… essa aventura que começou há 1 ano atrás."
    },
    [2] = {
        "Noivo: O que eu acho mais mágico sobre a gente, é que por mais diferentes que sejamos, por mais diferentes que nossos caminhos tenham sido (...)",
        "Noivo: (...) terminaríamos juntos. Não há como discutir.",
        "Noivo: Em todas as realidades, de todas as dimensões possíveis, quando trata-se da gente, o destino é inexorável.",
        "Noivo: O universo se dobrará e fará com que terminemos juntos.",
        "Noivo: Eu cruzaria as dimensões para te encontrar, mas graças a essa força superior, não precisei.",
        "Noivo: Achei a pessoa mais fantástica do mundo, aqui mesmo, nessa realidade.",
        "Noivo: Giselli Brasil dos Santos...",
        "Noivo: Você quer casar comigo?"
    },
    [3] = {
        "Fury: Finalmente te encontrei, Giselli!",
        "Fury: Testemunhei todas as suas proezas até aqui e realmente, (...)",
        "Fury: Ou você é um ser místico ou pertence à outra dimensão.",
        "Fury: ...",
        "Fury: Você já ouviu falar da iniciativa Vingadores?"
    }
}

function level:setMap()
    display.setDefault("minTextureFilter", "nearest")
    display.setDefault("magTextureFilter", "nearest")

    local map = dusk.buildMap(
        "maps/level6.json",
        display.contentScaleX,
        display.contentScaleY
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0


    self.map = map
end

function level:createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 240, 190
    gi.isVisible = false

    self.map.layer["characters"]:insert(gi)

    self.gi = gi
end

function level:createFiance()
    local fiance = Fiance.new()
    fiance.x, fiance.y = 480, 190
    fiance.isVisible = false

    self.map.layer["characters"]:insert(fiance)

    self.fiance = fiance
end

function level:createFury()
    local fury = Fury.new()
    fury.x, fury.y = 240, 0
    fury.isVisible = false

    self.map.layer["characters"]:insert(fury)

    self.fury = fury
end

function level:startLevel()
    timer.performWithDelay( 500, function()
        blink.blinkScreen(function()
            self.gi.isVisible = true

            timer.performWithDelay( 250, function()
                self:beforeFirstDialog()
            end )
        end )
    end )
end

function level:beforeFirstDialog()
    self.gi:turnRight()
    self.fiance.isVisible = true
    self.fiance:walkLeft( 210, function()
        self.textDialog:startDialog()
    end )
end

function level:onFirstDialogEnds()
    self.fiance:turnDown()

    timer.performWithDelay( 500, function()
        self.textDialog = TextDialog.new()
        self.textDialog:setDialog( sceneDialogs[2], function()
            self:onSecondDialogEnds()
        end )
        self.textDialog:startDialog()
    end )
end

function level:onSecondDialogEnds()
    self.fury.isVisible = true
    self.fury:walkDown( 160, function()
        self.gi:turnUp()
        self.fiance:turnUp()

        self.textDialog = TextDialog.new()
        self.textDialog:setDialog( sceneDialogs[3], function()
            self:onThirdDialogEnds()
        end )
        self.textDialog:startDialog()
    end )
end

function level:onThirdDialogEnds()
    composer.gotoScene( "game.end", "fade", 500 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:setMap()
    level:createFury()
    level:createGiselli()
    level:createFiance()

    level.backgroundMusic = audio.loadStream( "musics/level6.mp3" )
    level.textDialog = TextDialog.new()
    level.textDialog:setDialog( sceneDialogs[1], function()
        level:onFirstDialogEnds()
    end )

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

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
