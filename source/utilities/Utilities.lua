-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

Utilities.collisionGroups = {
	cursor = 1,
	uiButtons = 2,
	interactables = 3,
}

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

-- Move a NobleSprite towards another at the specified speed.
-- This calculates o1 moving towards o2
function Utilities.moveTowards( o1, o2, speed, offsetX, offsetY )

	local x1, y1 = o1:getPosition()
	local x2, y2 = o2:getPosition()

	if offsetX == nil then
		offsetX = 0
	end

	if offsetY == nil then
		offsetY = 0
	end

    -- Calculate distance between o1 and o2
    local distance_x = x2 - x1 + offsetX
    local distance_y = y2 - y1 + offsetY
    local dist = Utilities.distance( x1, y1, x2, y2 )

    -- Determine direction of movement
    local direction_x = distance_x / dist
    local direction_y = distance_y / dist

    -- Calculate change in position to move o1 towards o2 at desired speed
    local move_x = direction_x * speed
    local move_y = direction_y * speed

    -- Return the calculated move
    return move_x, move_y

end

-- Calculate the distance between (x1, y1) and (x2, y2)
function Utilities.distance( x1, y1, x2, y2 )
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


-- Pick a random value from a table with keys
function Utilities.randomElements( tb, count )
	local keys = {}
	local result = {}
	for k in pairs(tb) do table.insert(keys, k) end

	while #result < count do
		table.insert( result, tb[keys[math.random(#keys)]] )
	end

	return result
end