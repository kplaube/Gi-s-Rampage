--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Tile Layer

Builds a tile layer from data.
--]]
--------------------------------------------------------------------------------

local lib_tilelayer = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local verby = require("Dusk.dusk_core.external.verby")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_functions = require("Dusk.dusk_core.misc.functions")

local display_remove = display.remove
local display_newGroup = display.newGroup
local display_newImageRect = display.newImageRect
local display_newSprite = display.newSprite
local math_abs = math.abs
local math_max = math.max
local math_ceil = math.ceil
local table_maxn = table.maxn
local table_insert = table.insert
local string_len = string.len
local tonumber = tonumber
local tostring = tostring
local pairs = pairs
local unpack = unpack
local type = type
local getSetting = lib_settings.get
local setVariable = lib_settings.setEvalVariable
local removeVariable = lib_settings.removeEvalVariable
local verby_error = verby.error
local getProperties = lib_functions.getProperties
local addProperties = lib_functions.addProperties
local setProperty = lib_functions.setProperty
local getXY = lib_functions.getXY
local physicsKeys = {radius = true, isSensor = true, bounce = true, friction = true, density = true, shape = true}
local physics_addBody; if physics and type(physics) == "table" and physics.addBody then physics_addBody = physics.addBody else physics_addBody = function() verby_error("Physics library was not found on Dusk Engine startup") end end

local flipX = tonumber("80000000", 16)
local flipY = tonumber("40000000", 16)
local flipD = tonumber("20000000", 16)

