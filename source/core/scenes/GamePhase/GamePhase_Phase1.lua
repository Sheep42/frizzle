GamePhase_Phase1 = {}
class( 'GamePhase_Phase1' ).extends( 'State' )

local phase = GamePhase_Phase1 

-- Constructor
function phase:init()
	phase.super.init( self, "phase-1" )
end

-- Fires when the Phase is entered
function phase:enter() end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick() 
	print( "phase 1" )
end