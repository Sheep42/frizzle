LivingRoomScene = {}
class( "LivingRoomScene" ).extends( PlayScene )

local scene = LivingRoomScene

local background
local pet = nil

scene._CURSOR_SPEED_MULTIPLIER = 1

function scene:init()

	scene.super.init( self )

	pet = GameController.pet
	background = Graphics.image.new( "assets/images/background" )

	self.arrowBtn = Button( "assets/images/UI/button-arrow-right", 5 )

	-- Create room sprites
	self.window = NobleSprite( 'assets/images/room/window' )
	self.table = NobleSprite( 'assets/images/room/table' )
	self.vase = NobleSprite( 'assets/images/room/vase' )

	self.window:setCollideRect( 0, 0, self.window:getSize() )
	self.window:setGroups( Utilities.collisionGroups.interactables )
	self.window:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )

	self.table:setCollideRect( 0, 0, self.table:getSize() )
	self.table:setGroups( Utilities.collisionGroups.interactables )
	self.table:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )

	self.vase:setCollideRect( 0, 0, self.vase:getSize() )
	self.vase:setGroups( Utilities.collisionGroups.interactables )
	self.vase:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )

	local tvAnim = Noble.Animation.new( 'assets/images/room/tv' )
	tvAnim:addState( 'default', 1, 1, nil, nil, nil, 0 )
	tvAnim:addState( 'static', 2, 4, nil, nil, nil, 6 )
	tvAnim:addState( 'glitch', 4, 5, nil, nil, nil, 4 )
	tvAnim:addState( 'frizzle', 5, 5, nil, nil, nil, 0 )
	tvAnim:setState( GameController.getFlag( 'game.tvState' ) )
	self.tv = NobleSprite( tvAnim )
	self.tv:setSize( 77, 57 )
	self.tv:setCollideRect( 0, 0, self.tv:getSize() )
	self.tv:setGroups( Utilities.collisionGroups.interactables )
	self.tv:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )

	-- Create the game states
	scene.phases = {
		phase1 = GamePhase_Phase1( self ),
		phase2 = GamePhase_Phase2( self ),
		phase3 = GamePhase_Phase3( self ),
		phase4 = GamePhase_Phase4( self ),
	}

	local startScene = nil
	if GameController.getFlag( 'game.phase' ) == 1 then
		startScene = scene.phases.phase1
	elseif GameController.getFlag( 'game.phase' ) == 2 then
		startScene = scene.phases.phase2
	elseif GameController.getFlag( 'game.phase' ) == 3 then
		startScene = scene.phases.phase3
	elseif GameController.getFlag( 'game.phase' ) == 4 then
		startScene = scene.phases.phase4
	end

	self.phaseManager = StateMachine( startScene, scene.phases )

end

function scene:enter()
	scene.super.enter(self)
end

function scene:start()

	scene.super.start(self)

	self.arrowBtn:add( Utilities.screenBounds().right, Utilities.screenBounds().bottom - 30 )

	-- Add Room objects
	self.window:add( Utilities.screenBounds().left + 120, Utilities.screenBounds().top + 70 )
	self.table:add( Utilities.screenBounds().left + 120, Utilities.screenBounds().bottom - 80 )
	self.vase:add( Utilities.screenBounds().left + 120, Utilities.screenBounds().bottom - 100 )
	self.tv:add( Utilities.screenBounds().right - 60, Utilities.screenBounds().bottom - 100 )

	-- Add Pet to Scene
	pet:setVisible( true )

end

function scene:softRestart()
	scene.super.start( self )
end

function scene:drawBackground()

	scene.super.drawBackground(self)
	background:draw( 0, 0 )
	scene.super:drawBarkCanvas()

end

function scene:update()

	scene.super.update( self )

	if GameController.getFlag( 'game.tvToggle' ) then

		if self.tv.animation.currentName == 'static' then
			self.tv.animation:setState( 'default' )
			GameController.setFlag( 'game.tvState', 'default' )
		else
			self.tv.animation:setState( 'static' )
			GameController.setFlag( 'game.tvState', 'static' )
		end

		GameController.setFlag( 'game.tvToggle', false )

	end

end

function scene:exit()
	scene.super.exit( self )
end

function scene:finish()
	scene.super.finish( self )
end

function scene:glitchTv( callback )

	Timer.new( ONE_SECOND, function()
		self.tv.animation:setState( 'static' )

		Timer.new( ONE_SECOND, function()

			if playdate.getReduceFlashing() then
				self.tv.animation:setState( 'frizzle' )
			else
				self.tv.animation:setState( 'glitch' )
			end

			Timer.new( ONE_SECOND, function()

				self.tv.animation:setState( 'default' )

				if callback ~= nil and type( callback ) == 'function' then
					callback()
				end

			end)

		end)
	end)

end