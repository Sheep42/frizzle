PetState_Idle = {}
class( "PetState_Idle" ).extends( State )
local state = PetState_Idle

function state:init( id, owner )
	
	state.super.init( self, id )
	self.owner = owner

end

-- Fires when a State is entered
function state:enter() 
	self.owner.animation:setState( self.owner._animations.idle.name )
end

-- Fires when a State is exited
function state:exit() end

-- Fires when the State Machine updates
function state:tick() 

end