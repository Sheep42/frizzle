Petting_CrankGame = {}
class( "Petting_CrankGame" ).extends( NobleScene )
local scene = Petting_CrankGame

scene.baseColor = Graphics.kColorBlack

local HandStates = {
	Move = 'move',
	Rotate = 'rotate',
}

function scene:init()

	scene.super.init( self )

	local introText = "CRANK!"
	local introFont = Noble.Text.FONT_LARGE
	local textW, textH = Graphics.getTextSize( introText, introFont )

	self.happinessLabel = "Happiness"
	self.happinessFont = Noble.Text.FONT_LARGE
	self.timerLabel = "Time"
	self.timerFont = Noble.Text.FONT_LARGE

	self.background = nil
	self.bgMusic = nil
	self.hand = nil
	self.face = nil
	self.crankTick = 0
	self.lastCrankTick = 0
	self.cranked = 0
	self.crankDelta = 0
	self.crankAcceleration = 0
	self.maxFrameDuration = 15
	self.handState = HandStates.Move
	self.happinessVal = 0
	self.win = false
	self.dialogue = Dialogue( 
		introText,
		(Utilities.screenSize().width / 2) - ((textW + 50) / 2),
		(Utilities.screenSize().height / 2) - ((textH + 15) / 2),
		true, 
		textW + 50, 
		textH + 15,
		4,
		4,
		DialogueType.Instant,
		2000,
		introFont
	)
	self.gameTime = 5999

	self:resetTimer()

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
		BButtonDown = function()
			Noble.transition( PlayScene )
		end
	}

	local faceAnim = Noble.Animation.new( 'assets/images/pet-face' )

	faceAnim:addState( 'wait', 1, 1, nil, nil, nil, 0 )
	faceAnim:addState( 'beingPet', 1, 2, nil, nil, nil, self.maxFrameDuration )
	faceAnim:setState( 'wait' )

	self.face = NobleSprite( faceAnim )
	self.face:setSize( 150, 90 )

	self.hand = NobleSprite( 'assets/images/hand-petting' )

end

function scene:enter()
	
	scene.super.enter( self )
	self:resetTimer()
	self.dialogue:show()

end

function scene:start()
	
	scene.super.start( self )
	Noble.Input.setCrankIndicatorStatus( true )

	local faceWidth, faceHeight = self.face:getSize()

	self.face:add( Utilities.screenSize().width / 2, Utilities.screenSize().height - ( faceHeight / 2 ) )
	self.hand:add( Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 )

end

function scene:drawBackground()
	scene.super.drawBackground( self )
end

function scene:update()

	if self.timer.value >= self.gameTime or self.win then
		
		if self.win then
			GameController.setFlag( 'dialogue.showBark', NobleSprite( 'assets/images/UI/heart' ) )
			GameController.pet.stats.friendship.value = math.clamp( GameController.pet.stats.friendship.value + math.random(3), 1, 5 )
		end

		Noble.transition( PlayScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		return

	end

	scene.super.update( self )

	self.dialogue:drawCanvas()
	self.dialogue:update()

	if self.dialogue:getState() == DialogueState.Show then
		return
	end

	if pd.isCrankDocked() then
		if self.timer.paused then
			return
		end
	end

	if self.timer.paused then
		self.timer:start()
	end

	self:drawHappinessBar()
	self:drawTimer()

	if self.happinessVal >= 1.0 then
		self.win = true
		return	
	end

	self:handleCrank()

end

function scene:exit()

	scene.super.exit(self)
	Noble.Input.setCrankIndicatorStatus( false )

end

function scene:finish()
	scene.super.finish( self )
end

function scene:resetTimer() 
	
	self.timer = Timer.new( self.gameTime, 0, self.gameTime )
	self.timer:pause()
	self.timer:reset()

end

function scene:drawHappinessBar() 

	local labelWidth, labelHeight = Graphics.getTextSize( self.happinessLabel, self.happinessFont )

	Graphics.fillRect( 120, 20, 200*self.happinessVal, 20 )

	Noble.Text.draw( 
		self.happinessLabel,
		Utilities.screenBounds().left,
		20,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.happinessFont
	)

	Noble.Text.draw( 
		math.floor( self.happinessVal * 100 ) .. "%",
		Utilities.screenBounds().left,
		40,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.happinessFont
	)

end

function scene:drawTimer() 

	local labelWidth, labelHeight = Graphics.getTextSize( self.timerLabel, self.timerFont )

	-- Graphics.fillRect( 100, 100, 200*self.timer.value, 20 )

	Noble.Text.draw( 
		self.timerLabel,
		Utilities.screenBounds().left,
		Utilities.screenBounds().bottom - 10,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.timerFont
	)
	
	Noble.Text.draw(
		math.floor( 5.999 - (self.timer.value / 1000)  ),
		Utilities.screenBounds().left + labelWidth + 20,
		Utilities.screenBounds().bottom - 10,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.timerFont
	)

end

function scene:handleCrank() 

	if self.cranked > 0 then

		self.cranked = 0
		self:moveHand()

		if self.handState == HandStates.Rotate then
			self.face.animation:setState( 'beingPet' )
			self.face.animation.frameDuration = self.maxFrameDuration / math.clamp( self.crankAcceleration, 1, self.maxFrameDuration )
		end

		if self.crankTick >= 360 then
			self.crankTick = ( self.crankTick % 360 )

			if self.happinessVal < 1.0 then
				self.happinessVal += 0.1
			end
		end

	else
		self.face.animation:setState( 'wait' )
	end

end

function scene:moveHand()
	
	local x, y = self.hand:getPosition()
	local faceX, faceY = self.face:getPosition()
	local headPos = faceY - 30
	local handSpeed = math.clamp( self.crankAcceleration, 0.001, 10 )

	if self.handState == HandStates.Move then
		
		self.hand:moveBy( 0, handSpeed )
		if y >= headPos then
			self.hand:moveTo( x, headPos )
			self.handState = HandStates.Rotate
		end
	
	elseif self.handState == HandStates.Rotate then

		local radius = 10
		local maxAngle = 2 * math.pi
		local angle = (self.crankTick % 360) * (math.pi / 180)
		angle = math.min( angle, maxAngle )
		angle = math.max( angle, 0 )

		local xOffset = radius * math.cos( angle )
		local yOffset = radius * math.sin( angle )

		self.hand:moveTo( faceX + xOffset, headPos + yOffset )

	end


end