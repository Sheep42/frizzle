VirtualPet = {}
class( "VirtualPet" ).extends( NobleSprite )
local pet = VirtualPet

pet._states = {}
pet._stateMachine = nil

function pet:init( __spritesheet )

	-- TODO: Handle animations
	pet.super.init( self, __spritesheet )

	self._states = {
		IdleState = PetState_Idle( "idle" ),
	}

	self._stateMachine = StateMachine( self._states.IdleState, self._states )

end

function pet:update()

	pet.super.update( self )
	self._stateMachine:update()

end