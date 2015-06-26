local Guest = {
    imageSheetOption = {
        width = 32,
        height = 48,
        numFrames = 10,

        sheetContentWidth = 320,
        sheetContentHeight = 48
    },
    imageSheet = nil,
    rect = nil
}
Guest.__index = Guest

Guest.imageSheet = graphics.newImageSheet(
    "images/characters/guests.png",
    Guest.imageSheetOption
)

function Guest.new( frame )
    local self = setmetatable( {}, Guest )

    self.rect = display.newImageRect( self.imageSheet, frame, 32, 48 )

    return self
end

function Guest.guestsFactory()
    local guests = {}

    for i=1, Guest.imageSheetOption.numFrames do
        guests[i] = Guest.new( i )
    end

    return guests
end

function Guest:move( position )
    self.rect.x = position.x
    self.rect.y = position.y
end


return Guest
