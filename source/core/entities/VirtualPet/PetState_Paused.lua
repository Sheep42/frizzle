PetState_Paused = {}
class( "PetState_Paused" ).extends( State )
local state = PetState_Paused

function state:init( id )
	state.super.init( self, id )
end

-- Fires when a State is entered
function state:enter() end

-- Fires when a State is exited
function state:exit() end

-- Fires when the State Machine updates
function state:tick()

	if GameController.dialogue:getState() == DialogueState.Show or GameController.getFlag( 'pet.state' ) == GameController.pet.states.paused.id then
		return
	end

	GameController.pet.stateMachine:changeState( GameController.pet.states.active )

end