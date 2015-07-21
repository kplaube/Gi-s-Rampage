-- luacheck: globals display native, ignore self
local TextDialog = {
    background = {
        type = "gradient",
        color1={ 1/255, 1/255, 1/255, 0.9 },
        color2={ 1/255, 1/255, 1/255, 0.6 },
        direction="down"
    },
    fontType = native.systemFont,
    fontSize = 14,
    tapLabel = "pressione"
}

function TextDialog.new()
    local self = display.newGroup()
    self.x = display.contentCenterX
    self.y = display.contentHeight - 45

    function self:drawRect()
        local r = 4
        local roundedRect = display.newRoundedRect(
            0, 0, display.contentWidth - 10, 80, r)
        roundedRect:setFillColor( TextDialog.background )

        self:insert( 1, roundedRect, true )
    end

    function self:setText( text )
        if self.text ~= nil then
            self.text:removeSelf()
            self.text = nil
        end

        local textObject = display.newText( {
            text = text .. " (" .. TextDialog.tapLabel .. ")",
            x = 0, y = 0,
            font = TextDialog.fontType,
            fontSize = TextDialog.fontSize,
            width = 410
        } )
        textObject:setFillColor( 1, 1, 1)

        self.text = textObject
        self:insert(textObject)
    end

    function self:show( text )
        self:drawRect()
        self:setText( text )
    end

    function self:setDialog( dialogTable, onDialogEnd )
        self.dialogs = dialogTable
        self.dialogIndex = 1
        self.onDialogEnd = onDialogEnd
    end

    function self:startDialog()
        self:show(self.dialogs[self.dialogIndex])
    end

    function self:closeDialog()
        self:removeSelf()
    end

    function self:nextDialog()
        self.dialogIndex = self.dialogIndex + 1

        if self.dialogIndex > table.getn(self.dialogs) then
            self:closeDialog()
            self:onDialogEnd()
            return
        end

        self:setText(self.dialogs[self.dialogIndex])
    end

    local closure = function() return self:nextDialog() end
    self:addEventListener( "tap", closure )

    return self
end


return TextDialog
