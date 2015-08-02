-- luacheck: globals audio display native physics Runtime timer transition onBarrelTap, ignore event self
-----------------------------------------------------------------------------------------
--
-- level5.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local blink = require( "libs.blink" )
local TextDialog = require( "libs.dialog" )
local StartLevel = require( "libs.start-level" )

local Crowd = require( "game.chars.crowd" )
local Guardian = require( "game.chars.guardian5" )
local Giselli = require( "game.chars.giselli" )

local scene = composer.newScene()
local level = display.newGroup()

-----------------------------------------------------------------------------------------

level.sceneDialogs = {
    [1] = {
        "Guardião: Eu sou a guardiã desta dimensão.",
        "Guardião: Seu noivo? Ele passou por aqui sim, mas foi levado pela multidão até a próxima dimensão.",
        "Guardião: Eu só permitirei que você prossiga se me ajudar com esse pudim.",
        "Guardião: Curiosamente, uma versão alternativa de você quem fez, e está muito bom!",
        "Guardião: Ajude-me levando-o ao ônibus."
    },
    [2] = {
        "Guardião: Muito bem! Até parece que você já fez isso antes...",
        "Guardião: Por gratidão te darei essa habilidade.",
        "Giselli aprendeu sobre a filmografia do Hayao Miyazaki.",
        "Guardião: Muito obrigado, e boa sorte.",
        "Giselli passa as próximas semanas assistindo animações japonesas."
    }
}

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

function level:createGuardian()
    local guardian = Guardian.new()
    guardian.x, guardian.y = 28, 30

    self.map.layer["characters"]:insert(guardian)
    physics.addBody( guardian, "static", { density=3.0, friction=0.5, bounce=0.3 } )

    self.guardian = guardian
end

function level:createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 28, 82
    gi.isVisible = false

    physics.addBody( gi, "dynamic", { density=3.0, friction=0, bounce=0.3 } )
    gi.isFixedRotation = true

    self.map.layer["characters"]:insert(gi)

    self.gi = gi
end

function level:createCrowd()
    local crowd = {
        {x=64, y=32},
        {x=64, y=58},
        {x=64, y=90},
        {x=64, y=122},
        {x=64, y=154},
        {x=64, y=186},
        {x=64, y=218},
        {x=64, y=236},

        {x=98, y=186},

        {x=136, y=86},
        {x=130, y=186},
        {x=136, y=288},

        {x=166, y=86},
        {x=166, y=288},

        {x=200, y=86},
        {x=200, y=122},
        {x=200, y=160},
        {x=200, y=192},
        {x=200, y=224},
        {x=200, y=256},
        {x=200, y=288},

        {x=234, y=86},
        {x=234, y=288},

        {x=268, y=86},
        {x=272, y=186},
        {x=266, y=288},

        {x=302, y=86},
        {x=302, y=186},

        {x=336, y=86},
        {x=336, y=186},
        {x=340, y=234},

        {x=370, y=86},
        {x=370, y=186},

        {x=404, y=86},
        {x=404, y=186},

        {x=428, y=86},
        {x=428, y=186},
        {x=416, y=288},

        {x=460, y=186},
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

        physics.addBody( person, "static", {
            friction=0,
            bounce=1,
        } )

        self.map.layer["maze"]:insert(person)
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
    level.gi:turnUp()
    level.textDialog:startDialog()
end

function level.onFirstDialogEnds()
    level.startText:show()
end

function level.gameplayStart()
    level.map:addEventListener( "tap", level.onMapTap )
    Runtime:addEventListener( "collision", level.onCollision )
end

function level.onCollision( event )
    print( "collision" )

    if event.phase == "ended" then
        level.gi:stopMoving()
    end
end

function level.onMapTap( event )
    if event.y > 292 then
        event.y = 292
    end

    if event.x < 10 then
        event.x = 10
    end

    local newX = (event.x - level.gi.x)
    local newY = (event.y - level.gi.y)

    if math.abs(newX) > math.abs(newY) then
        if event.x > level.gi.x then
            level.gi:walkRight( newX, level.isGameover )
        else
            level.gi:walkLeft( -newX, level.isGameover )
        end
    else
        if event.y > level.gi.y then
            level.gi:walkDown( newY, level.isGameover )
        else
            level.gi:walkUp( -newY, level.isGameover )
        end
    end
end

function level.isGameover()
    if not (level.gi.x > 416 and level.gi.y > 192) then
        return false
    end

    level:dispatchEvent{
        name="endGameplay",
        target=level
    }
end

function level.gameplayEnd()
    level.map:removeEventListener( "tap", level.onMapTap )
    level.guardian.x, level.guardian.y = 382, 236
    level.guardian:turnRight()
    level.gi:turnLeft()

    level:setDialog( level.sceneDialogs[2], level.onSecondDialogEnds )

    timer.performWithDelay( 500, function()
        level.textDialog:startDialog()
    end )
end

function level.onSecondDialogEnds()
    blink.blinkScreen( function ()
        level.gi.isVisible = false

        timer.performWithDelay( 500, level.endLevel )
    end )
end

function level.endLevel()
    composer.gotoScene( "game.level6-intro", "fade", 500 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    physics.start()
    --physics.setDrawMode("hybrid")
    physics.setGravity( 0, 0 )

    level:createMap()
    level:createCrowd()
    level:createGuardian()
    level:createGiselli()

    level:setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )
    level.startText = StartLevel.new()
    level.startText:addEventListener( "hideText" , level.gameplayStart )
    level:addEventListener( "endGameplay", level.gameplayEnd )

    sceneGroup:insert( level.map )
    sceneGroup:insert( level.guardian )
    sceneGroup:insert( level.gi )
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
    level.guardian = nil
    level.gi = nil
    level.textDialog = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
