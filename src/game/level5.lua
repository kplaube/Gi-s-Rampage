-- luacheck: globals audio display native timer transition onBarrelTap, ignore event self
-----------------------------------------------------------------------------------------
--
-- level5.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local Crowd = require( "game.chars.crowd" )

local scene = composer.newScene()
local level = display.newGroup()

-----------------------------------------------------------------------------------------

function level:createMap()
    display.setDefault("minTextureFilter", "nearest")
    display.setDefault("magTextureFilter", "nearest")

    local map = dusk.buildMap(
        "maps/level5.json",
        display.contentScaleX,
        display.contentScaleY
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    self.map = map
end

function level:createCrowd()
    local crowd = {
        {x=47, y=32},
        {x=47, y=64},
        {x=47, y=96},
        {x=47, y=128},
        {x=47, y=160},
        {x=47, y=192},
        {x=47, y=224},
        {x=47, y=256},

        {x=79, y=32},
        {x=79, y=96},
        {x=79, y=224},

        {x=111, y=32},
        {x=111, y=96},
        {x=111, y=160},
        {x=111, y=224},
        {x=111, y=288},

        {x=143, y=32},
        {x=143, y=96},
        {x=143, y=160},
        {x=143, y=288},

        {x=175, y=32},
        {x=175, y=160},
        {x=175, y=192},
        {x=175, y=224},
        {x=175, y=256},
        {x=175, y=288},

        {x=207, y=32},
        {x=207, y=96},
        {x=207, y=128},
        {x=207, y=160},

        {x=239, y=96},
        {x=239, y=224},
        {x=239, y=256},

        {x=271, y=64},
        {x=271, y=98},
        {x=271, y=160},
        {x=271, y=192},
        {x=271, y=224},

        {x=303, y=64},
        {x=303, y=160},
        {x=303, y=288},

        {x=335, y=64},
        {x=335, y=128},
        {x=335, y=160},
        {x=335, y=224},
        {x=335, y=256},

        {x=367, y=64},
        {x=367, y=128},
        {x=367, y=224},

        {x=399, y=64},
        {x=399, y=128},
        {x=399, y=192},
        {x=399, y=224},

        {x=431, y=64},
        {x=431, y=128},
        {x=431, y=224},

        {x=463, y=128},
        {x=463, y=160},
        {x=463, y=224},
    }
    local j = 1

    for i=1, table.getn(crowd) do
        if j >= 10 then
            j = 1
        else
            j = j + 1
        end

        local person = Crowd.new(tostring(j))
        person.x = crowd[i].x
        person.y = crowd[i].y

        if i % 2 == 0 then
            person:turnLeft()
        elseif i % 3 == 0 then
            person:turnDown()
        else
            person:turnRight()
        end

        self.map.layer["maze"]:insert(person)
    end
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:createMap()
    level:createCrowd()

    sceneGroup:insert( level.map )
end

function scene:destroy( event )
    level.map = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
