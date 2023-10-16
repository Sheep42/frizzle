PetState_Idle = {}
class( "PetState_Idle" ).extends( State )
local state = PetState_Idle

function state:init( id )
	state.super.init( self, id )
end

-- Fires when a State is entered
function state:enter() end

-- Fires when a State is exited
function state:exit() end

-- Fires when the State Machine updates
function state:tick() 
	print( "idle" ) 
end