local Fiance = {
    imageSheetOption = {
        width = 32,
        height = 48,
        numFrames = 16,

        sheetContentWidth = 128,
        sheetContentHeight = 192
    }
}
Fiance.__index = Fiance

Fiance.imageSheet = graphics.newImageSheet(
    "images/characters/fiance.png",
    Fiance.imageSheetOption
)

function Fiance.new()
    local self = setmetatable( {}, Fiance )

    self.rect = self:_getImage(1)

    return self
end

function Fiance:_getImage( frame )
    return display.newImageRect( self.imageSheet, frame, 32, 48 )
end

function Fiance:move( position )
    self.rect.x = position.x
    self.rect.y = position.y
end

function Fiance:turnUp()
    self.rect:removeSelf()
    self.rect = self:_getImage(13)
end


return Fiance
