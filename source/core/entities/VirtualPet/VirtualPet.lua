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
	},
}

pet._statTimer = nil

pet.stats = {
	hunger = 5,
	boredom = 5,
	groom = 5,
	friendship = 5,
	tired = 5,
}

function pet:init()

	-- This is a really gross way to make VirtualPet a singleton, but I'm the 
	-- only person who has to read this stinky code, so it's probably fine
	-- Famous last words

	if GameController.pet ~= nil then
		return GameController.pet
	end
	
	GameController.pet = self

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
		IdleState = PetState_Active( "active" ),
	}

	self._stateMachine = StateMachine( self._states.IdleState, self._states )

end

function pet:update()

	pet.super.update( self )
	self._stateMachine:update()

end

function pet:tickStats()

	if self._statTimer == nil then
		local duration = math.random( 3, 6 ) * 1000
		self._statTimer = Timer.new( duration, 0, duration )
	end

	if self._statTimer.value >= self._statTimer.duration then

		self._statTimer = nil

		if self.stats.hunger > 0 then
			self.stats.hunger -= 1
		end
	
		if self.stats.boredom > 0 then
			self.stats.boredom -= 1
		end
	
		if self.stats.friendship > 0 then
			self.stats.friendship -= 1
		end
	
		if self.stats.groom > 0 then
			self.stats.groom -= 1
		end
	
		if self.stats.tired > 0 then
			self.stats.tired -= 1
		end

	end

end