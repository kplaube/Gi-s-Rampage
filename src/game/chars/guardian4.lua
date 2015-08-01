-- luacheck: ignore self

local Char = require( "game.chars.base" );

local Guardian1 = {
    image = "images/characters/guardian4.png",
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

function Guardian1.new()
    return Char.new(Guardian1)
end

return Guardian1
