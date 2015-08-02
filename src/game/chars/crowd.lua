-- luacheck: ignore self

local Char = require( "game.chars.base" );

local Crowd = {
    imageSheetOption = {
        width = 32,
        height = 48,
        numFrames = 16,

        sheetContentWidth = 128,
        sheetContentHeight = 192
    },
    sequenceData = {
        { name="walking-down", frames={ 1, 2, 3, 4 }, loopCount = 0 },
        { name="walking-left", frames={ 5, 6, 7, 8 }, loopCount = 0 },
        { name="walking-right", frames={ 9, 10, 11, 12 }, loopCount = 0, time=300 },
        { name="walking-up", frames={ 13, 14, 15, 16 }, loopCount = 0 },
        { name="lasers", frames={ 17, 18, 19, 20, 21, 22, 23, 24 }, loopCount = 1, time=800 }
    }
}

function Crowd.new(number)
    Crowd.image = "images/characters/crowd" .. number .. ".png"
    local self = Char.new(Crowd)

    return self
end


return Crowd
