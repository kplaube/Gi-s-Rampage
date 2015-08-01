-- luacheck: globals display graphics transition, ignore self
local Char = {}

function Char.new(options)
    local imageSheet = graphics.newImageSheet(
        options.image,
        options.imageSheetOption
    )

    local self = display.newSprite(
        imageSheet,
        options.sequenceData
    )

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

    function self:turnUp()
        self:setSequence( "walking-up" )
        self:setFrame( 1 )
    end

    function self:walkLeft( deltaX, onComplete )
        self:setSequence( "walking-left" )
        self:play()

        transition.moveTo( self, {
          x = self.x - deltaX,
          y = self.y,
          time = 2000,
          onComplete = function ()
              self:pause()

              onComplete()
          end
        } )
    end

    function self:walkRight( deltaX, onComplete )
        self:setSequence( "walking-right" )
        self:play()

        transition.moveTo( self, {
            x = self.x + deltaX,
            y = self.y,
            time = 2000,
            onComplete = function ()
                self:pause()

                onComplete()
            end
        } )
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

return Char
