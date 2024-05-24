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
		playing = {},
		grooming = {},
		sleeping = {
		},
	}

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

	if not GameController.getFlag( 'game.phase3.resetTriggered' ) then
		return
	end

	if not GameController.getFlag( 'game.phase4.playedIntro' ) then

		GameController.setFlag( 'dialogue.currentScript', 'phase4Intro' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()

	else

		GameController.setFlag( 'dialogue.currentScript', 'gameFinished' )
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

	if GameController.getFlag( 'game.phase4.playedIntro' ) and GameController.pet:isVisible() then
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
		self.owner.sparkle:setImage( self.owner.sparkle:getImage():vcrPauseFilterImage() )
		Timer.new( ONE_SECOND, function()
			self.owner.sparkle:remove()
			GameController.setFlag( 'game.phase4.deleteSparkle', false )
			GameController.setFlag( 'game.phase4.glitchSound', false )
			GameController.setFlag( 'game.phase4.loadBrokenSound', true )
			GameController.setFlag( 'game.phase4.glitchTv', true )
		end)
	end

	if GameController.getFlag( 'game.phase4.deletePet' ) then
		-- TODO: Play glitched animation
	end

	if GameController.getFlag( 'game.phase4.glitchTv' ) then

		GameController.setFlag( 'game.phase4.glitchTv', false )
		self.owner:glitchTv()

	end

	if GameController.getFlag( 'game.phase4.movePetToCenter' ) then

		GameController.pet:moveBy( -1, 0 )
		local x, y = GameController.pet:getPosition()

		if x <= Utilities.screenSize().width / 2 then
			GameController.setFlag( 'game.phase4.movePetToCenter', false )
		end

	end

end

function phase:phaseHandler()

end

function phase:handleInteractableClick()

	if GameController.dialogue:getState() == DialogueState.Show then
		return false
	end

	local collision = self.owner.window:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickWindow4' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.owner.vase:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickVaseTable4' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.owner.table:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickVaseTable4' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.owner.tv:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickTv4' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	return false

end