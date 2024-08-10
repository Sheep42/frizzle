GamePhase_Phase4 = {}
class( 'GamePhase_Phase4' ).extends( 'State' )

local phase = GamePhase_Phase4

-- Constructor
function phase:init( scene )

	phase.super.init( self, "phase-4" )
	self.owner = scene

	self.games = {
		feeding = {
		},
		petting = {
		},
		playing = {
		},
		grooming = {},
		sleeping = {
		},
	}

	self.dots = 1
	self.deleteText = "DELETING..."
	local textW, textH = Graphics.getTextSize( self.deleteText, self.introFont )
	self.dialogue = Dialogue(
		self.deleteText,
		(Utilities.screenSize().width / 2) - ((textW + 50) / 2),
		(Utilities.screenSize().height / 2) - ((textH + 15) / 2),
		false,
		textW + 50,
		textH + 15,
		4,
		4,
		DialogueType.Instant,
		2000,
		self.introFont
	)

	self.dialogue:disableIndicator()

	self.fullCranks = 0
	self.endTimer = nil
	self.crankTimer = nil
	self.noCrankTimer = nil
	self.cranked = 0
	self.crankDelta = 0
	self.crankAcceleration = 0

	self.lastCrankTick = 0
	self.crankTick = 0

	self.inputHandler = {
		AButtonDown = function()

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
		cranked = function( change, acceleratedChange )

			if not GameController.getFlag( 'game.phase4.crankToEnd' ) and not GameController.getFlag( 'game.resetCrank' ) then
				return
			end

			if change < 0 then
				return
			end

			self.cranked += change
			self.crankDelta = change
			self.crankAcceleration = acceleratedChange

			self.lastCrankTick = self.crankTick
			self.crankTick += change

		end,
	}

	self.newPet = NobleSprite( 'assets/images/player' )

end

