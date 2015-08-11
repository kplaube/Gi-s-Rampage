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
    self.moveTime = 1000

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

    function self:walkLeft( deltaX, callback )
        self:setSequence( "walking-left" )
        self:play()
        self:move( self.x - deltaX, self.y, callback )
    end

    function self:walkRight( deltaX, callback )
        self:setSequence( "walking-right" )
        self:play()
        self:move( self.x + deltaX, self.y, callback )
    end

    function self:walkDown( deltaY, callback )
        self:setSequence( "walking-down" )
        self:play()
        self:move( self.x, self.y + deltaY, callback )
    end

    function self:walkUp( deltaY, callback )
        self:setSequence( "walking-up" )
        self:play()
        self:move( self.x, self.y - deltaY, callback )
    end

    function self:move( deltaX, deltaY, callback )
        transition.moveTo( self, {
          x = deltaX,
          y = deltaY,
          time = self.moveTime,
          onComplete = function ()
              self:pause()
              self:setSequence( self.sequence )

              if callback then
                  callback()
              end
          end
        } )
    end

    function self:stopMoving()
        self:pause()
        transition.cancel( self )
    end

    return self
end

return Char
