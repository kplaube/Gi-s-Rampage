-- luacheck: globals audio display graphics, ignore self transition
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
        { name="walking-down", frames={ 1, 2, 3, 4 }, loopCount = 0 },
        { name="walking-left", frames={ 5, 6, 7, 8 }, loopCount = 0 },
        { name="walking-right", frames={ 9, 10, 11, 12 }, loopCount = 0, time=300 },
        { name="walking-up", frames={ 13, 14, 15, 16 }, loopCount = 0 },
        { name="lasers", frames={ 17, 18, 19, 20, 21, 22, 23, 24 }, loopCount = 1, time=800 }
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

    function self:turnDown()
        self:setSequence( "walking-down" )
        self:setFrame( 1 )
    end

    function self:turnRight()
        self:setSequence( "walking-right" )
        self:setFrame( 1 )
    end

    function self:turnUp()
        self:setSequence( "walking-up" )
        self:setFrame( 1 )
    end

    function self:walkRight( deltaX, onComplete )
        self:setSequence( "walking-right" )
        self:play()

        transition.moveTo( self, {
            x = self.x + deltaX,
            y = self.y,
            time = 300,
            onComplete = function ()
                self:pause()

                onComplete()
            end
        } )
    end

    function self:enableLasers()
        self:setSequence( "lasers" )
        self:play()
    end

    return self
end


return Giselli
