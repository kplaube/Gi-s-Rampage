local module = {}

module.blinkScreen = function(callback)
    local rect = module._createRect()
    module._fadeIn(rect, function()
        module._fadeOut(rect, callback)
    end)
end

module._createRect = function()
    local rect = display.newRect(0, 0,
        display.contentWidth, display.contentHeight)
    rect.anchorX, rect.anchorY = 0, 0

    rect:setFillColor(1)
    rect.blendMode = "add"
    rect.alpha = 0

    return rect
end

module._fadeIn = function(rect, callback)
    transition.fadeIn(rect, {
        time = 200,
        onComplete = function()
            module._fadeOut(rect, callback)
        end
    })
end

module._fadeOut = function(rect, callback)
    transition.fadeOut(rect, {
        time = 200,
        onComplete = function()
            callback()
        end
    })
end

return module
