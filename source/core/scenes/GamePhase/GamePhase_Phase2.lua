GamePhase_Phase2 = {}
class( 'GamePhase_Phase2' ).extends( 'State' )

local phase = GamePhase_Phase2 

-- Constructor
function phase:init( scene )
	phase.super.init( self, "phase-2" )
	self.owner = scene
end

-- Fires when the Phase is entered
function phase:enter() end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	self:phaseHandler()
	print( 'PHASE 2' )

end

function phase:phaseHandler() 

end