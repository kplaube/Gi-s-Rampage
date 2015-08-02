-- luacheck: globals audio display timer, ignore event self
-----------------------------------------------------------------------------------------
--
-- level6.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )
local TextDialog = require( "libs.dialog" )
local Teleport = require( "libs.teleport" )

local Giselli = require( "game.chars.giselli" )
local Fiance = require( "game.chars.fiance" )
local Fury = require( "game.chars.fury" )

local level = display.newGroup()
local scene = composer.newScene()

level.sceneDialogs = {
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

function level.createMap()
    local map = dusk.buildMap(
        "maps/level6.json",
        display.contentScaleX,
        display.contentScaleY
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    level.map = map
end

function level.createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 240, 190
    gi.isVisible = false

    level.map.layer["characters"]:insert(gi)
    level.gi = gi
end

function level.createFiance()
    local fiance = Fiance.new()
    fiance.x, fiance.y = 480, 190
    fiance.isVisible = false

    level.map.layer["characters"]:insert(fiance)
    level.fiance = fiance
end

function level.createFury()
    local fury = Fury.new()
    fury.x, fury.y = 240, 0
    fury.isVisible = false

    level.map.layer["characters"]:insert(fury)
    level.fury = fury
end

function level.setDialog( dialog, callback )
    level.textDialog = TextDialog.new()
    level.textDialog:setDialog( dialog, callback )
end

function level.startLevel()
    timer.performWithDelay( 500, function()
        level.teleport.inside( level.gi, function()
            level.gi.isVisible = true

            timer.performWithDelay( 250, level.beforeFirstDialog )
        end )
    end )
end

function level.beforeFirstDialog()
    level.gi:turnRight()
    level.fiance.isVisible = true
    level.fiance:walkLeft( 210, function()
        level.textDialog:startDialog()
    end )
end

function level.onFirstDialogEnds()
    level.fiance:turnDown()

    timer.performWithDelay( 500, function()
        level.setDialog( level.sceneDialogs[2], level.onSecondDialogEnds )
        level.textDialog:startDialog()
    end )
end

function level.onSecondDialogEnds()
    level.fury.isVisible = true
    level.fury:walkDown( 160, function()
        level.gi:turnUp()
        level.fiance:turnUp()

        level.setDialog( level.sceneDialogs[3], level.onThirdDialogEnds )
        level.textDialog:startDialog()
    end )
end

function level.onThirdDialogEnds()
    composer.gotoScene( "game.end", "fade", 500 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level.createMap()
    level.createFury()
    level.createGiselli()
    level.createFiance()

    level.backgroundMusic = audio.loadStream( "musics/level6.mp3" )

    level.setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )
    level.teleport = Teleport.new()

    sceneGroup:insert( level.map )
    sceneGroup:insert( level.textDialog )
    sceneGroup:insert( level.teleport )
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

    level.startLevel()
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

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
