PetState_Active = {}
class( "PetState_Active" ).extends( State )
local state = PetState_Active

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
	self.owner:tickStats()
end