StatBarState_Paused = {}
class( "StatBarState_Paused" ).extends( State )
local state = StatBarState_Paused

function state:init( id, owner )
	state.super.init( self, id )
	self.owner = owner
end

-- Fires when a State is entered
function state:enter() end

-- Fires when a State is exited
function state:exit() end

-- Fires when the State Machine updates
function state:tick() 

	if GameController.dialogue:getState() == DialogueState.Show then
		return
	end

	self.owner.stateMachine:changeState( self.owner.states.active )

end