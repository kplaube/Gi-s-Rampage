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
local StartLevel = require( "libs.start-level" )

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
        "Guardião: Eu só permitirei que você prossiga se vencer o meu desafio. *hic*",
        "Guardião: Você pode seguir se me ajudar a tomar 20 melzinhos...",
        "Guardião: Valendo!",
        "Guardião: *hic*"
    },
    [2] = {
        "Guardião: Muito bem! *hic*",
        "Guardião: Até parece que você já fez isso antes...",
        "Guardião: Por gratidão te darei essa habilidade.",
        "Giselli aprendeu a arte do debate.",
        "Guardião: Muito *hic* obrigado, e boa sorte!",
        "Giselli debate sobre os fenômenos subjetivos da ciência noética e converte o Guardião."
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
    guardian.x, guardian.y = 270, 135

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
    level.startText:show()
end

function level.gameplayStart()
    level:createObjects()
    level:startHud()
end

function level.startHud()
        level.hud = display.newGroup()

    local rect = display.newRoundedRect(
        level.hud, 0, 0, 120, 40, 4 )

    level.hud.anchorX = 0
    level.hud.anchorY = 0
    level.hud.x = display.contentWidth - 70
    level.hud.y = 30

    level.hud.label = display.newText{
        parent = level.hud,
        text = "Melzinhos: ",
        x = 10, y = 0,
        font = native.systemFont,
        fontSize = 14,
        width = rect.contentWidth
    }
    level.hud.counter = display.newText{
        parent = level.hud,
        text = "20",
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
    local beverage = display.newImageRect(
        "images/objects/beverage.png",
        32, 32)

    beverage.anchorX = 0
    beverage.anchorY = 0

    beverage.positions = {
        {x=35, y=35},
        {x=352, y=160},
        {x=192, y=128},
        {x=64, y=224},
        {x=448, y=128},
        {x=0, y=224},
        {x=128, y=96},
        {x=448, y=288},
        {x=35, y=35},
        {x=192, y=224},
        {x=320, y=128},
        {x=448, y=192},
        {x=256, y=224},
        {x=192, y=0},
        {x=35, y=35},
        {x=384, y=256},
        {x=352, y=160},
        {x=192, y=128},
        {x=128, y=96},
        {x=448, y=288}
    }
    beverage.positionIndex = 1

    function beverage.updatePosition()
        beverage.x = beverage.positions[beverage.positionIndex].x
        beverage.y = beverage.positions[beverage.positionIndex].y
    end

    beverage.updatePosition()
    transition.blink( beverage, {time=1000})

    beverage:addEventListener( "tap", level.onBeverageTap )
    self.map.layer["characters"]:insert(beverage)
end

function level.onBeverageTap( event )
    local counter = tonumber(level.hud.counter.text) - 1

    audio.play( level.rightAnswerSound )
    level.hud.counter.text = counter

    if counter > 0 then
        event.target.positionIndex = event.target.positionIndex + 1
        event.target.updatePosition()

        return false
    end

    event.target.isVisible = false

    level:dispatchEvent{
        name="endGameplay",
        target=level
    }
end

function level.gameplayEnd( event )
    audio.stop( level.backgroundMusicChannel )
    level.victoryMusicChannel = audio.play( level.victoryMusic, {
        channel=1,
        loops=-1
    } )

    level.destroyHud()
    level:setDialog( level.sceneDialogs[2], level.onSecondDialogEnds )

    timer.performWithDelay( 500, function()
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
    composer.gotoScene( "game.level4-intro", "fade", 500 )
end

-----------------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    level:createMap()
    level:createGiselli()
    level:createGuardian()
    level:createCrowd()

    level.backgroundMusic = audio.loadStream( "musics/level2.mp3" )
    level.victoryMusic = audio.loadStream( "musics/victory.mp3" )

    level:setDialog( level.sceneDialogs[1], level.onFirstDialogEnds )
    level.startText = StartLevel.new()
    level.startText:addEventListener( "hideText", level.gameplayStart )
    level:addEventListener( "endGameplay", level.gameplayEnd )

    level.rightAnswerSound = audio.loadSound( "sounds/right.mp3" )

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

    level:startLevel()
end

function scene:hide( event )
    local phase = event.phase

    if phase == "will" then
        audio.stop( level.victoryMusicChannel )
    end
end

function scene:destroy( event )
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
