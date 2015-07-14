-- luacheck: globals display graphics transition, ignore self
local Fury = {
    image = "images/characters/fury.png",
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

Fury.imageSheet = graphics.newImageSheet(
    Fury.image,
    Fury.imageSheetOption
)

function Fury.new()
    local self = display.newSprite(
        Fury.imageSheet,
        Fury.sequenceData
    )

    function self:turnUp()
        self:setSequence( "walking-up" )
        self:setFrame( 1 )
    end

    function self:turnDown()
        self:setSequence( "walking-down" )
        self:setFrame( 1 )
    end

    function self:turnLeft()
        self:setSequence( "walking-left" )
        self:setFrame( 1 )
    end

    function self:turnRight()
        self:setSequence( "walking-right" )
        self:setFrame( 1 )
    end

    function self:walkDown( deltaY, onComplete )
        self:setSequence( "walking-down" )
        self:play()

        transition.moveTo( self, {
          x = self.x,
          y = self.y + deltaY,
          time = 1000,
          onComplete = function ()
              self:pause()

              onComplete()
          end
        } )
    end

    return self
end


return Fury
