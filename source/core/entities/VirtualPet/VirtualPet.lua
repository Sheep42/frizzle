VirtualPet = {}
class( "VirtualPet" ).extends( NobleSprite )
local pet = VirtualPet

pet._states = {}
pet._stateMachine = nil
pet._spritesheet = "assets/images/pet"
pet._animations = {
	idle = {
		name = "idle",
		startFrame = 1,
		endFrame = 6,
		frameDuration = 15,
	},
}

function pet:init()

	-- Create Base NobleSprite
	self:setSize( 64, 64 )

	-- Set up animation states
	local animation = Noble.Animation.new( self._spritesheet )
	for key, anim in pairs( self._animations ) do

		local _frameDuration = 15 
		if nil ~= anim.frameDuration then
			_frameDuration = anim.frameDuration
		end

		-- Add state
		animation:addState( anim.name, anim.startFrame, anim.endFrame, nil, nil, nil, _frameDuration )

	end

	-- Create the pet
	pet.super.init( self, animation )

	-- Set up logic states
	self._states = {
		IdleState = PetState_Idle( "idle", self ),
	}

	self._stateMachine = StateMachine( self._states.IdleState, self._states )

end

function pet:update()

	pet.super.update( self )
	self._stateMachine:update()

end