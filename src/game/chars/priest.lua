local Priest = {
    rect = nil
}
Priest.__index = Priest

function Priest.new( )
    local self = setmetatable( {}, Priest )

    self.rect = display.newImageRect(
        "images/characters/priest.png",
        48,
        48
    )

    return self
end

function Priest:move( position )
    self.rect.x = position.x
    self.rect.y = position.y
end


return Priest
