Feeding_CrankGame_Phase2 = {}
class( "Feeding_CrankGame_Phase2" ).extends( Microgame )
local scene = Feeding_CrankGame_Phase2

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
		cranked = function( change, acceleratedChange )

			if change < 0 then
				return
			end

			self.cranked += change
			self.crankDelta = change
			self.crankAcceleration = acceleratedChange

			self.lastCrankTick = self.crankTick
			self.crankTick += change

		end,
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
		'foot',
		'steak',
		'message',
	}

	local foodAnim = Noble.Animation.new( 'assets/images/food' )
	foodAnim:addState( foodStates[1], 4, 4, nil, nil, nil, 0 )
	foodAnim:addState( foodStates[2], 5, 5, nil, nil, nil, 0 )
	foodAnim:addState( foodStates[3], 5, 6, nil, nil, nil, 25 )

	foodAnim:setState( foodStates[math.random( 1, 3 )] )
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

	if self.timer.value >= self.gameTime or self.win then

		if self.win then
			GameController.setFlag( 'dialogue.showBark', true )
			GameController.bark:setEmote( NobleSprite( self.stat.icon ), nil, nil, 'assets/sound/win-game.wav' )
			GameController.pet.stats.hunger.value = math.clamp( GameController.pet.stats.hunger.value + math.random(3), 1, 5 )
		end

		Noble.transition( LivingRoomScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
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

	self:handleCrank()

	if self.handState == HandStates.Stop and self.face.animation.currentName ~= 'eating' then
		self.face.animation:setState( 'eating' )
		self.face.animation.frameDuration = self.maxFrameDuration
		Timer.keyRepeatTimerWithDelay( ONE_SECOND * 0.5, ONE_SECOND * 0.5, function() self.happinessVal += 0.25 end )
	end

end

function scene:exit()

	scene.super.exit(self)
	Noble.Input.setCrankIndicatorStatus( false )

end

function scene:finish()
	scene.super.finish( self )
end

function scene:handleCrank()

	if self.handState == HandStates.Stop then
		return
	end

	if self.cranked > 0 then

		self.cranked = 0
		self:moveHand()

	else
		self.face.animation:setState( 'wait' )
	end

end

function scene:moveHand()

	local x, y = self.hand:getPosition()
	local faceX, faceY = self.face:getPosition()
	local foodX, foodY = self.food:getPosition()
	local faceOffsetX, faceOffsetY = 20, 40
	local offsetX, offsetY = 10, 25
	local handSpeed = math.clamp( self.crankAcceleration, 0.001, 10 )

	if self.handState == HandStates.MoveToFood then

		self.hand:moveBy( Utilities.moveTowards( self.hand, self.food, handSpeed, offsetX, offsetY ) )

		local differnce = math.abs( Utilities.distance( x, y, foodX, foodY ) - Utilities.distance( foodX, foodY, foodX + offsetX, foodY + offsetY ) )

		if differnce < 0.1 then
			self.hand.animation:setState( 'closed' )
			self.handState = HandStates.MoveToFace
		end

	elseif self.handState == HandStates.MoveToFace then

		self.hand:moveBy( Utilities.moveTowards( self.hand, self.face, handSpeed, faceOffsetX, faceOffsetY ) )
		self.food:moveTo( x - offsetX, y - offsetY )

		if Utilities.distance( x, y, faceX + faceOffsetX, faceY + faceOffsetY ) < 0.1 then
			self.handState = HandStates.Stop
		end

	elseif self.handState == HandStates.Stop then
		return
	end

end