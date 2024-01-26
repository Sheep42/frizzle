StatBar = {}
class( "StatBar" ).extends()

function StatBar:init( icon, stat, gameType )

	self.icon = icon
	self.stat = stat
	self.gameType = gameType
	self.emptyTime = 0
	self.nagged = false
	self.position = { x = 0, y = 0 }
	self.sprites = {}

	-- States
	self.states = {
		paused = StatBarState_Paused( 'paused', self ),
		active = StatBarState_Active( 'active', self ),
		empty = StatBarState_Empty( 'empty', self ),
	}

	self.stateMachine = StateMachine( self.states.paused )

end

function StatBar:add( x, y )

	self.position.x = x
	self.position.y = y

	self:addSprites()

end

function StatBar:update()

	self.stateMachine:update()

end

function StatBar:addSprites()

	local statVal = GameController.pet.stats[self.stat].value

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