-- Fires when the Phase is entered
function phase:enter()

	PlayScene.setInputHandler( self.inputHandler )

	self.owner.petBtn:setPressedCallback( function()
	end)

	self.owner.sleepBtn:setPressedCallback( function()
	end)

	self.owner.feedBtn:setPressedCallback( function()
	end)

	self.owner.playBtn:setPressedCallback( function ()
	end)

	if not GameController.getFlag( 'game.phase3.resetTriggered' ) then
		return
	end

	if not GameController.getFlag( 'game.phase4.playedIntro' ) then

		GameController.setFlag( 'dialogue.currentScript', 'phase4Intro' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()

	else if not GameController.getFlag( 'game.phase4.systemCrash' ) then

		local script = 'gameFinishedNarrator'
		if GameController.getFlag( 'game.frizzleWon' ) then
			script = 'gameFinishedFrizzle'
		end

		if GameController.getFlag( 'game.doDataReset' ) then
			GameController.setFlag( 'dialogue.buttonPressEnabled', true )
			GameController.setFlag( 'game.doDataReset', false )
			script = 'dataResetNarrator'

			if GameController.getFlag( 'game.frizzleWon' ) then
				script = 'dataResetFrizzle'
			end
		end

		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()

	end

	self.owner.tv.animation:setState( 'static' )

	self.owner:softRestart()

end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	self:phaseHandler()

	if GameController.getFlag( 'game.phase4.systemCrash' ) then
		Noble.transition( CrashScene, 0, Noble.TransitionType.CUT )
	end

	self.dialogue:drawCanvas()
	self.dialogue:update()

	if GameController.getFlag( 'game.hideFrizzle' ) and GameController.pet:isVisible() then
		GameController.pet:remove()
	end

	if GameController.getFlag( 'game.phase4.loadBrokenSound' ) then
		self.owner.bgMusic:stop()
		self.owner.bgMusic = Sound.fileplayer.new( 'assets/sound/main-broken' )
		self.owner.bgMusic:setVolume( 0.5 )
		self.owner.bgMusic:play(0)
		GameController.setFlag( 'game.phase4.loadBrokenSound', false )
	end

	if GameController.getFlag( 'game.phase4.glitchSound' ) then
		self.owner.bgMusic:stop()
		self.owner.bgMusic:play()
	end

	if GameController.getFlag( 'game.phase4.deleteSparkle' ) then
		self.owner.sparkle:setImage( self.owner.sparkle.animation.imageTable:getImage( self.owner.sparkle.animation.currentFrame ):vcrPauseFilterImage() )
		Timer.new( ONE_SECOND, function()
			self.owner.sparkle:remove()
			GameController.setFlag( 'game.phase4.deleteSparkle', false )
			GameController.setFlag( 'game.phase4.glitchSound', false )
			GameController.setFlag( 'game.phase4.loadBrokenSound', true )
			GameController.setFlag( 'game.phase4.glitchTv', true )
		end)
	end

	if GameController.getFlag( 'game.phase4.crankToEnd' ) then
		Noble.Input.setCrankIndicatorStatus( true )
		self:handleCrankToEnd()

		if endTimer == nil then
			endTimer = Timer.new( ONE_SECOND * 30, function()

				if self.fullCranks >= 10 then
					GameController.setFlag( 'dialogue.currentScript', 'narratorWins' )
				else
					GameController.setFlag( 'dialogue.currentScript', 'frizzleWins' )
				end

				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()

			end )
		end
	end


	if GameController.getFlag( 'game.resetCrank' ) then
		self:handleCrankToReset()
	end

	if GameController.getFlag( 'game.phase4.deletePet' ) then
		GameController.pet:setImage( GameController.pet.animation.imageTable:getImage( GameController.pet.animation.currentFrame ):vcrPauseFilterImage() )
	else
		GameController.pet:setImage( GameController.pet.animation.imageTable:getImage( GameController.pet.animation.currentFrame ) )
	end

	if GameController.getFlag( 'game.phase4.glitchTv' ) then

		GameController.setFlag( 'game.phase4.glitchTv', false )
		self.owner:glitchTv()

	end

	if GameController.getFlag( 'game.rollCredits' ) then
		GameController.setFlag( 'game.rollCredits', false )
		Noble.transition( CreditScene, 1.5, Noble.TransitionType.DIP_TO_BLACK )
	end

	if GameController.getFlag( 'game.phase4.movePetToCenter' ) then

		GameController.pet:moveBy( -1, 0 )
		local x, y = GameController.pet:getPosition()

		if x <= Utilities.screenSize().width / 2 then
			GameController.setFlag( 'game.phase4.movePetToCenter', false )
		end

	end

	self.owner:phase4Tick()

end

function phase:phaseHandler()

end

function phase:handleInteractableClick()

	if GameController.dialogue:getState() == DialogueState.Show then
		return false
	end

	if not GameController.getFlag( 'game.frizzleWon' ) and not GameController.getFlag( 'game.narratorWon' ) then
		return false
	end

	return self.owner:phase4Interact()

end

function phase:handleCrankToEnd()

	if GameController.dialogue:getState() == DialogueState.Show then
		if self.crankTimer ~= nil then
			self.crankTimer:reset()
			self.crankTimer:pause()
			self.crankTimer = nil
		end

		if self.noCrankTimer ~= nil then
			self.noCrankTimer:reset()
			self.noCrankTimer:pause()
			self.noCrankTimer = nil
		end

		return
	end

	if self.cranked > 5 then

		if self.noCrankTimer ~= nil then
			self.noCrankTimer:reset()
			self.noCrankTimer:pause()
			self.noCrankTimer = nil
		end

		GameController.setFlag( 'game.phase4.deletePet', true )
		self.cranked = 0

		if self.crankTick >= 360 then
			self.crankTick = ( self.crankTick % 360 )
			self.fullCranks += 1
		end


		if self.crankTimer == nil then
			self.crankTimer = Timer.new( ONE_SECOND * 3, function()
				local dialogueIndex = math.random(4)
				GameController.setFlag( 'dialogue.currentScript', 'playerCranking' .. tostring( dialogueIndex ) )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)
		end

	else
		GameController.setFlag( 'game.phase4.deletePet', false )

		if self.crankTimer ~= nil then
			self.crankTimer:reset()
			self.crankTimer:pause()
			self.crankTimer = nil
		end

		if self.noCrankTimer == nil then
			self.noCrankTimer = Timer.new( ONE_SECOND * 5, function()
				local dialogueIndex = math.random(4)
				GameController.setFlag( 'dialogue.currentScript', 'playerNotCranking' .. tostring( dialogueIndex ) )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)
		end
	end

end

function phase:handleCrankToReset()

	if self.fullCranks >= 15 then
		GameController.deleteData()
		GameController.reset()
	end

	if self.cranked > 30 then

		if self.noCrankTimer ~= nil then
			self.noCrankTimer:reset()
			self.noCrankTimer:pause()
			self.noCrankTimer = nil
		end

		self.cranked = 0

		if self.crankTick >= 360 then
			self.crankTick = ( self.crankTick % 360 )
			self.fullCranks += 1
			self.dots = 1 + ( self.fullCranks % 3 )
			self.dialogue:setText( "DELETING" .. string.rep( '.', self.dots ) )
		end

		self.dialogue:show()

	else

		if self.noCrankTimer == nil then
			self.noCrankTimer = Timer.new( ONE_SECOND * 0.5, function()
				self.fullCranks = 0
				self.dots = 1
				self.dialogue:hide()
			end)
		end

	end

end
