StatBarState_Active = {}
class( "StatBarState_Active" ).extends( State )
local state = StatBarState_Active

function state:init( id, owner )
	state.super.init( self, id )
	self.owner = owner
end

-- Fires when a State is entered
function state:enter() 
	
end

-- Fires when a State is exited
function state:exit() end

-- Fires when the State Machine updates
function state:tick() 
	
	if GameController.getFlag( 'dialogue.show' ) then
		self.owner.stateMachine:changeState( self.owner.states.paused )	
	end

	if #self.owner.sprites ~= GameController.pet.stats[self.owner.stat] then
		self.owner:removeSprites()
		self.owner:addSprites()	
	end

end