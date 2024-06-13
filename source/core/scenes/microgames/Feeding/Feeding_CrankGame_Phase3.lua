Feeding_CrankGame_Phase3 = {}
class( "Feeding_CrankGame_Phase3" ).extends( Microgame )
local scene = Feeding_CrankGame_Phase3

scene.baseColor = Graphics.kColorBlack

local HandStates = {
	MoveToFood = 'move_to_food',
	MoveToFace = 'move_to_face',
	Stop = 'stop',
}

function scene:init()

	scene.super.init( self )

	self.introText = "CRANK!"
	local textW, textH = Graphics.getTextSize( self.introText, self.introFont )
	self.dialogue = Dialogue(
		self.introText,
		(Utilities.screenSize().width / 2) - ((textW + 50) / 2),
		(Utilities.screenSize().height / 2) - ((textH + 15) / 2),
		true, 
		textW + 50,
		textH + 15,
		4,
		4,
		DialogueType.Instant,
		2000,
		self.introFont
	)

	self.dialogue.onHideCallback = function ()
		self.startTimer = true
	end

	self.background = nil
	self.hand = nil
	self.face = nil
	self.food = nil
	self.crankTick = 0
	self.lastCrankTick = 0
	self.cranked = 0
	self.crankDelta = 0
	self.crankAcceleration = 0
	self.maxFrameDuration = 15
	self.handState = HandStates.MoveToFood
	self.category = MicrogameType.feeding
	self.stat = GameController.pet.stats.hunger

	scene.inputHandler = {
		AButtonDown = scene.super.inputHandler.AButtonDown,
		BButtonDown = scene.super.inputHandler.BButtonDown,
	}

	-- Initialize face, hand, & food sprites
	local faceAnim = Noble.Animation.new( 'assets/images/pet-face' )
	faceAnim:addState( 'wait', 1, 1, nil, nil, nil, 0 )
	faceAnim:addState( 'eating', 1, 2, nil, nil, nil, self.maxFrameDuration )
	faceAnim:setState( 'wait' )

	self.face = NobleSprite( faceAnim )
	self.face:setSize( 150, 90 )

	local handAnim = Noble.Animation.new( 'assets/images/hand-feeding' )
	handAnim:addState( 'open', 1, 1, nil, nil, nil, 0 )
	handAnim:addState( 'closed', 2, 2, nil, nil, nil, 0 )
	handAnim:setState( 'open' )

	self.hand = NobleSprite( handAnim )
	self.hand:setSize( 64, 64 )

	local foodStates = {
		'message',
	}

	local foodAnim = Noble.Animation.new( 'assets/images/food' )
	foodAnim:addState( foodStates[1], 5, 6, nil, nil, nil, 30 )

	foodAnim:setState( foodStates[1] )
	self.food = NobleSprite( foodAnim )
	self.food:setSize( 64, 64 )

end

function scene:enter()
	scene.super.enter( self )
end

function scene:start()

	scene.super.start( self )
	Noble.Input.setCrankIndicatorStatus( true )

	local faceWidth, faceHeight = self.face:getSize()

	self.face:add( Utilities.screenSize().width / 2, Utilities.screenSize().height - ( faceHeight / 2 ) )
	self.food:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 40 )
	self.hand:add( Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 )

end

function scene:drawBackground()
	scene.super.drawBackground( self )
end

function scene:update()

	-- GameController.dialogue:drawCanvas()
	-- GameController.dialogue:update()

	if GameController.getFlag( 'game.phase3.finished.feeding' ) then
		GameController.dialogue:hide()
		Noble.transition( LivingRoomScene, 0.75, Noble.TransitionType.SLIDE_OFF_LEFT )
		return
	end

	scene.super.update( self )

	if pd.isCrankDocked() then
		if self.timer.paused then
			return
		end
	end

	if self.startTimer then
		self.timer:start()
		self.startTimer = false
	elseif self.timer.paused then
		return
	end

	Timer.new( ONE_SECOND * 2, function()

		if GameController.dialogue:getState() == DialogueState.Hide and not self.finished then
			GameController.setFlag( 'dialogue.currentScript', 'phase3FeedingGame' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
			self.finished = true
		end

	end)

end

function scene:exit()

	scene.super.exit(self)
	Noble.Input.setCrankIndicatorStatus( false )

end

function scene:finish()
	scene.super.finish( self )
end