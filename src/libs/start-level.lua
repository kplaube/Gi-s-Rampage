-- luacheck: globals audio display transition timer, ignore self

local module = {}

function module.newStartText( text )
    return display.newText{
        font="PressStart2P",
        fontSize=16,
        text=text,
        x=display.contentWidth * 0.5,
        y=display.contentHeight * 0.5
    }
end

function module.new()
    local group = display.newGroup()
    group.anchorX = 0
    group.anchorY = 0

    group.x = display.contentWidth * 2
    group.y = display.contentCenterY

    group.background = display.newRoundedRect(
        group, 0, 0, display.contentWidth, 80, 0)

    group.startText = display.newText{
        font="PressStart2P",
        fontSize=32,
        text="Começar!",
        x=0,
        y=0,
        parent=group
    }
    group.startText:setFillColor( 0, 0, 0 )

    function group:show()
        group.isVisible = true
        transition.moveTo( group, {
            x=display.contentCenterX,
            time=500,
            onComplete=function ()
                group:hide()
            end
        })
    end

    function group:hide()
        timer.performWithDelay( 200, function()
            local startSound = audio.loadSound( "sounds/level-start.mp3" )
            audio.play( startSound )

            transition.moveTo( group, {
                x=-group.contentWidth,
                time=500,
                onComplete=function ()
                    group.isVisible = false

                    group:dispatchEvent{
                        name="hideText",
                        target=group
                    }
                end
            })
        end )
    end

    return group
end

return module