--------------------------------------------------------------------------------
-- Create Layer
--------------------------------------------------------------------------------
function lib_tilelayer.createLayer(map, mapData, data, dataIndex, tileIndex, imageSheets, imageSheetConfig, tileProperties)
	local layerProps = getProperties(data.properties or {}, "tiles", true)
	local dotImpliesTable = getSetting("dotImpliesTable")

	local layer = display_newGroup()
	
	layer._leftmostTile = mapData._dusk.layers[dataIndex].leftTile - 1
	layer._rightmostTile = mapData._dusk.layers[dataIndex].rightTile + 1
	layer._highestTile = mapData._dusk.layers[dataIndex].topTile - 1
	layer._lowestTile = mapData._dusk.layers[dataIndex].bottomTile + 1

	layer.props = {}

	local mapWidth, mapHeight = mapData.width, mapData.height
	
	layer.edgeModeX, layer.edgeModeY = "stop", "stop"
	
	if layer._leftmostTile == math.huge then
		layer._isBlank = true
		-- If we want, we can overwrite the normal functions with blank ones; this
		-- layer is completely empty so no reason to have useless functions that
		-- take time. However, in the engine, we can just check for layer._isBlank
		-- and it'll be even faster than a useless function call.
		--[[
		function layer.tile() return nil end
		function layer._drawTile() end
		function layer._eraseTile() end
		function layer._redrawTile() end
		function layer._lockTileDrawn() end
		function layer._lockTileErased() end
		function layer._unlockTile() end
		function layer._edit() end
		function layer.draw() end
		function layer.erase() end
		function layer.lock() end
		--]]
	end

	local layerTiles = {}
	local locked = {}

	function layer.tile(x, y) if layerTiles[x] ~= nil and layerTiles[x][y] ~= nil then return layerTiles[x][y] else return nil end end

	layer.tiles = layerTiles

	------------------------------------------------------------------------------
	-- Draw a Single Tile to the Screen
	------------------------------------------------------------------------------
	function layer._drawTile(x, y)
		if locked[x] and locked[x][y] == "e" then return false end
		
		if not layerTiles[x] or not layerTiles[x][y] then
			local idX, idY = x, y

			if x < 1 or x > mapWidth then
				local edgeModeX = layer.edgeModeX
				if edgeModeX == "wrap" then
					idX = (idX - 1) % mapWidth + 1
				elseif edgeModeX == "clamp" then
					idX = (idX < 1 and 1) or (idX > mapWidth and mapWidth)
				elseif edgeModeX == "stop" then
					return false
				end
			end

			if y < 1 or y > mapHeight then
				local edgeModeY = layer.edgeModeY
				if edgeModeY == "wrap" then
					idY = (idY - 1) % mapHeight + 1
				elseif edgeModeY == "clamp" then
					idY = (idY < 1 and 1) or (idY > mapHeight and mapHeight)
				elseif edgeModeY == "stop" then
					return false
				end
			end

			local id = ((idY - 1) * mapData.width) + idX
			local gid = data.data[id]

			-- Skip blank tiles
			if gid == 0 then return true end

			--------------------------------------------------------------------------
			-- Tile Data/Preparation
			--------------------------------------------------------------------------
			local flippedX = false
			local flippedY = false
			local rotated = false
			if gid % (gid + flipX) >= flipX then flippedX = true gid = gid - flipX end
			if gid % (gid + flipY) >= flipY then flippedY = true gid = gid - flipY end
			if gid % (gid + flipD) >= flipX then rotated = true gid = gid - flipD end

			if gid > mapData.highestGID or gid < 0 then verby_error("Invalid GID at position [" .. x .. "," .. y .."] (index #" .. id ..") - expected [0 <= GID <= " .. mapData.highestGID .. "] but got " .. gid .. " instead.") end

			local tileData = tileIndex[gid]
			local sheetIndex = tileData.tilesetIndex
			local tileGID = tileData.gid

			local tile
			local tileProps

			if tileProperties[sheetIndex][tileGID] then
				tileProps = tileProperties[sheetIndex][tileGID]
			end

			------------------------------------------------------------------------
			-- Create Tile
			------------------------------------------------------------------------
			if tileProps and tileProps.object["!isSprite!"] then
				tile = display_newSprite(imageSheets[sheetIndex], imageSheetConfig[sheetIndex])
				tile:setFrame(tileGID)
			elseif tileProps and tileProps.anim.enabled then
				tile = display_newSprite(imageSheets[sheetIndex], tileProps.anim.options)
				tile._animData = tileProps.anim
				tile.isAnimated = true
			else
				tile = display_newImageRect(imageSheets[sheetIndex], tileGID, mapData.stats.tileWidth, mapData.stats.tileHeight)
			end
			
			tile.props = {}
			
			tile.x, tile.y = mapData.stats.tileWidth * (x - 0.5), mapData.stats.tileHeight * (y - 0.5)
			-- tile.xScale, tile.yScale = screen.zoomX, screen.zoomY

			tile.gid = gid
			tile.tilesetGID = tileGID
			tile.tileset = sheetIndex
			tile.layerIndex = dataIndex
			tile.tileX, tile.tileY = x, y
			tile.hash = tostring(tile)
			
			if flippedX then tile.xScale = -tile.xScale end
			if flippedY then tile.yScale = -tile.yScale end

			--------------------------------------------------------------------------
			-- Tile Properties
			--------------------------------------------------------------------------
			if tileProps then				
				------------------------------------------------------------------------
				-- Add Physics to Tile
				------------------------------------------------------------------------
				local shouldAddPhysics = tileProps.options.physicsExistent
				if shouldAddPhysics == nil then shouldAddPhysics = layerProps.options.physicsExistent end
				if shouldAddPhysics then
					local physicsParameters = {}
					local physicsBodyCount = layerProps.options.physicsBodyCount
					local tpPhysicsBodyCount = tileProps.options.physicsBodyCount; if tpPhysicsBodyCount == nil then tpPhysicsBodyCount = physicsBodyCount end

					physicsBodyCount = math_max(physicsBodyCount, tpPhysicsBodyCount)

					for i = 1, physicsBodyCount do
						physicsParameters[i] = {}
						local tilePhysics = tileProps.physics[i]
						local layerPhysics = layerProps.physics[i]

						if tilePhysics and layerPhysics then
							for k, v in pairs(physicsKeys) do
								physicsParameters[i][k] = tilePhysics[k]
								if physicsParameters[i][k] == nil then physicsParameters[i][k] = layerPhysics[k] end
							end
						elseif tilePhysics then
							physicsParameters[i] = tilePhysics
						elseif layerPhysics then
							physicsParameters[i] = layerPhysics
						end
					end

					if physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
						physics_addBody(tile, physicsParameters[1])
					else
						physics_addBody(tile, unpack(physicsParameters))
					end
				end
				
				for k, v in pairs(layerProps.object) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
				end

				for k, v in pairs(tileProps.object) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
				end

				for k, v in pairs(tileProps.props) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile.props, k, v) else tile.props[k] = v end
				end
			else -- if tileProps
				------------------------------------------------------------------------
				-- Add Physics to Tile
				------------------------------------------------------------------------
				if layerProps.options.physicsExistent then
					if layerProps.options.physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
						physics_addBody(tile, layerProps.physics)
					else
						physics_addBody(tile, unpack(layerProps.physics))
					end
				end
				
				for k, v in pairs(layerProps.object) do
					if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(tile, k, v) else tile[k] = v end
				end
			end

			if not layerTiles[x] then layerTiles[x] = {} end
			layerTiles[x][y] = tile
			layer:insert(tile)
			tile:toBack()
			
			if tile.isAnimated and map._animManager then map._animManager.animatedTileCreated(tile) end
		end
	end

	------------------------------------------------------------------------------
	-- Erase a Single Tile from the Screen
	------------------------------------------------------------------------------
	function layer._eraseTile(x, y)
		if locked[x] and locked[x][y] == "d" then return end

		if layerTiles[x] and layerTiles[x][y] then
			if layerTiles[x][y].isAnimated and map._animManager then map._animManager.animatedTileRemoved(layerTiles[x][y]) end
			display_remove(layerTiles[x][y])
			layerTiles[x][y] = nil

			-- Need this for tile edge modes
			if table_maxn(layerTiles[x]) == 0 then
				layerTiles[x] = nil -- Clear row if no tiles in the row
			end
		end
	end

	------------------------------------------------------------------------------
	-- Redraw a Tile
	------------------------------------------------------------------------------
	function layer._redrawTile(x, y)
		layer._eraseTile(x, y)
		layer._drawTile(x, y)
	end

	------------------------------------------------------------------------------
	-- Lock/Unlock a Tile
	------------------------------------------------------------------------------
	function layer._lockTileDrawn(...) verby_alert("Warning: `layer._lockTileDrawn()` has been deprecated in favor of layer.lockTileDrawn().") layer.lockTileDrawn(...) end
	function layer._lockTileErased(...) verby_alert("Warning: `layer._lockTileErased()` has been deprecated in favor of layer.lockTileErased().") layer.lockTileErased(...) end
	function layer._unlockTile(...) verby_alert("Warning: `layer._unlockTile()` has been deprecated in favor of layer.unlockTile().") layer.unlockTile(...) end

	function layer.lockTileDrawn(x, y) if not locked[x] then locked[x] = {} end locked[x][y] = "d" layer._drawTile(x, y) end
	function layer.lockTileErased(x, y) if not locked[x] then locked[x] = {} end locked[x][y] = "e" layer._eraseTile(x, y) end
	function layer.unlockTile(x, y) if locked[x] and locked[x][y] then locked[x][y] = nil if table_maxn(locked[x]) == 0 then locked[x] = nil end end end

	------------------------------------------------------------------------------
	-- Edit Section
	------------------------------------------------------------------------------
	function layer._edit(x1, x2, y1, y2, mode)
		local mode = mode or "d"
		local x1 = x1 or 0
		local x2 = x2 or x1
		local y1 = y1 or 0
		local y2 = y2 or y1

		-- "Shortcuts" for cutting down time
		if x1 > x2 then x1, x2 = x2, x1 end; if y1 > y2 then y1, y2 = y2, y1 end
		-- if x2 < 1 or x1 > mapData.stats.mapWidth then return true end; if y2 < 1 or y1 > mapData.stats.mapHeight then return true end
		-- if x1 < 1 then x1 = 1 end; if y1 < 1 then y1 = 1 end
		-- if x2 > mapData.stats.mapWidth then x2 = mapData.stats.mapWidth end; if y2 > mapData.stats.mapHeight then y2 = mapData.stats.mapHeight end

		-- Function associated with edit mode
		local layerFunc = "_eraseTile"
		if mode == "d" then layerFunc = "_drawTile" elseif mode == "ld" then layerFunc = "_lockTileDrawn" elseif mode == "le" then layerFunc = "_lockTileErased" elseif mode == "u" then layerFunc = "_unlockTile" end

		for x = x1, x2 do
			for y = y1, y2 do
				layer[layerFunc](x, y)
			end
		end
	end

	------------------------------------------------------------------------------
	-- Draw Section (shortcut, shouldn't be used in speed-intensive places because it's just a tail call)
	------------------------------------------------------------------------------
	function layer.draw(x1, x2, y1, y2)
		return layer._edit(x1, x2, y1, y2, "d")
	end

	------------------------------------------------------------------------------
	-- Erase Section (shortcut, shouldn't be used in speed-intensive places because it's just a tail call)
	------------------------------------------------------------------------------
	function layer.erase(x1, x2, y1, y2)
		return layer._edit(x1, x2, y1, y2, "e")
	end

	------------------------------------------------------------------------------
	-- Lock Section (shortcut, shouldn't be used in speed-intensive places because it's just a tail call)
	------------------------------------------------------------------------------
	function layer.lock(x1, y1, x2, y2, mode)
		if mode == "draw" or mode == "d" then
			return layer._edit(x1, x2, y1, y2, "ld")
		elseif mode == "erase" or mode == "e" then
			return layer._edit(x1, x2, y1, y2, "le")
		elseif mode == "unlock" or mode == "u" then
			return layer._edit(x1, x2, y1, y2, "u")
		end
	end

	------------------------------------------------------------------------------
	-- Tiles to Pixels Conversion
	------------------------------------------------------------------------------
	function layer.tilesToPixels(x, y)
		local x, y = getXY(x, y)

		if x == nil or y == nil then verby_error("Missing argument(s).") end

		x, y = (x - 0.5) * mapData.stats.tileWidth, (y - 0.5) * mapData.stats.tileHeight

		return x, y
	end

	------------------------------------------------------------------------------
	-- Pixels to Tiles Conversion
	------------------------------------------------------------------------------
	function layer.pixelsToTiles(x, y)
		local x, y = getXY(x, y)

		if x == nil or y == nil then verby_error("Missing argument(s).") end

		return math_ceil(x / mapData.stats.tileWidth), math_ceil(y / mapData.stats.tileHeight)
	end

	------------------------------------------------------------------------------
	-- Tile by Pixels
	------------------------------------------------------------------------------
	function layer.tileByPixels(x, y)
		local x, y = layer.pixelsToTiles(x, y)
		if layerTiles[x] and layerTiles[x][y] then
			return layerTiles[x][y]
		else
			return nil
		end
	end

	------------------------------------------------------------------------------
	-- Get Tiles in Range
	------------------------------------------------------------------------------
	function layer._getTilesInRange(x, y, w, h)
		local t = {}
		for xPos = x, x + w - 1 do
			for yPos = y, y + h - 1 do
				local tile = layer.tile(xPos, yPos)
				if tile then
					table_insert(t, tile)
				end
			end
		end

		return t
	end

	------------------------------------------------------------------------------
	-- Tile Iterators
	------------------------------------------------------------------------------
	function layer.tilesInRange(x, y, w, h)
		if x == nil or y == nil or w == nil or h == nil then verby_error("Missing argument(s).") end

		local tiles = layer._getTilesInRange(x, y, w, h)

		local i = 0
		return function()
			i = i + 1
			if tiles[i] then return tiles[i] else return nil end
		end
	end

	function layer.tilesInRect(x, y, w, h)
		if x == nil or y == nil or w == nil or h == nil then verby_error("Missing argument(s).") end

		local tiles = layer._getTilesInRange(x - w, y - h, w * 2, h * 2)

		local i = 0
		return function()
			i = i + 1
			if tiles[i] then return tiles[i] else return nil end
		end
	end

	------------------------------------------------------------------------------
	-- Destroy Layer
	------------------------------------------------------------------------------
	function layer.destroy()
		display_remove(layer)
		layer = nil
	end

	------------------------------------------------------------------------------
	-- Finish Up
	------------------------------------------------------------------------------
	for k, v in pairs(layerProps.props) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer.props, k, v) else layer.props[k] = v end
	end

	for k, v in pairs(layerProps.layer) do
		if (dotImpliesTable or layerProps.options.usedot[k]) and not layerProps.options.nodot[k] then setProperty(layer, k, v) else layer[k] = v end
	end

	return layer
end

return lib_tilelayer