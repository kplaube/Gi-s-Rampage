local Priest = {
    image = "images/characters/priest.png",
    imageWidth = 48,
    imageHeight = 48
}

function Priest.new( )
    local self = display.newImageRect(
        Priest.image,
        Priest.imageWidth,
        Priest.imageHeight
    )

    return self
end


return Priest
