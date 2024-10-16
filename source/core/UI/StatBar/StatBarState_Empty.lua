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

	self.owner.disabled = GameController.getFlag( self.owner.FLAG_PREFIX .. '.disabled' )

	if GameController.getFlag( 'statBars.paused' ) or self.owner.disabled then
		self.owner.stateMachine:changeState( self.owner.states.paused )
		return
	end

	if #self.owner.sprites > 0 then
		self.owner:resetEmptyTime()
		self.owner.stateMachine:changeState( self.owner.states.active )
		return
	end

	if self.timer.value >= ONE_SECOND then
		self.owner:tickEmptyTime()
		self.timer = Timer.new( ONE_SECOND, 0, ONE_SECOND )
	end

	if self.owner.emptyTime >= GameController.STAT_BAR_CRY_TIME and not self.owner.playCry then
		self.owner.playCry = true
	end

	local alreadyNagged = GameController.getFlag( self.owner.NAG_FLAG )
	local passedFailStage1Threshold = self.owner.emptyTime >= GameController.STAT_BAR_FAIL_STAGE_1_TIME
	if passedFailStage1Threshold and not alreadyNagged then
		self.owner.nag = true
	end

	local passedFailStage2Threshold = self.owner.emptyTime >= GameController.STAT_BAR_FAIL_STAGE_2_TIME
	if passedFailStage2Threshold and alreadyNagged then
		self.owner.ignored = true
	end

end