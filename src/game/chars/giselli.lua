-- luacheck: ignore self

local Char = require( "game.chars.base" );

local Giselli = {
    image = "images/characters/giselli.png",
    imageSheetOption = {
        width = 32,
        height = 48,
        numFrames = 24,

        sheetContentWidth = 128,
        sheetContentHeight = 288
    },
    sequenceData = {
        { name="walking-down", frames={ 1, 2, 3, 4 }, time=300 },
        { name="walking-left", frames={ 5, 6, 7, 8 }, time=300 },
        { name="walking-right", frames={ 9, 10, 11, 12 }, time=300 },
        { name="walking-up", frames={ 13, 14, 15, 16 }, time=300 },
        { name="lasers", frames={ 17, 18, 19, 20, 21, 22, 23, 24 }, loopCount = 1, time=800 }
    }
}

function Giselli.new()
    local self = Char.new(Giselli)

    function self:enableLasers()
        self:setSequence( "lasers" )
        self:play()
    end

    return self
end


return Giselli
