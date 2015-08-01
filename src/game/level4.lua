-- luacheck: globals audio display native timer transition onBarrelTap, ignore event self
-----------------------------------------------------------------------------------------
--
-- level4.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local blink = require( "libs.blink" )
local TextDialog = require( "libs.dialog" )
local StartLevel = require( "libs.start-level" )

local Giselli = require( "game.chars.giselli" )
local Guardian = require(  "game.chars.guardian4" )
local Priest = require( "game.chars.priest" )

local scene = composer.newScene()
local level = display.newGroup()

-----------------------------------------------------------------------------------------

level.sceneDialogs = {
    [1] = {
        "Guardião: Eu sou a guardiã dessa dimensão.",
        "Guardião: Seu noivo? Estamos em época de eleições e ele justificou o voto.",
        "Guardião: Fui obrigada a aprisioná-lo na próxima dimensão.",
        "Guardião: Eu só permitirei que você prossiga se você me ajudar a eliminar todos os políticos fazendo boca de urna.",
        "Guardião: Eu pediria para eliminar todos os políticos... Mas sei que você não simpatiza com a anarquia."
    },
    [2] = {
        "Padre: Minha filha, pelos poderes a mim investidos, eu permito o uso de raios laser."
    }
}

function level:createMap()
    display.setDefault("minTextureFilter", "nearest")
    display.setDefault("magTextureFilter", "nearest")

    local map = dusk.buildMap(
        "maps/level4.json",
        display.contentScaleX,
        display.contentScaleY
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    self.map = map
end

function level:createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 256, 96
    gi.isVisible = false

    self.map.layer["characters"]:insert(gi)

    self.gi = gi
end

function level:createGuardian()
    local guardian = Guardian.new()
    guardian.x, guardian.y = 224, 96

    self.map.layer["characters"]:insert(guardian)

    self.guardian = guardian
end

function level:createPriest()
    local priest = Priest.new()
    priest.x, priest.y = 288, 96
    priest.isVisible = false

    self.map.layer["characters"]:insert(priest)

    self.priest = priest
end

function level:createPolitics()

end

function level:setDialog( dialog, callback )
    self.textDialog = TextDialog.new()
    self.textDialog:setDialog( dialog, callback )
end

function level:startLevel()
    timer.performWithDelay( 500, function()
        blink.blinkScreen( function()
            self.gi.isVisible = true
            timer.performWithDelay( 250, level.beforeFirstDialog )
        end )
    end )
end

function level.beforeFirstDialog()
    level.gi:turnLeft()
    level.guardian:turnRight()

    timer.performWithDelay( 500, function()
        level.textDialog:startDialog()
    end )
end

function level.onFirstDialogEnds()
    blink.blinkScreen( function()
        level.priest.isVisible = true
        timer.performWithDelay( 250, level.beforeSecondDialog )
    end )
end

function level.beforeSecondDialog()
    level.gi:turnRight()

    timer.performWithDelay( 500, function()
        level:setDialog( level.sceneDialogs[2], level.onSecondDialogEnds )
        level.textDialog:startDialog()
    end )
end

function level.onSecondDialogEnds()
    blink.blinkScreen( function()
        level.priest.isVisible = false
        level.startText:show()
        level.gi:turnDown()
        level.guardian:turnDown()
    end )
end

function level.gameplayStart()
end

function level.gameplayEnd()
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:createMap()
    level:createGiselli()
    level:createGuardian()
    level:createPriest()
    level:createPolitics()

    level:setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )
    level.startText = StartLevel.new()
    level.startText:addEventListener( "hideText", level.gameplayStart )
    level:addEventListener( "endGameplay", level.gameplayEnd )

    sceneGroup:insert( level.map )
    sceneGroup:insert( level.textDialog )
    sceneGroup:insert( level.startText )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        return
    end

    level:startLevel()
end

function scene:destroy( event )
    level.map = nil
    level.gi = nil
    level.textDialog = nil
    level.startText = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
