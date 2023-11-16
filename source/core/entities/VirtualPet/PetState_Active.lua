PetState_Active = {}
class( "PetState_Active" ).extends( State )
local state = PetState_Active

function state:init( id )
	state.super.init( self, id )
end

-- Fires when a State is entered
function state:enter() 
	GameController.pet.animation:setState( GameController.pet._animations.idle.name )
end

-- Fires when a State is exited
function state:exit() end

-- Fires when the State Machine updates
function state:tick() 
	GameController.pet:tickStats()
end