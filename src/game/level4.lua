-- luacheck: globals audio display graphics native timer transition onBarrelTap, ignore event self
-----------------------------------------------------------------------------------------
--
-- level4.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )
local Teleport = require( "libs.teleport" )
local TextDialog = require( "libs.dialog" )
local StartLevel = require( "libs.start-level" )

local Giselli = require( "game.chars.giselli" )
local Guardian = require(  "game.chars.guardian4" )
local Priest = require( "game.chars.priest" )
local Politic = require( "game.chars.politic" )

local scene = composer.newScene()
local level = {}

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
    },
    [3] = {
        "Guardião: Muito bem! Até parece que você já fez isso antes...",
        "Guardião: Por gratidão te darei essa habilidade.",
        "Giselli aprendeu a Constituição Federal.",
        "Guardião: Muito obrigado, e boa sorte.",
        "Giselli ensina ao Guardião sobre a CLT, e lança a sua candidatura a prefeita."
    }
}

function level.createMap()
    local map = dusk.buildMap(
        "maps/level4.json",
        display.contentScaleX,
        display.contentScaleY
    )

    map.anchorX, map.anchorY = 0, 0
    map.x, map.y = 0, 0

    level.map = map
end

function level.createGiselli()
    local gi = Giselli.new()
    gi.x, gi.y = 256, 96
    gi.isVisible = false

    level.map.layer["characters"]:insert(gi)
    level.gi = gi
end

function level.createGuardian()
    local guardian = Guardian.new()
    guardian.x, guardian.y = 224, 96

    level.map.layer["characters"]:insert(guardian)
    level.guardian = guardian
end

function level.createPriest()
    local priest = Priest.new()
    priest.x, priest.y = 288, 96
    priest.isVisible = false

    level.map.layer["characters"]:insert(priest)
    level.priest = priest
end

function level.createPolitics()
    local positions = {
        {16, 192},
        {16, 224},
        {16, 256},
        {460, 192},
        {460, 224},
        {460, 256},
    }
    level.politics = {}

    for i=1, table.getn(positions) do
        local politic = Politic.new(i)
        politic.x = positions[i][1]
        politic.y = positions[i][2]
        politic:moveAround()

        table.insert(level.politics, politic)
        level.map.layer["characters"]:insert(politic)
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
    level.gi:turnLeft()
    level.guardian:turnRight()

    timer.performWithDelay( 500, function()
        level.textDialog:startDialog()
    end )
end

function level.onFirstDialogEnds()
    level.teleport.inside( level.priest, function()
        level.priest.isVisible = true
        timer.performWithDelay( 250, level.beforeSecondDialog )
    end )
end

function level.beforeSecondDialog()
    level.gi:turnRight()

    timer.performWithDelay( 500, function()
        level.setDialog( level.sceneDialogs[2], level.onSecondDialogEnds )
        level.textDialog:startDialog()
    end )
end

function level.onSecondDialogEnds()
    level.teleport.out( function()
        level.priest.isVisible = false
        level.startText:show()
        level.gi:turnDown()
        level.guardian:turnDown()
    end )
end

function level.gameplayStart()
    level.politicsDead = 0
    level.explosionImagesheet = graphics.newImageSheet(
        "images/objects/explosion.png",
        {
            width=64,
            height=64,
            numFrames=16,

            sheetContentWidth=256,
            sheetContentHeight=256,
        }
    )
    level.explosion = display.newSprite( level.explosionImagesheet, {
        name="explode",
        loopCount=0,
        start=1,
        count=16
    } )
    level.explosion.isVisible = false

    function level.explosion:explode( x, y )
        level.explosion.x = x
        level.explosion.y = y
        level.explosion.isVisible = true

        level.explosion:setSequence( "explode" )
        level.explosion:play()

        timer.performWithDelay( 500, function ()
            level.explosion:pause()
            level.explosion.isVisible = false
        end )
    end

    level.map:addEventListener( "tap" , level.onMapTap )

    for i=1, table.getn(level.politics) do
        local politic = level.politics[i]
        politic:addEventListener( "tap", level.onPoliticTap )
    end
end

function level.onMapTap( event )
    level.gi:enableLasers()
    level.explosion:explode( event.x, event.y )
    audio.play( level.shooting )
end

function level.onPoliticTap( event )
    event.target:stopMoving()

    timer.performWithDelay( 250, function()
        event.target:die()
        level.politicsDead = level.politicsDead + 1
        audio.play( level.rightAnswerSound )

        if level.politicsDead == table.getn(level.politics) then
            level:dispatchEvent{
                name="endGameplay",
                target=level
            }
        end
    end )
end

function level.gameplayEnd()
    level.map:removeEventListener( "tap", level.onMapTap )
    level.gi:turnLeft()
    level.guardian:turnRight()

    audio.stop( level.backgroundMusicChannel )
    level.victoryMusicChannel = audio.play( level.victoryMusic, {
        channel=1,
        loops=-1
    } )

    level.setDialog( level.sceneDialogs[3], level.onThirdDialogEnds )

    timer.performWithDelay( 500, function()
        level.textDialog:startDialog()
    end )
end

function level.onThirdDialogEnds()
    level.teleport.out( function()
        level.gi.isVisible = false

        timer.performWithDelay( 500, level.endLevel )
    end )
end

function level.endLevel()
    composer.gotoScene( "game.level5-intro", "fade", 500 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level.createMap()
    level.createGiselli()
    level.createGuardian()
    level.createPriest()
    level.createPolitics()

    level.setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )
    level.startText = StartLevel.new()
    level.startText:addEventListener( "hideText", level.gameplayStart )
    level:addEventListener( "endGameplay", level.gameplayEnd )
    level.teleport = Teleport.new()

    level.backgroundMusic = audio.loadStream( "musics/level4.mp3" )
    level.victoryMusic = audio.loadStream( "musics/victory.mp3" )
    level.rightAnswerSound = audio.loadSound( "sounds/right.mp3" )
    level.shooting = audio.loadSound( "sounds/small-fire.mp3" )

    sceneGroup:insert( level.map )
    sceneGroup:insert( level.textDialog )
    sceneGroup:insert( level.startText )
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
    if level.victoryMusic then
        audio.dispose( level.victoryMusic )
    end

    if level.backgroundMusic then
        audio.dispose( level.backgroundMusic )
    end

    if level.rightAnswerSound then
        audio.dispose( level.rightAnswerSound )
    end

    if level.shooting then
        audio.dispose( level.shooting )
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
