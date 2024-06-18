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

	self.wanderStart = false
	self.screenshot = nil
	self.arrowBtn = Button( "assets/images/UI/button-arrow-right", 5 )
	self.arrowBtn:setPressedCallback( function()

		if GameController.getFlag( 'game.phase' ) < 3 then
			Noble.transition( KitchenScene, 1, Noble.TransitionType.DIP_TO_BLACK )
		else

			local notAllowedSample = Sound.sampleplayer.new( 'assets/sound/not-allowed.wav' )
			notAllowedSample:setVolume( 0.25 )
			notAllowedSample:play()

			if self.screenshot == nil and not pd.getReduceFlashing() then
				self.screenshot = Graphics.getDisplayImage()
			end

			Timer.new( ONE_SECOND * 0.15, function()
				self.screenshot = nil
				GameController.setFlag( 'dialogue.currentScript', 'frizzleBlockRoom' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end )
		end
	end )

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
	scene.super:softRestart( self )
	pet:setVisible( true )
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

	if self.screenshot ~= nil then
		self.screenshot:drawBlurred( 0, 0, math.random( 5, 20 ), math.random( 3 ), Graphics.image.kDitherTypeBayer4x4 )
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

function scene:phase1Tick()

	if GameController.getFlag( 'dialogue.playedIntro' ) and self.face:isVisible() then
		self.face:remove()
	end

	if GameController.getFlag( 'dialogue.playedIntro' ) and not self.wanderStart then
		self.resetPos = true
		self.wanderStart = true
	end

	if self.wanderY then
		self:petWanderY()
	elseif self.wanderX then
		self:petWanderX()
	elseif self.resetPos then
		self:petResetPos()
	end

end

function scene:phase1Interact()

	local collision = self.window:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickWindow1' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.vase:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickVase' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.table:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickTable' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.tv:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickTv1' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	return false

end

function scene:phase2Interact()

	local collision = self.window:overlappingSprites()
	if #collision > 0 then

		local script = 'clickWindow1'
		if math.random() >= 0.3 and GameController.getFlag( 'game.phase2.playedMicroGame' ) then
			script = 'clickWindow2'
		end

		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.vase:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickVase' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.table:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickTable' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.tv:overlappingSprites()
	if #collision > 0 then

		local script = 'clickTv1'

		if math.random() >= 0.3 and GameController.getFlag( 'game.phase2.playedMicroGame' ) then
			script = 'clickTv2'
		end

		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	return false

end

function scene:phase3Interact()

	local collision = self.window:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickWindow3' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.vase:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickVaseTable3' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.table:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickVaseTable3' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.tv:overlappingSprites()
	if #collision > 0 then

		local script = 'clickTv3' .. tostring( math.random( 2 ) )

		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	return false

end

function scene:phase4Interact()

	local collision = self.window:overlappingSprites()
	local script = 'narratorWonClickWindow'
	if GameController.getFlag( 'game.frizzleWon' ) then
		script = 'frizzleWonClickWindow'
	end

	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.vase:overlappingSprites()
	script = 'narratorWonClickVaseTable'
	if GameController.getFlag( 'game.frizzleWon' ) then
		script = 'frizzleWonClickVaseTable'
	end

	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.table:overlappingSprites()
	script = 'narratorWonClickVaseTable'
	if GameController.getFlag( 'game.frizzleWon' ) then
		script = 'frizzleWonClickVaseTable'
	end

	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	collision = self.tv:overlappingSprites()
	script = 'narratorWonClickTv'
	if GameController.getFlag( 'game.frizzleWon' ) then
		script = 'frizzleWonClickTv'
	end

	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	return false

end