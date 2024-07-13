GamePhase_Phase3 = {}
class( 'GamePhase_Phase3' ).extends( 'State' )

local phase = GamePhase_Phase3

-- Constructor
function phase:init( scene )

	phase.super.init( self, "phase-3" )
	self.owner = scene

	self.games = {
		feeding = {
			Feeding_CrankGame_Phase3,
		},
		petting = {
			Petting_CrankGame_Phase3,
		},
		playing = {
			Playing_CopyGame_Phase3,
		},
		grooming = {},
		sleeping = {
			Sleeping_Phase3,
		},
	}

	self.inputHandler = {
		AButtonDown = function()

			if GameController.getFlag( 'game.playRecording' ) then
				return
			end

			if self:handleInteractableClick() then
				return
			end

			self.owner:checkABtnPress()

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

	self.buffer = playdate.sound.sample.new( 2, playdate.sound.kFormat16bitMono )

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

	self.owner.playBtn:setPressedCallback( function ()
		self.owner:handleBtnPress( MicrogameType.playing, self.games )
	end)

	self.owner.sleepBtn:setPressedCallback( function()
		self.owner:handleBtnPress( MicrogameType.sleeping, self.games )
	end)

	if GameController.getFlag( 'game.phase3.disableBtn.petting' ) then
		self.owner.petBtn:setPressedCallback( function()
			GameController.setFlag( 'dialogue.currentScript', 'phase3BtnAfterFinish' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
		end)
	end

	if GameController.getFlag( 'game.phase3.disableBtn.sleeping' ) then
		self.owner.sleepBtn:setPressedCallback( function()
			GameController.setFlag( 'dialogue.currentScript', 'phase3BtnAfterFinish' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
		end)
	end

	if GameController.getFlag( 'game.phase3.disableBtn.feeding' ) then
		self.owner.feedBtn:setPressedCallback( function()
			GameController.setFlag( 'dialogue.currentScript', 'phase3BtnAfterFinish' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
		end)
	end

	if GameController.getFlag( 'game.phase3.disableBtn.playing' ) then
		self.owner.playBtn:setPressedCallback( function()
			GameController.setFlag( 'dialogue.currentScript', 'phase3BtnAfterFinish' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
		end)
	end

	self.owner:softRestart()
	self.owner.bgMusic:load( 'assets/sound/main-crack' )

	-- Check if all games are finished
	if GameController.getFlag( 'game.phase3.finished' ) ~= nil and not GameController.getFlag( 'game.phase3.allFinished' ) then

		local finished = GameController.getFlag( 'game.phase3.finished' )
		if type( finished ) ~= 'table' then
			return
		end

		local allFinished = true
		for k, v in pairs( finished ) do
			if v == false then
				allFinished = false
				break;
			end
		end

		if allFinished then
			GameController.setFlag( 'game.phase3.allFinished', true )
		end

	end

	-- Reset playedFinish to avoid softlock
	GameController.setFlag( 'game.phase3.playedFinish', false )

end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	if GameController.getFlag( 'game.phase3.allFinished' ) and not GameController.getFlag( 'game.phase3.playedFinish' ) then

		Timer.new( ONE_SECOND * 2, function()
			if GameController.dialogue:getState() == DialogueState.Hide then
				GameController.setFlag( 'game.phase3.playedFinish', true )
				GameController.setFlag( 'dialogue.currentScript', 'phase3Finished' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end
		end)

	end

	if GameController.getFlag( 'game.playRecording' ) then
		self:playRecording()
		GameController.setFlag( 'game.playRecording', false )
	end

	if GameController.getFlag( 'game.phase3.glitchTv' ) then

		GameController.setFlag( 'game.phase3.glitchTv', false )
		self.owner:glitchTv()

	end

	self:phaseHandler()
	self.owner:phase3Tick()

end

function phase:phaseHandler()

	if GameController.getFlag( 'game.phase' ) == 4 then
		self.stateMachine:changeState( self.owner.phases.phase4 )
		return
	end

end

function phase:playRecording()

	if type( GameController.getFlag( 'game.playerSample' ) ) == 'nil' then
		self:progressDialogue()
		return
	end

	self.buffer:load( GameController.getFlag( 'game.playerSample' ) )
	if self.buffer == nil then
		return
	end

	local player = Sound.sampleplayer.new( self.buffer )
	player:play()
	player:setFinishCallback( function()
		self:progressDialogue()
	end)

end

function phase:progressDialogue()
	GameController.setFlag( 'dialogue.currentScript', 'phase3FinishedPt2' )
	GameController.setFlag( 'dialogue.currentLine', 1 )
	GameController.dialogue:setText( GameController.advanceDialogueLine() )
	GameController.dialogue:show()
end

function phase:handleInteractableClick()

	if GameController.dialogue:getState() == DialogueState.Show then
		return false
	end

	return self.owner:phase3Interact()

end