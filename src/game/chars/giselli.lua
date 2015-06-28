local Giselli = {
    image = "images/characters/giselli.png",
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
        { name="walking-right", frames={ 9, 10, 11, 12 }, loopCount = 0 },
        { name="walking-up", frames={ 13, 14, 15, 16 }, loopCount = 0 }
    }
}

Giselli.imageSheet = graphics.newImageSheet(
    Giselli.image,
    Giselli.imageSheetOption
)

function Giselli.new()
    local self = display.newSprite(
        Giselli.imageSheet,
        Giselli.sequenceData
    )

    function self:turnUp()
        self:setSequence( "walking-up" )
        self:setFrame( 1 )
    end

    return self
end


return Giselli
