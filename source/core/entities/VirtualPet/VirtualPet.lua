VirtualPet = {}
class( "VirtualPet" ).extends( NobleSprite )
local pet = VirtualPet

pet._spritesheet = "assets/images/pet"
pet._animations = {
	idle = {
		name = "idle",
		startFrame = 1,
		endFrame = 6,
	},
}

function pet:init()

	-- This is a really gross way to make VirtualPet a singleton, but I'm the 
	-- only person who has to read this stinky code, so it's probably fine
	-- Famous last words

	GameController.pet = self

	-- Create Base NobleSprite
	self:setSize( 64, 64 )

	self._statTimer = nil
	self.stats = {
		hunger = {
			key = 'hunger',
			icon = 'assets/images/UI/feed',
			gameType = MicrogameType.feeding,
			crySound = 'assets/sound/cry.wav',
			value = 5,
			hidden = false,
		},
		boredom = {
			key = 'boredom',
			icon = 'assets/images/UI/heart',
			gameType = MicrogameType.playing,
			crySound = 'assets/sound/cry.wav',
			value = 5,
			hidden = true,
		},
		groom = {
			key = 'groom',
			icon = 'assets/images/UI/heart',
			gameType = MicrogameType.grooming,
			crySound = 'assets/sound/cry.wav',
			value = 5,
			hidden = true,
		},
		friendship = {
			key = 'friendship',
			icon = 'assets/images/UI/heart',
			gameType = MicrogameType.petting,
			crySound = 'assets/sound/cry.wav',
			value = 5,
			hidden = false,
		},
		tired = {
			key = 'tired',
			icon = 'assets/images/UI/sleep',
			gameType = MicrogameType.sleeping,
			crySound = 'assets/sound/cry.wav',
			value = 5,
			hidden = false,
		},
		anger = {
			key = 'anger',
			icon = 'assets/images/UI/heart',
			crySound = 'assets/sound/cry.wav',
			gameType = nil,
			value = 0,
			hidden = true,
		},
		obsessiveness = {
			key = 'obsessiveness',
			icon = 'assets/images/UI/heart',
			crySound = 'assets/sound/cry.wav',
			gameType = nil,
			value = 0,
			hidden = true,
		},
		selfAwareness = {
			key = 'selfAwareness',
			icon = 'assets/images/UI/heart',
			crySound = 'assets/sound/cry.wav',
			gameType = nil,
			value = 0,
			hidden = true,
		},
	}

	self.lowStats = {}

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
	self.states = {
		paused = PetState_Paused( "paused" ),
		active = PetState_Active( "active" ),
	}

	self.stateMachine = StateMachine( self.states.paused, self.states )

end

function pet:update()

	pet.super.update( self )
	self.stateMachine:update()

end

function pet:tickStats()

	if self._statTimer == nil then
		local duration = math.random( 3, 6 ) * 1000
		self._statTimer = Timer.new( duration, 0, duration )
	end

	if self._statTimer.value >= self._statTimer.duration then

		self._statTimer = nil

		for key, stat in pairs( self.stats ) do

			-- Don't touch hidden stats
			if stat.hidden then
				goto continue -- lol, Lua
			end

			-- Don't touch stats at 0
			if self.stats[key].value <= 0 then
				goto continue
			end

			-- 30% chance to skip a stat
			if math.random() >= 0.3 then
				goto continue
			end

			self.stats[key].value -= 1

			::continue::

		end

	end

end

function pet:resetStats()

	for key, stat in pairs( self.stats ) do
		stat.value = 5
	end

end