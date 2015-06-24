--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Update

Wraps camera and tile culling to create a unified system.
--]]
--------------------------------------------------------------------------------

local lib_update = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")

local getSetting = lib_settings.get

local lib_camera; if getSetting("enableCamera") then lib_camera = require("Dusk.dusk_core.run.camera") end
local lib_tileculling; if getSetting("enableTileCulling") then lib_tileculling = require("Dusk.dusk_core.run.tileculling") end
local lib_anim = require("Dusk.dusk_core.run.anim")

--------------------------------------------------------------------------------
-- Register Tile Culling and Camera
--------------------------------------------------------------------------------
function lib_update.register(map)
	local enableCamera, enableTileCulling = getSetting("enableCamera"), getSetting("enableTileCulling")
	local mapLayers = #map.layer

	local update = {}
	local camera, culling
	local anim = lib_anim.new(map)

	------------------------------------------------------------------------------
	-- Add Camera and Tile Culling to Map
	------------------------------------------------------------------------------
	if enableCamera then
		if not lib_camera then
			lib_camera = require("Dusk.dusk_core.run.camera")
		end

		camera = lib_camera.addControl(map)
	end

	if enableTileCulling then
		if not lib_tileculling then
			lib_tileculling = require("Dusk.dusk_core.run.tileculling")
		end

		culling = lib_tileculling.addTileCulling(map)
		culling.screenTileField.x, culling.screenTileField.y = screen.centerX, screen.centerY

		for layer, i in map.tileLayers() do
			if culling.screenTileField.layer[i] then
				local l, r, t, b = culling.screenTileField.layer[i].updatePositions()
				layer._edit(l, r, t, b, "d")
				culling.screenTileField.layer[i].updatePositions()
			end
		end
	else
		for layer in map.tileLayers() do
			layer._edit(1, map.data.mapWidth, 1, map.data.mapHeight, "d")
		end
	end
	
	------------------------------------------------------------------------------
	-- Update Tile Culling Only
	------------------------------------------------------------------------------
	local function updateTileCulling()
		map._animManager.update()

		for i = 1, #culling.screenTileField.layer do
			culling.screenTileField.layer[i].update()
		end
	end

	------------------------------------------------------------------------------
	-- Update Camera Only
	------------------------------------------------------------------------------
	local function updateCamera()
		camera.processCameraViewpoint()
		map._animManager.update()
		
		for i = 1, #camera.layer do
			camera.layer[i].update()
		end
	end
	
	------------------------------------------------------------------------------
	-- Omni-Update
	------------------------------------------------------------------------------
	local function updateView()
		camera.processCameraViewpoint()
		map._animManager.update()
		for i = 1, mapLayers do
			if camera.layer[i] then
				camera.layer[i].update()
			end

			if culling.screenTileField.layer[i] then
				culling.screenTileField.layer[i].update()
			end
		end
	end

	------------------------------------------------------------------------------
	-- Destroy
	------------------------------------------------------------------------------
	function update.destroy()
		camera = nil
		culling = nil
	end

	map.snapCamera = function()
		local trackingLevel = map.getTrackingLevel()
		map.setTrackingLevel(1)
		map.updateView()
		map.setTrackingLevel(trackingLevel)
	end

	------------------------------------------------------------------------------
	-- Give Tile/Camera Updating to Map
	------------------------------------------------------------------------------
	if enableTileCulling and not enableCamera then
		map.updateView = updateTileCulling
		updateView = nil
		updateCamera = nil
	elseif enableCamera and not enableTileCulling then
		map.updateView = updateCamera
		updateTileCulling = nil
		updateView = nil
	elseif enableTileCulling and enableCamera then
		map.updateView = updateView
		updateCamera = nil
		updateTileCulling = nil
	elseif not enableTileCulling and not enableCamera then
		map.updateView = map._animManager.update
	end

	return update
end

return lib_update