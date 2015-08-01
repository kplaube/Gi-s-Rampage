-- luacheck: globals transition, ignore self

local Char = require( "game.chars.base" );

local Politic = {
    image = {
        "images/characters/politic1.png",
        "images/characters/politic2.png",
        "images/characters/politic3.png",
        "images/characters/politic4.png",
        "images/characters/politic1.png",
        "images/characters/politic2.png"
    },
    imageSheetOption = {
        width = 32,
        height = 48,
        numFrames = 16,

        sheetContentWidth = 128,
        sheetContentHeight = 192
    },
    sequenceData = {
        { name="walking-down", frames={ 1, 2, 3, 4 }, loopCount = 0, time=300 },
        { name="walking-left", frames={ 5, 6, 7, 8 }, loopCount = 0, time=300 },
        { name="walking-right", frames={ 9, 10, 11, 12 }, loopCount = 0, time=300 },
        { name="walking-up", frames={ 13, 14, 15, 16 }, loopCount = 0, time=300 }
    }
}

function Politic.new(index)
    local politic = {
        image = Politic.image[index],
        imageSheetOption = Politic.imageSheetOption,
        sequenceData = Politic.sequenceData
    }
    local self = Char.new(politic)

    function self:move()
        if self.x < 400 then
            self:turnRight()
            self:walkRight( 450, function()
                self:move()
            end )
        else
            self:turnLeft()
            self:walkLeft( 450, function()
                self:move()
            end )
            return
        end
    end

    function self:die()
        self.isVisible = false
    end

    function self:stopMoving()
        self:pause()
        transition.cancel( self )
    end

    return self
end


return Politic
