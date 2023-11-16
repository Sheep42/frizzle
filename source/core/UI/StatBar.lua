StatBar = {}
class( "StatBar" ).extends()

function StatBar:init( icon, stat ) 

	self.icon = icon
	self.stat = stat
	self.position = { x = 0, y = 0 }
	self.sprites = {}

end

function StatBar:add( x, y ) 

	self.position.x = x
	self.position.y = y

	self:addSprites()

end

function StatBar:update()

	if #self.sprites ~= GameController.pet.stats[self.stat] then
		self:removeSprites()
		self:addSprites()	
	end

end

function StatBar:addSprites() 
	
	local statVal = GameController.pet.stats[self.stat]
	
	for i = 0, statVal - 1 do
		local sprite = NobleSprite( self.icon )
		sprite:add( self.position.x + (10 * i), self.position.y )
		table.insert( self.sprites, sprite )
	end

end

function StatBar:removeSprites() 

	for i = 1, #self.sprites do
		local sprite = self.sprites[i]
		sprite:remove()
	end

	self.sprites = {}

end
