local Unknown = {
    image = "images/characters/unknown.png",
    imageSheetOption = {
        width = 96,
        height = 96,
        numFrames = 16,

        sheetContentWidth = 384,
        sheetContentHeight = 384
    },
    sequenceData = {
        { name="walking-down", frames={ 1, 2, 3, 4 }, loopCount = 0 },
        { name="walking-left", frames={ 5, 6, 7, 8 }, loopCount = 0 },
        { name="walking-right", frames={ 9, 10, 11, 12 }, loopCount = 0 },
        { name="walking-up", frames={ 13, 14, 15, 16 }, loopCount = 0 }
    }
}

Unknown.imageSheet = graphics.newImageSheet(
    Unknown.image,
    Unknown.imageSheetOption
)

function Unknown.new()
    local self = display.newSprite(
        Unknown.imageSheet,
        Unknown.sequenceData
    )

    function self:turnDown()
        self:setSequence( "walking-down" )
        self:setFrame( 1 )
    end

    function self:turnLeft()
        self:setSequence( "walking-left" )
        self:setFrame( 1 )
    end

    return self
end


return Unknown
