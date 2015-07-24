-- luacheck: globals audio display native timer transition onBarrelTap, ignore event self
-----------------------------------------------------------------------------------------
--
-- level2.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local blink = require( "libs.blink" )
local TextDialog = require( "libs.dialog" )

local Giselli = require( "game.chars.giselli" )
local Guardian = require(  "game.chars.guardian2" )
local Crowd = require( "game.chars.crowd" )

local scene = composer.newScene()
local level = display.newGroup()

-----------------------------------------------------------------------------------------

level.sceneDialogs = {
    [1] = {
        "Guardião: Eu sou o guardião dessa dimensão! *hic*",
        "Guardião: Seu noivo? *hic* Ele passou por aqui sim...",
        "Guardião: Mas estava muito bêbado e tentando usar o celular.",
        "Guardião: Acabou dormindo sentado, e eu o mandei para a próxima dimensão.",
        "Guardião: Eu só permitirei que você prossiga se vencer o meu desafio.",
        "Guardião: Você pode seguir se me ajudar a tomar 25 melzinhos...",
        "Guardião: Valendo!"
    }
}

function level:createMap()
    display.setDefault("minTextureFilter", "nearest")
    display.setDefault("magTextureFilter", "nearest")

    local map = dusk.buildMap(
        "maps/level2.json",
        display.contentScaleX,
        display.contentScaleY
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    self.map = map
end

function level:createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 430, 140
    gi.isVisible = false

    self.map.layer["characters"]:insert(gi)

    self.gi = gi
end

function level:createGuardian()
    local guardian = Guardian.new()
    guardian.x, guardian.y = 270, 140

    self.map.layer["characters"]:insert(guardian)

    self.guardian = guardian
end

function level:createCrowd()
    local crowd = {
        {x=302, y=260},
        {x=238, y=260},
        {x=174, y=260}
    }

    for i=1, table.getn(crowd) do
        local person = Crowd.new(tostring(i))
        person.x = crowd[i].x
        person.y = crowd[i].y
        person:turnUp()

        self.map.layer["characters"]:insert(person)
    end
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
    level.guardian:turnRight()
    level.gi:walkLeft( 65, function()
        level.textDialog:startDialog()
    end )
end

function level.onFirstDialogEnds()
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:createMap()
    level:createGiselli()
    level:createGuardian()
    level:createCrowd()

    level:setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )

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
    level.map = nil
    level.gi = nil
    level.guardian = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
