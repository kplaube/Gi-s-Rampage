--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Lua Preprocessor

Processes a Lua map to conform with Dusk's format.
--]]
--------------------------------------------------------------------------------

local lib_preprocessor = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local tostring = tostring

--------------------------------------------------------------------------------
-- Get Map Data
--------------------------------------------------------------------------------
function lib_preprocessor.process(data)
	for i = 1, #data.tilesets do
		local t = data.tilesets[i]
		t.tileproperties = {}

		for n = 1, #t.tiles do
			local p = t.tiles[n]
			t.tileproperties[tostring(p.id)] = p.properties
		end
	end
end

return lib_preprocessor