-- luacheck: globals audio display native physics Runtime timer transition onBarrelTap, ignore event self
-----------------------------------------------------------------------------------------
--
-- level5.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )
local Teleport = require( "libs.teleport" )
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

function level.createMap()
    local map = dusk.buildMap(
        "maps/level5.json",
        display.contentScaleX,
        display.contentScaleY
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    level.map = map
end

function level.createGuardian()
    local guardian = Guardian.new()
    guardian.x, guardian.y = 28, 30

    level.map.layer["characters"]:insert(guardian)
    physics.addBody( guardian, "static", {
        density=3.0
    } )

    level.guardian = guardian
end

function level.createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 28, 82
    gi.isVisible = false

    level.map.layer["characters"]:insert(gi)
    physics.addBody( gi, "dynamic", {
        density=3.0,
        bounce=10
    } )
    gi.isFixedRotation = true
    gi:addEventListener( "preCollision", level.onCollision )

    level.gi = gi
end

function level.createCrowd()
    local crowd = {
        {x=64, y=32},
        {x=64, y=42},
        {x=64, y=52},
        {x=64, y=62},
        {x=64, y=72},
        {x=64, y=82},
        {x=64, y=92},
        {x=64, y=102},
        {x=64, y=112},
        {x=64, y=122},
        {x=64, y=132},
        {x=64, y=142},
        {x=64, y=152},
        {x=64, y=162},
        {x=64, y=172},
        {x=64, y=182},
        {x=64, y=192},
        {x=64, y=202},
        {x=64, y=212},
        {x=64, y=222},
        {x=64, y=232},
        {x=64, y=236},

        {x=98, y=186},

        {x=136, y=86},
        {x=130, y=186},
        {x=136, y=288},

        {x=166, y=86},
        {x=166, y=288},

        {x=200, y=86},
        {x=200, y=90},
        {x=200, y=100},
        {x=200, y=110},
        {x=200, y=120},
        {x=200, y=130},
        {x=200, y=140},
        {x=200, y=150},
        {x=200, y=160},
        {x=200, y=170},
        {x=200, y=180},
        {x=200, y=190},
        {x=200, y=200},
        {x=200, y=210},
        {x=200, y=220},
        {x=200, y=230},
        {x=200, y=240},
        {x=200, y=250},
        {x=200, y=260},
        {x=200, y=270},
        {x=200, y=280},
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
        {x=450, y=288},
    }
    local walls = {
        {x=54, y=16, width=20, height=238},
        {x=76, y=170, width=60, height=30},
        {x=128, y=74, width=310, height=30},
        {x=190, y=74, width=20, height=238},
        {x=126, y=276, width=150, height=30},
        {x=264, y=170, width=210, height=30},
        {x=330, y=200, width=20, height=56},
        {x=410, y=276, width=70, height=30},
    }
    local j = 1

    for i=1, table.getn(walls) do
        local wall = display.newRect(
            walls[i].x, walls[i].y, walls[i].width, walls[i].height
        )
        wall.anchorX, wall.anchorY = 0, 0
        level.map.layer["maze"]:insert(wall)
        physics.addBody( wall, "kinematic", {
            density=3.0
        } )
        wall.isFixedRotation = true
    end

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

        level.map.layer["maze"]:insert(person)
    end
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
    level.gi:turnUp()
    level.textDialog:startDialog()
end

function level.onFirstDialogEnds()
    level.startText:show()
end

function level.gameplayStart()
    level.map:addEventListener( "tap", level.onMapTap )
end

function level.onCollision( event )
    level.gi:stopMoving()

    timer.performWithDelay(50, function()
        if level.gi.sequence == 'walking-right' then
            level.gi.x = level.gi.x - 1
        elseif level.gi.sequence == 'walking-left' then
            level.gi.x = level.gi.x + 1
        elseif level.gi.sequence == "walking-up" then
            level.gi.y = level.gi.y + 1
        elseif level.gi.sequence == "walking-down" then
            level.gi.y = level.gi.y - 1
        end
    end )
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

    audio.stop( level.backgroundMusicChannel )
    level.victoryMusicChannel = audio.play( level.victoryMusic, {
        channel=1,
        loops=-1
    } )

    level.setDialog( level.sceneDialogs[2], level.onSecondDialogEnds )

    timer.performWithDelay( 500, function()
        level.textDialog:startDialog()
    end )
end

function level.onSecondDialogEnds()
    level.teleport.out( function ()
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

    level.createMap()
    level.createCrowd()
    level.createGuardian()
    level.createGiselli()

    level.backgroundMusic = audio.loadStream( "musics/level5.mp3" )
    level.victoryMusic = audio.loadStream( "musics/victory.mp3" )

    level.setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )
    level.startText = StartLevel.new()
    level.startText:addEventListener( "hideText" , level.gameplayStart )
    level:addEventListener( "endGameplay", level.gameplayEnd )
    level.teleport = Teleport.new()

    sceneGroup:insert( level.map )
    sceneGroup:insert( level.textDialog )
    sceneGroup:insert( level.startText )
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
    if level.victoryMusic then
        audio.dispose( level.victoryMusic )
    end

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
