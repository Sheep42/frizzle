GamePhase_Phase1 = {}
class( 'GamePhase_Phase1' ).extends( 'State' )

local phase = GamePhase_Phase1 

-- Constructor
function phase:init( scene )
	phase.super.init( self, "phase-1" )
	self.owner = scene
end

-- Fires when the Phase is entered
function phase:enter() 

	-- Input Listener Callbacks
	self.owner.inputHandler = {
		AButtonDown = function()
			self.owner:checkABtnPress()
		end,
		BButtonDown = function()
			-- TODO: REMOVE ME
			Noble.transition( TitleScene )
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

		self.owner.cursor.velocity = { x = 0, y = 0 }

		if Noble.Settings.get( "debug_mode" ) then
			self.owner.dbgMenu:activate()
			self.owner.dbgMenu:select( 1 )
		else
			-- TODO: Load a random game type
			Noble.transition( Petting_CrankGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end

	end)

	self.owner.feedBtn:setPressedCallback( function ()
		self.owner.cursor.velocity = { x = 0, y = 0 }

		if Noble.Settings.get( "debug_mode" ) then
			self.owner.dbgMenu:activate()
			self.owner.dbgMenu:select( 1 )
		else
			-- TODO: Load a random game type
			Noble.transition( Feeding_ShakeGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	end)

	self.owner.playBtn:setPressedCallback( function ()
	end)

	self.owner.groomBtn:setPressedCallback( function ()
	end)

	self.owner.sleepBtn:setPressedCallback( function ()
	end)

end

-- Fires when the Phase is exited
function phase:exit() end

-- Fires when the State Machine updates
function phase:tick()

	self:phaseChangeHandler()

end

function phase:phaseChangeHandler() 

	if GameController.getFlag( 'game.phase' ) == 2 then
		self.stateMachine:changeState( self.owner.phases.phase2 )
	end

	if GameController.getFlag( 'game.playTime' ) >= GameController.PHASE_2_TIME_TRIGGER then
		GameController.setFlag( 'game.phase', 2 )
		return
	end

	local change = true
	for k, v in pairs( GameController.PHASE_2_GAME_TRIGGERS ) do

		local flagVal = GameController.getFlag( 'game.gamesPlayed.' .. k )
		if flagVal < v then
			change = false
		end

	end

	if change then
		GameController.setFlag( 'game.phase', 2 )
	end

end