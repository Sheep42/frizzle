-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

local SCREEN_BOUNDS_PADDING_PERCENT = {x = 0.025, y = 0.05}

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

function Utilities.screenBounds()
	return {
		top = Utilities.screenSize().height * SCREEN_BOUNDS_PADDING_PERCENT.y,
		bottom = Utilities.screenSize().height - ( Utilities.screenSize().height * SCREEN_BOUNDS_PADDING_PERCENT.y ),
		left = Utilities.screenSize().width * SCREEN_BOUNDS_PADDING_PERCENT.x,
		right = Utilities.screenSize().width - ( Utilities.screenSize().width * SCREEN_BOUNDS_PADDING_PERCENT.x ),
	}
end