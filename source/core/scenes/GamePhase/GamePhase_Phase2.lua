GamePhase_Phase2 = {}
class( 'GamePhase_Phase2' ).extends( 'State' )

local phase = GamePhase_Phase2

-- Constructor
function phase:init( scene )
	phase.super.init( self, "phase-2" )
	self.owner = scene

	self.buffer = playdate.sound.sample.new( 2, playdate.sound.kFormat16bitMono )
	self.listening = false

	self.games = {
		feeding = {
			Feeding_ShakeGame,
		},
		petting = {
			Petting_CrankGame,
			Petting_ShakeGame,
		},
		playing = {},
		grooming = {},
		sleeping = {
			Sleeping_MicGame,
		},
	}

	self.inputHandler = {
		AButtonDown = function()
			self.owner:checkABtnPress()
		end,
		BButtonDown = function()

			if Noble.Settings.get( 'debug_mode' ) then
			-- 	-- Noble.transition( TitleScene )
				self.buffer:load( 'name' )

				if self.buffer ~= nil then
					local pl = Sound.sampleplayer.new( self.buffer )
					pl:play()
				end
			end

		end,
		downButtonUp = function ()

			if self.owner.cursor ~= nil then
				if self.owner.cursor.velocity.y < 0 then
					return
				end

				self.owner:setCursorVelocity( { x = self.owner.cursor.velocity.x, y = 0 } )
			end

		end,
		upButtonUp = function ()

			if self.owner.cursor ~= nil then
				if self.owner.cursor.velocity.y > 0 then
					return
				end

				self.owner:setCursorVelocity( { x = self.owner.cursor.velocity.x, y = 0 } )
			end	

		end,
		leftButtonUp = function ()

			if self.owner.cursor ~= nil then
				if self.owner.cursor.velocity.x > 0 then
					return
				end

				self.owner:setCursorVelocity( { x = 0, y = self.owner.cursor.velocity.y } )
			end	

		end,
		rightButtonUp = function ()

			if self.owner.cursor ~= nil then
				if self.owner.cursor.velocity.x < 0 then
					return
				end

				self.owner:setCursorVelocity( { x = 0, y = self.owner.cursor.velocity.y } )
			end	

		end,
		downButtonDown = function ()
			self.owner.dbgMenu:selectNext()
			self.owner:setCursorVelocity( { x = self.owner.cursor.velocity.x, y = PlayScene._CURSOR_SPEED_MULTIPLIER } )
		end,
		upButtonDown = function ()
			self.owner.dbgMenu:selectPrevious()
			self.owner:setCursorVelocity( { x = self.owner.cursor.velocity.x, y = - PlayScene._CURSOR_SPEED_MULTIPLIER } )
		end,
		leftButtonDown = function ()
			self.owner:setCursorVelocity( { x = - PlayScene._CURSOR_SPEED_MULTIPLIER, y = self.owner.cursor.velocity.y } )
		end,
		rightButtonDown = function ()
			self.owner:setCursorVelocity( { x =  PlayScene._CURSOR_SPEED_MULTIPLIER, y = self.owner.cursor.velocity.y } )
		end,
	}

end

-- Fires when the Phase is entered
function phase:enter()

	PlayScene.setInputHandler( self.inputHandler )

	-- Button Press Handlers
	self.owner.petBtn:setPressedCallback( function()
		GameController.dialogue:setText( "Z A L G O . . .\n\nHe c0m3z" )
		GameController.dialogue:show()
	end)

	self.owner.feedBtn:setPressedCallback( function ()
		GameController.dialogue:setText( "Z A L G O . . .\n\nHe c0m3z" )
		GameController.dialogue:show()
	end)

	-- self.owner.playBtn:setPressedCallback( function ()
	-- end)

	-- self.owner.groomBtn:setPressedCallback( function ()
	-- end)

	self.owner.sleepBtn:setPressedCallback( function ()
		GameController.dialogue:setText( "Z A L G O . . .\n\nHe c0m3z" )
		GameController.dialogue:show()
	end)

	Timer.new( ONE_SECOND * 3, function()
		GameController.setFlag( 'dialogue.currentScript', 'petIntro' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
	end)

	self.owner:softRestart()

end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	if GameController.getFlag( 'game.listenForName' ) then
		self:recordName()
		return
	end

	self:phaseHandler()
	self.owner:handleStatNag( self.games )

end

function phase:phaseHandler()

end

function phase:recordName()

	if not self.listening then
		Sound.micinput.startListening()
		self.listening = true

		Timer.new( ONE_SECOND * 0.25, function()

			-- TODO: Save buffer to file?
			-- TODO: Live with whatever audio we get?
			Sound.micinput.recordToSample( self.buffer, function ( sample )
				Sound.micinput.stopListening()
				self.listening = false

				local path = 'name'
				GameController.setFlag( 'game.listenForName', false )
				GameController.setFlag( 'game.nameSample', path )
				sample:save( path )

				GameController.setFlag( 'dialogue.currentScript', 'nameRecorded' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)

		end)
	end

end