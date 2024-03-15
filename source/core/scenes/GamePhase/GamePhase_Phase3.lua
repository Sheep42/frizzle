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
		playing = {},
		grooming = {},
		sleeping = {
			Sleeping_Phase3,
		},
	}

	self.inputHandler = {
		AButtonDown = function()
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

	self.owner:softRestart()

end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	self:phaseHandler()

end

function phase:phaseHandler()

end