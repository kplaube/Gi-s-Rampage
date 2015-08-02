-- luacheck: globals display transition

local blink = require( "libs.blink" )

local module = {}

function module.new()
    local self = display.newRect( 0, 0, 5, 30 )
    self.isVisible = false

    function self.inside( target, callback )
        self.x = target.x
        self.isVisible = true

        transition.moveBy( self, {
            y=target.y,
            time=600,
            onComplete=self.onTeleportInComplete,
        } )

        blink.blinkScreen( callback )
    end

    function self.out( callback )
        blink.blinkScreen( callback )
    end

    function self.onTeleportInComplete()
        self.isVisible = false
    end

    self:setFillColor( 1, 1, 1 )

    return self
end

return module
