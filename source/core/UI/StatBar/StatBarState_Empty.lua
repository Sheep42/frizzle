StatBarState_Empty = {}
class( "StatBarState_Empty" ).extends( State )
local state = StatBarState_Empty

function state:init( id, owner )
	state.super.init( self, id )
	self.owner = owner
	self.timer = nil
end

-- Fires when a State is entered
function state:enter()
	self.timer = Timer.new( ONE_SECOND, 0, ONE_SECOND )
end

-- Fires when a State is exited
function state:exit() end

-- Fires when the State Machine updates
function state:tick()

	if GameController.getFlag( 'statBars.paused' ) then
		self.owner.stateMachine:changeState( self.owner.states.paused )
	end

	if #self.owner.sprites > 0 then
		self.owner.stateMachine:changeState( self.owner.states.active )
		self.owner.emptyTime = 0
	end

	if self.timer.value >= ONE_SECOND then
		self.owner.emptyTime += 1
		self.timer = Timer.new( ONE_SECOND, 0, ONE_SECOND )
	end

end