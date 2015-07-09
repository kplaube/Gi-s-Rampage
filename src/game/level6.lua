-- luacheck: globals blink display timer, ignore event self
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
    }
}

function level:setMap()
    local map = dusk.buildMap(
        "maps/level6.json",
        display.contentWidth,
        display.contentHeight
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
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:setMap()
    level:createGiselli()
    level:createFiance()

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
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
