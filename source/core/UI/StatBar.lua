StatBar = {}
class( "StatBar" ).extends()

StatBar.icon = nil
StatBar.stat = ""

function StatBar:init( icon, stat ) 

	self.icon = icon
	self.stat = stat

end

function StatBar:add( x, y ) 

	-- TODO: There's gotta be a better way
	local statVal = Global.pet.stats[self.stat]
	-- local statVal = 5

	for i = 1, statVal do
		local sprite = NobleSprite( self.icon )
		sprite:add( x + (10 * i), y )
	end

end

function StatBar:update()
	-- TODO: Update bar with current value
end