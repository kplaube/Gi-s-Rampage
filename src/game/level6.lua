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

local level = {}
local scene = composer.newScene()

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
                level:beforeFirstDialog()
            end )
        end )
    end )
end

function level:beforeFirstDialog()
    self.gi:turnRight()
    self.fiance.isVisible = true
    self.fiance:walkLeft( 210, function() end )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:setMap()
    level:createGiselli()
    level:createFiance()

    sceneGroup:insert( level.map )
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        return
    end

    level:startLevel()
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

-----------------------------------------------------------------------------------------

return scene
