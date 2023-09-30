-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

function Utilities.getZero()
	return 0
end

function Utilities.findKeyByValue( tbl, value )
	for k, v in pairs(tbl) do
		if v == value then
		return k
		end
	end
	return nil
end

function Utilities.screenSize()
	return {width = 400, height = 240}
end