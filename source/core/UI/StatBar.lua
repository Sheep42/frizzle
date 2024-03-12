StatBar = {}
class( "StatBar" ).extends()

function StatBar:init( stat )

	self.FLAG_PREFIX = 'statBars.' .. stat.key
	self.NAG_FLAG = self.FLAG_PREFIX .. '.nagged'

	self.icon = stat.icon
	self.stat = stat.key
	self.crySound = stat.crySound
	self.gameType = stat.gameType
	self.emptyTime = GameController.getFlag( self.FLAG_PREFIX .. '.emptyTime' )
	self.ignored = false
	self.nag = false
	self.playCry = false
	self.position = { x = 0, y = 0 }
	self.sprites = {}
	self.disabled = false

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

function StatBar:resetEmptyTime()

	self.emptyTime = 0
	GameController.setFlag( self.FLAG_PREFIX .. '.emptyTime', self.emptyTime )

	self.nag = false
	GameController.setFlag( self.NAG_FLAG, false )

	self.playCry = false

end

function StatBar:tickEmptyTime()
	self.emptyTime += 1
	GameController.setFlag( self.FLAG_PREFIX .. '.emptyTime', self.emptyTime )
end