GamePhase_Phase1 = {}
class( 'GamePhase_Phase1' ).extends( 'State' )

local phase = GamePhase_Phase1 

-- Constructor
function phase:init( scene )
	phase.super.init( self, "phase-1" )
	self.owner = scene
end

-- Fires when the Phase is entered
function phase:enter() end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	self:phaseHandler()

end

function phase:phaseHandler() 

	if GameController.getFlag( 'game.phase' ) == 2 then
		self.stateMachine:changeState( self.owner.phases.phase2 )
	end

	if GameController.getFlag( 'game.playTime' ) >= GameController.PHASE_2_TIME_TRIGGER then
		GameController.setFlag( 'game.phase', 2 )
		return
	end

	local change = true
	for k, v in pairs( GameController.PHASE_2_GAME_TRIGGERS ) do

		local flagVal = GameController.getFlag( 'game.gamesPlayed.' .. k )
		if flagVal < v then
			change = false
		end

	end

	if change then
		GameController.setFlag( 'game.phase', 2 )
	end

end