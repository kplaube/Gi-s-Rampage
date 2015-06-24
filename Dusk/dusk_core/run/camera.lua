--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Camera

Adds virtual camera functionality to maps.
--]]
--------------------------------------------------------------------------------

local lib_camera = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_functions = require("Dusk.dusk_core.misc.functions")

local getSetting = lib_settings.get
local verby_error = verby.error
local verby_alert = verby.alert
local getXY = lib_functions.getXY
local clamp = lib_functions.clamp
local display_contentWidth = display.contentWidth
local display_contentHeight = display.contentHeight
local math_min = math.min
local math_max = math.max
local math_huge = math.huge
local math_nhuge = -math_huge
local math_round = math.round

--------------------------------------------------------------------------------
-- Add Camera Control to a Map
--------------------------------------------------------------------------------
function lib_camera.addControl(map)
	local camera

	camera = {
		trackingLevel = getSetting("defaultCameraTrackingLevel"),
		scaleBoundsToScreen = getSetting("scaleCameraBoundsToScreen"),
		viewX = screen.centerX,
		viewY = screen.centerY,
		layer = {},

		xScale = 1,
		yScale = 1,

		addX = screen.centerX,
		addY = screen.centerY,

		bounds = {
			xMin = math_nhuge,
			yMin = math_nhuge,
			xMax = math_huge,
			yMax = math_huge
		},

		scaledBounds = {
			xMin = math_nhuge,
			yMin = math_nhuge,
			xMax = math_huge,
			yMax = math_huge
		},

		trackFocus = false,
		getFocusXY = function() return camera.viewX, camera.viewY end,
		scaleBounds = function() end
	}

	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	-- Load Each Layer
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	for i = 1, #map.layer do
		if map.layer[i].cameraTrackingEnabled then
			camera.layer[i] = {
				update = function() end, -- Placeholder to keep from rehashing
				xOffset = 0,
				yOffset = 0,
				x = 0,
				y = 0
			}

			--------------------------------------------------------------------------
			-- Update Camera
			--------------------------------------------------------------------------
			camera.layer[i].update = function()
				local layer = map.layer[i]
				camera.layer[i].x = camera.layer[i].x + (-camera.viewX - camera.layer[i].x)
				camera.layer[i].y = camera.layer[i].y + (-camera.viewY - camera.layer[i].y)
				layer.x = math_round((layer.x - (layer.x - (camera.layer[i].x + camera.addX) * layer.xParallax) * camera.trackingLevel) + camera.layer[i].xOffset)
				layer.y = math_round((layer.y - (layer.y - (camera.layer[i].y + camera.addY) * layer.yParallax) * camera.trackingLevel) + camera.layer[i].yOffset)
			end

			--------------------------------------------------------------------------
			-- Get/Set Methods
			--------------------------------------------------------------------------
			-- Set offset
			map.layer[i].setCameraOffset = function(x, y)
				local x, y = getXY(x, y)
				camera.layer[i].xOffset = x or camera.layer[i].xOffset
				camera.layer[i].yOffset = y or camera.layer[i].yOffset
			end

			-- Get offset
			map.layer[i].getCameraOffset = function() return camera.layer[i].xOffset, camera.layer[i].yOffset end

			map.layer[i].setOffset = function(x, y) verby_alert("Warning: `layer.setOffset()` is deprecated in favor of `layer.setCameraOffset()`.") map.layer[i].setCameraOffset(x, y) end
			map.layer[i].getOffset = function() verby_alert("Warning: `layer.getOffset()` is deprecated in favor of `layer.getCameraOffset()`.") return map.layer[i].getCameraOffset() end
		end
	end


	------------------------------------------------------------------------------
	-- Internal Camera Methods
	------------------------------------------------------------------------------
	-- Scale bounds to screen
	function camera.scaleBounds(doX, doY)
		if camera.scaleBoundsToScreen then
			local xMin = camera.bounds.xMin
			local xMax = camera.bounds.xMax
			local yMin = camera.bounds.yMin
			local yMax = camera.bounds.yMax

			local doX = doX and not ((xMin == math_nhuge) or (xMax == math_huge))
			local doY = doY and not ((yMin == math_nhuge) or (yMax == math_huge))

			if doX then
				local scaled_xMin = xMin / map.xScale
				local scaled_xMax = xMax - (scaled_xMin - xMin)

				-- Check against "hopping"
				if scaled_xMax < scaled_xMin then
					local hopDist = scaled_xMin - scaled_xMax
					local halfDist = hopDist * 0.5
					scaled_xMax = scaled_xMax + halfDist
					scaled_xMin = scaled_xMin - halfDist
				end

				camera.scaledBounds.xMin = scaled_xMin
				camera.scaledBounds.xMax = scaled_xMax
			end

			if doY then
				local scaled_yMin = yMin / map.yScale
				local scaled_yMax = yMax - (scaled_yMin - yMin)

				-- Check against "hopping"
				if scaled_yMax < scaled_yMin then
					local hopDist = scaled_yMin - scaled_yMax
					local halfDist = hopDist * 0.5
					scaled_yMax = scaled_yMax + halfDist
					scaled_yMin = scaled_yMin - halfDist
				end

				camera.scaledBounds.yMin = scaled_yMin
				camera.scaledBounds.yMax = scaled_yMax
			end
		else
			-- Move along, nothing to see here; just set the scaled bounds to the camera bounds
			camera.scaledBounds.xMin, camera.scaledBounds.xMax, camera.scaledBounds.yMin, camera.scaledBounds.yMax = camera.bounds.xMin, camera.bounds.xMax, camera.bounds.yMin, camera.bounds.yMax
		end
	end

	-- Update camera addX and Y
	function camera.updateAddXY()
		camera.addX = screen.centerX / map.xScale
		camera.addY = screen.centerY / map.yScale
	end

	------------------------------------------------------------------------------
	-- Process Camera Viewpoint
	------------------------------------------------------------------------------
	function camera.processCameraViewpoint()
		if camera.trackFocus then
			local x, y = camera.getFocusXY()

			local mapXScale, mapYScale = map.xScale, map.yScale

			if mapXScale ~= camera.xScale or mapYScale ~= camera.yScale then
				camera.updateAddXY()
			end

			if mapXScale ~= camera.xScale then
				camera.xScale = mapXScale
				camera.scaleBounds(true, false)
			end

			if mapYScale ~= camera.yScale then
				camera.yScale = mapYScale
				camera.scaleBounds(false, true)
			end

			x = clamp(x, camera.scaledBounds.xMin, camera.scaledBounds.xMax)
			y = clamp(y, camera.scaledBounds.yMin, camera.scaledBounds.yMax)

			map.setViewpoint(x, y)
		end
	end

	------------------------------------------------------------------------------
	-- Map Methods
	------------------------------------------------------------------------------

	------------------------------------------------------------------------------
	-- Set/Get Viewpoint
	------------------------------------------------------------------------------
	function map.setViewpoint(x, y)
		local x, y = getXY(x, y)
		camera.viewX, camera.viewY = math_round(x), math_round(y)
	end

	function map.getViewpoint()
		return camera.viewX, camera.viewY
	end

	------------------------------------------------------------------------------
	-- Position Camera
	------------------------------------------------------------------------------
	function map.positionCamera(x, y)
		local x, y = getXY(x, y)
		map.setViewpoint(x, y)
		map.snapCamera() -- This isn't defined here, but we'll have it if control ever reaches here
	end

	------------------------------------------------------------------------------
	-- Enable/Disable Focus Tracking
	------------------------------------------------------------------------------
	function map.enableFocusTracking(t)
		camera.trackFocus = not not t -- Convert to Boolean

		if not camera.trackFocus then
			camera.getFocusXY = function() return camera.viewX, camera.viewY end
		end
	end

	------------------------------------------------------------------------------
	-- Set Focus
	------------------------------------------------------------------------------
	function map.setCameraFocus(f, noSnapCamera)
		if not (f ~= nil and f.x ~= nil and f.y ~= nil) then verby_error("Invalid focus object passed to `map.setCameraFocus()`") end

		camera.getFocusXY = function()
			return f.x, f.y
		end

		camera.trackFocus = true

		if noSnapCamera then
			-- Specified as do not snap camera to object, so do nothing
		else
			map.snapCamera() -- Center on object to start out; this function is not defined in this library, but we know we'll get it when lib_update processes the map
		end
	end

	------------------------------------------------------------------------------
	-- Set Camera Bounds
	------------------------------------------------------------------------------
	function map.setCameraBounds(bounds)
		local xMin, xMax, yMin, yMax

		if bounds.xMin then xMin = bounds.xMin elseif bounds.xMin == false then xMin = math_nhuge else xMin = camera.bounds.xMin end
		if bounds.xMax then xMax = bounds.xMax elseif bounds.xMax == false then xMax = math_huge else xMax = camera.bounds.xMax end
		if bounds.yMin then yMin = bounds.yMin elseif bounds.yMin == false then yMin = math_nhuge else yMin = camera.bounds.yMin end
		if bounds.yMax then yMax = bounds.yMax elseif bounds.yMax == false then yMax = math_huge else yMax = camera.bounds.yMax end

		camera.bounds.xMin = math_min(xMin, xMax)
		camera.bounds.xMax = math_max(xMin, xMax)
		camera.bounds.yMin = math_min(yMin, yMax)
		camera.bounds.yMax = math_max(yMin, yMax)

		camera.scaleBounds(true, true)
	end

	------------------------------------------------------------------------------
	-- Set/Get Tracking Level (damping)
	------------------------------------------------------------------------------
	-- Set tracking level (in tracking level format)
	function map.setTrackingLevel(t)
		if not t then verby_error("Missing argument to `map.setTrackingLevel()`") end
		if t <= 0 then verby_error("Invalid argument passed to `map.setTrackingLevel()`: expected t > 0 but got " .. t .. " instead") end
		camera.trackingLevel = t
	end

	-- Set tracking level (in damping format)
	function map.setDamping(d)
		if not d then verby_error("Missing argument to `map.setDamping()`") end
		if d == 0 then verby_error("Invalid argument passed to `map.setDamping()`: expected d > 0 but got 0 instead.") end
		return map.setTrackingLevel(1 / d)
	end

	-- Get tracking level (in tracking level format)
	function map.getTrackingLevel()
		return camera.trackingLevel
	end

	-- Get tracking level (in damping format)
	function map.getDamping()
		return 1 / camera.trackingLevel
	end

	return camera
end

return lib_camera