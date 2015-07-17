-- luacheck: globals display timer, ignore event self
-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local TextDialog = require( "libs.dialog" )
local blink = require( "libs.blink" )

local Giselli = require( "game.chars.giselli" )
local Guardian = require(  "game.chars.guardian1" )

local level = display.newGroup()
local scene = composer.newScene()
local sceneDialogs = {
    [1] = {
        "Guardião: Eu sou o guardião dessa dimensão! Buahahahaha!",
        "Guardião: Seu noivo? Ele passou por aqui sim...",
        "Guardião: Mas por ser muito branco, não resistiu ao sol e foi aprisionado na próxima dimensão.",
        "Guardião: Eu só permitirei que você prossiga se você me ajudar a montar um barco.",
        "Guardião: Meu superior disse que isso me ajudaria no relacionamento com os meus colegas guardiões...",
        "Guardião: Me ajude a coletar 4 itens necessários: Vela, Remo, Madeira e Corda.",
        "Guardião: Eles estão escondidos nos barris."
    }
}

function level:setMap()
    display.setDefault("minTextureFilter", "nearest")
    display.setDefault("magTextureFilter", "nearest")

    local map = dusk.buildMap(
        "maps/level1.json",
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

function level:createGuardian()
    local guardian = Guardian.new()
    guardian.x, guardian.y = 0, 190
    guardian.isVisible = false

    self.map.layer["characters"]:insert(guardian)

    self.guardian = guardian
end

function level:startLevel()
    timer.performWithDelay( 500, function()
        blink.blinkScreen( function()
            self.gi.isVisible = true

            timer.performWithDelay( 250, function()
                self:beforeFirstDialog()
            end )
        end )
    end )
end

function level:beforeFirstDialog()
    self.gi:turnLeft()
    self.guardian.isVisible = true
    self.guardian:walkRight( 210, function()
        self.textDialog:startDialog()
    end )
end

function level:onFirstDialogEnds()
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:setMap()
    level:createGiselli()
    level:createGuardian()

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

    level:startLevel()
end

function scene:destroy( event )
    level.textDialog = nil
    sceneDialogs = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
--scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
