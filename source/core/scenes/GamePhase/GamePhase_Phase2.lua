GamePhase_Phase2 = {}
class( 'GamePhase_Phase2' ).extends( 'State' )

local phase = GamePhase_Phase2 

-- Constructor
function phase:init( scene )
	phase.super.init( self, "phase-2" )
	self.owner = scene

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
end

-- Fires when the Phase is entered
function phase:enter() 

	self.owner.inputHandler = {
		AButtonDown = function()
			self.owner:checkABtnPress()
		end,
		BButtonDown = function()

			if Noble.Settings.get( 'debug_mode' ) then
				Noble.transition( TitleScene )
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

	-- Button Press Handlers
	self.owner.petBtn:setPressedCallback( function()
		GameController.dialogue:setText( "Z A L G O . . .\n\nHe c0m3z" )
		GameController.dialogue:show()
	end)

	self.owner.feedBtn:setPressedCallback( function ()
	end)

	-- self.owner.playBtn:setPressedCallback( function ()
	-- end)

	-- self.owner.groomBtn:setPressedCallback( function ()
	-- end)

	self.owner.sleepBtn:setPressedCallback( function ()
	end)

end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	self:phaseHandler()
	self.owner:handleStatNag( self.games )

end

function phase:phaseHandler()

end