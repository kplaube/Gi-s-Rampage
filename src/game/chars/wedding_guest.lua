local Guest = {
    image = "images/characters/guests.png",
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

Guest.imageSheet = graphics.newImageSheet(
    Guest.image,
    Guest.imageSheetOption
)

function Guest.new( frame )
    local self = display.newImageRect(
        Guest.imageSheet,
        frame,
        Guest.imageSheetOption.width,
        Guest.imageSheetOption.height
    )

    return self
end

function Guest.guestsFactory()
    local guests = {}

    for i=1, Guest.imageSheetOption.numFrames do
        guests[i] = Guest.new( i )
    end

    return guests
end


return Guest
