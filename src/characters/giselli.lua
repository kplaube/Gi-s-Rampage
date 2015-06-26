local Giselli = {
    imageSheetOption = {
        width = 32,
        height = 48,
        numFrames = 16,

        sheetContentWidth = 128,
        sheetContentHeight = 192
    }
}
Giselli.__index = Giselli

Giselli.imageSheet = graphics.newImageSheet(
    "images/characters/giselli.png",
    Giselli.imageSheetOption
)

function Giselli.new()
    local self = setmetatable( {}, Giselli )

    self.rect = self:_getImage(1)

    return self
end

function Giselli:_getImage( frame )
    return display.newImageRect( self.imageSheet, frame, 32, 48)
end

function Giselli:move( position )
    self.rect.x = position.x
    self.rect.y = position.y
end

function Giselli:turnUp()
    self.rect:removeSelf()
    self.rect = self:_getImage(13)
end


return Giselli
