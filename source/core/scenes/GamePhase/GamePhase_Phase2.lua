GamePhase_Phase2 = {}
class( 'GamePhase_Phase2' ).extends( 'State' )

local phase = GamePhase_Phase2

phase.playerSamplePath = 'playerSample'

-- Constructor
function phase:init( scene )
	phase.super.init( self, "phase-2" )
	self.owner = scene

	self.buffer = playdate.sound.sample.new( 2, playdate.sound.kFormat16bitMono )
	self.listening = false
	self.screenshot = nil

	self.games = {
		feeding = {
			Feeding_CrankGame,
			Feeding_CrankGame_Phase2,
			Feeding_CrankGame_Phase2,
		},
		petting = {
			Petting_CrankGame,
			Petting_CrankGame_Phase2,
			Petting_CrankGame_Phase2,
		},
		playing = {},
		grooming = {},
		sleeping = {
			Sleeping_MicGame,
			Sleeping_MicGame_Phase2,
			Sleeping_MicGame_Phase2,
		},
	}

	self.inputHandler = {
		AButtonDown = function()

			if GameController.getFlag( 'game.phase2.playedMicroGame' ) and not GameController.getFlag( 'game.phase2.playerRecorded' ) then

				local limit = false
				for k, v in pairs( GameController.getFlag( 'game.gamesPlayed' ) ) do
					if v >= 3 then
						limit = true
						break
					end
				end

				if (limit or GameController.getFlag( 'game.playTime' ) >= 360) and GameController.dialogue:getState() ~= DialogueState.Show then
					GameController.setFlag( 'statBars.paused', true )
					GameController.setFlag( 'buttons.active', false )
					GameController.setFlag( 'dialogue.currentScript', 'petRecord' )
					GameController.setFlag( 'dialogue.currentLine', 1 )
					GameController.dialogue:setText( GameController.advanceDialogueLine() )
					GameController.dialogue:show()
					return
				end

			end

			if GameController.getFlag( 'game.phase2.playedMicroGame' ) and not GameController.getFlag( 'game.phase2.narratorAfterPet' ) and GameController.getFlag( 'game.phase2.playerRecorded' ) then

				local limit = false
				for k, v in pairs( GameController.getFlag( 'game.gamesPlayed' ) ) do
					if v >= 5 then
						limit = true
						break
					end
				end

				if (limit or GameController.getFlag( 'game.playTime' ) >= 500) and GameController.dialogue:getState() ~= DialogueState.Show then
					GameController.setFlag( 'game.phase2.narratorAfterPet', true )
					GameController.setFlag( 'statBars.paused', true )
					GameController.setFlag( 'buttons.active', false )
					GameController.setFlag( 'dialogue.currentScript', 'narratorAfterPetIntro' )
					GameController.setFlag( 'dialogue.currentLine', 1 )
					GameController.dialogue:setText( GameController.advanceDialogueLine() )
					GameController.dialogue:show()
					return
				end

			end

			if self:handleInteractableClick() then
				return
			end

			self.owner:checkABtnPress()

		end,
		BButtonDown = function()

			if Noble.Settings.get( 'debug_mode' ) then
			-- 	-- Noble.transition( TitleScene )
				self.buffer:load( phase.playerSamplePath )

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
		self.owner:handleBtnPress( MicrogameType.petting, self.games )
	end)

	self.owner.feedBtn:setPressedCallback( function()
		self.owner:handleBtnPress( MicrogameType.feeding, self.games )
	end)

	self.owner.sleepBtn:setPressedCallback( function()
		self.owner:handleBtnPress( MicrogameType.sleeping, self.games )
	end)

	-- self.owner.feedBtn:setPressedCallback( function ()
	-- 	GameController.dialogue:setText( "Z A L G O . . .\n\nHe c0m3z" )
	-- 	GameController.dialogue:show()
	-- end)

	-- self.owner.playBtn:setPressedCallback( function ()
	-- end)

	-- self.owner.groomBtn:setPressedCallback( function ()
	-- end)

	-- self.owner.sleepBtn:setPressedCallback( function ()
	-- 	GameController.dialogue:setText( "Z A L G O . . .\n\nHe c0m3z" )
	-- 	GameController.dialogue:show()
	-- end)

	if not GameController.getFlag( 'dialogue.playedPhase2Intro' ) then

		GameController.setFlag( 'buttons.active', false )

		Timer.new( ONE_SECOND * 3, function()
			GameController.setFlag( 'dialogue.currentScript', 'narratorIntro' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
		end)

	end

	if GameController.getFlag( 'game.phase2.narratorAfterPet' ) then
		self.games.feeding = {
			Feeding_CrankGame_Phase2,
			Feeding_CrankGame_Phase2_Glitch,
		}
		self.games.petting = {
			Petting_CrankGame_Phase2,
			Petting_CrankGame_Phase2_Glitch,
		}
		self.games.sleeping = {
			Sleeping_MicGame_Phase2,
			Sleeping_MicGame_Phase2_Glitch,
		}
	end

	if GameController.getFlag( 'game.phase2.playedGlitchGame' ) and not GameController.getFlag( 'game.phase2.didGlitchScreen' ) then
		GameController.setFlag( 'game.phase2.didGlitchScreen', true )
		Timer.new( ONE_SECOND * 0.25, function()
			GameController.setFlag( 'dialogue.currentScript', 'narratorAfterGlitch' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
		end )
	end

	self.owner:softRestart()

end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	if GameController.getFlag( 'game.listenForPlayer' ) then
		self:recordPlayer()
		return
	end

	if GameController.getFlag( 'game.glitchScreen' ) then
		if self.screenshot == nil then
			self.screenshot = Graphics.getDisplayImage()
		end

		self.screenshot = self.screenshot:vcrPauseFilterImage()
		self.screenshot:draw( 0, 0 )
	end

	self:phaseHandler()
	self.owner:handleStatNag( self.games )

end

function phase:phaseHandler()

	if GameController.getFlag( 'game.phase' ) == 3 then
		self.stateMachine:changeState( self.owner.phases.phase3 )
		return
	end

	local change = true

	if GameController.getFlag( 'game.playTime' ) < GameController.PHASE_3_TIME_TRIGGER then
		for k, v in pairs( GameController.PHASE_3_GAME_TRIGGERS ) do

			local flagVal = GameController.getFlag( 'game.gamesPlayed.' .. k )
			if flagVal < v then
				change = false
			end

		end
	end

	if change then
		GameController.setFlag( 'game.phase', 3 )
	end

end

function phase:recordPlayer()

	if not self.listening then
		Sound.micinput.startListening()
		self.listening = true

		Timer.new( ONE_SECOND * 0.25, function()

			-- TODO: Live with whatever audio we get?
			Sound.micinput.recordToSample( self.buffer, function ( sample )
				Sound.micinput.stopListening()
				self.listening = false

				GameController.setFlag( 'game.listenForPlayer', false )
				GameController.setFlag( 'game.playerSample', phase.playerSamplePath )
				sample:save( phase.playerSamplePath )

				GameController.setFlag( 'dialogue.currentScript', 'playerRecorded' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)

		end)
	end

end

function phase:handleInteractableClick()

	if GameController.dialogue:getState() == DialogueState.Show then
		return false
	end

	local collision = self.owner.window:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickWindow' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.owner.vase:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickVase' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.owner.table:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickTable' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.owner.tv:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickTv' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	return false

end