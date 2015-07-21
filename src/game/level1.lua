-- luacheck: globals audio display native timer transition onBarrelTap, ignore event self
-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local dusk = require( "Dusk.Dusk" )

local TextDialog = require( "libs.dialog" )
local StartLevel = require( "libs.start-level" )
local blink = require( "libs.blink" )

local Giselli = require( "game.chars.giselli" )
local Guardian = require(  "game.chars.guardian1" )

local scene = composer.newScene()
local level = display.newGroup()

-----------------------------------------------------------------------------------------

level.sceneDialogs = {
    [1] = {
        "Guardião: Eu sou o guardião dessa dimensão! Buahahahaha!",
        "Guardião: Seu noivo? Ele passou por aqui sim...",
        "Guardião: Mas por ser muito branco, não resistiu ao sol e foi aprisionado na próxima dimensão.",
        "Guardião: Eu só permitirei que você prossiga se você me ajudar a montar um barco.",
        "Guardião: Meu superior disse que isso me ajudaria no relacionamento com os meus colegas guardiões...",
        "Guardião: Me ajude a coletar 4 itens necessários: Vela, Remo, Madeira e Corda.",
        "Guardião: Eles estão escondidos nos barris."
    },
    [2] = {
        "Guardião: Muito bem! Até parece que você já fez isso antes.",
        "Guardião: Por gratidão te darei essa habilidade.",
        "Giselli aprendeu a sambar.",
        "Guardião: Muito obrigado, e boa sorte!",
        "Giselli sambou na cara da sociedade."
    }
}

function level:createMap()
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
    level.guardian.isVisible = true
    level.guardian:walkRight( 210, function()
        level.textDialog:startDialog()
    end )
end

function level.onFirstDialogEnds()
    level.gi:turnUp()
    level.guardian:turnUp()

    level.startText:show()
end

function level:gameplayStart()
    level:createObjects()
    level:startHud()
end

function level.startHud()
    level.hud = display.newGroup()

    local rect = display.newRoundedRect(
        level.hud, 0, 0, 100, 40, 4 )

    level.hud.anchorX = 0
    level.hud.anchorY = 0
    level.hud.x = display.contentWidth - 60
    level.hud.y = 30

    level.hud.label = display.newText{
        parent = level.hud,
        text = "Itens: ",
        x = 10, y = 0,
        font = native.systemFont,
        fontSize = 14,
        width = rect.contentWidth
    }
    level.hud.counter = display.newText{
        parent = level.hud,
        text = "0",
        x = -10, y = 0,
        font = native.systemFont,
        fontSize = 14,
        width = rect.contentWidth,
        align = "right"
    }

    rect:setFillColor{
        type = "gradient",
        color1={ 1/255, 1/255, 1/255, 0.9 },
        color2={ 1/255, 1/255, 1/255, 0.6 },
        direction="down"
    }
end

function level.destroyHud()
    level.hud.isVisible = false
    level.hud:remove()
end

function level:createObjects()
    local barrel
    local positions = {
        {50, 50, true},
        {140, 100, false},
        {320, 220, false},
        {200, 120, false},
        {400, 250, true},
        {100, 280, false},
        {400, 60, true},
        {300, 50, true},
        {20, 210, false},
        {400, 200, false}
    }
    self.barrels = {}

    for i=1, 10 do
        barrel = display.newImageRect(
            "images/objects/barrel.png",
            32, 38
        )
        barrel.anchorX = 0
        barrel.anchorY = 0

        barrel.x = positions[i][1]
        barrel.y = positions[i][2]
        barrel.hasItem = positions[i][3]

        barrel:addEventListener( "tap", level.onBarrelTap)
        self.map.layer["characters"]:insert(barrel)

        self.barrels[i] = barrel
    end
end

function level.onBarrelTap( event )
    local number = tonumber(level.hud.counter.text) + 1
    event.target.isVisible = false

    if not event.target.hasItem then
        audio.play( level.wrongAnswerSound )
        return false
    end

    audio.play( level.rightAnswerSound )
    level.hud.counter.text = number

    if number == 4 then
        level:dispatchEvent{
            name="endGameplay",
            target=level
        }
    end
end

function level.gameplayEnd( event )
    audio.stop( level.backgroundMusicChannel )
    level.victoryMusicChannel = audio.play( level.victoryMusic, {
        channel=1,
        loops=-1
    } )

    level.destroyHud()
    level:setDialog( level.sceneDialogs[2], level.onSecondDialogEnds )

    timer.performWithDelay( 500, function ()
        level.gi:turnLeft()
        level.guardian:turnRight()
        level.textDialog:startDialog()
    end )
end

function level.onSecondDialogEnds()
    blink.blinkScreen(function()
        level.gi.isVisible = false

        timer.performWithDelay( 500, level.endLevel)
    end )
end

function level.endLevel()
    composer.gotoScene( "game.menu", "fade", 500 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:createMap()
    level:createGiselli()
    level:createGuardian()

    level.backgroundMusic = audio.loadStream( "musics/level1.mp3" )
    level.victoryMusic = audio.loadStream( "musics/victory.mp3" )
    level.rightAnswerSound = audio.loadSound( "sounds/right.mp3" )
    level.wrongAnswerSound = audio.loadSound( "sounds/wrong.mp3" )

    level:setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )
    level.startText = StartLevel.new()
    level.startText:addEventListener( "hideText", level.gameplayStart)
    level:addEventListener( "endGameplay", level.gameplayEnd )

    sceneGroup:insert( level.map )
    sceneGroup:insert( level.gi )
    sceneGroup:insert( level.guardian )
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

    level:startLevel()
end

function scene:hide( event )
    local phase = event.phase

    if phase == "will" then
        audio.stop( level.victoryMusicChannel )
    end
end

function scene:destroy( event )
    if level.victoryMusic then
        audio.dispose( level.victoryMusic )
    end

    if level.backgroundMusic then
        audio.dispose( level.backgroundMusic )
    end

    level.backgroundMusic = nil
    level.backgroundMusicChannel = nil
    level.victoryMusic = nil
    level.victoryMusicChannel = nil
    level.map = nil
    level.gi = nil
    level.guardian = nil
    level.textDialog = nil
    level.startText = nil
    level.sceneDialogs = nil
end

-----------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
