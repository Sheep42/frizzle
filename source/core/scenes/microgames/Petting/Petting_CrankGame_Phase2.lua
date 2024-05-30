Petting_CrankGame_Phase2 = {}
class( "Petting_CrankGame_Phase2" ).extends( Microgame )
local scene = Petting_CrankGame_Phase2

scene.baseColor = Graphics.kColorBlack

local HandStates = {
	Move = 'move',
	Rotate = 'rotate',
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
	self.crankTick = 0
	self.lastCrankTick = 0
	self.cranked = 0
	self.crankDelta = 0
	self.crankAcceleration = 0
	self.maxFrameDuration = 15
	self.handState = HandStates.Move
	self.category = MicrogameType.petting
	self.stat = GameController.pet.stats.friendship
	self.finished = false
	self.playCount = 1

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
		AButtonDown = scene.super.inputHandler.AButtonDown,
		BButtonDown = scene.super.inputHandler.BButtonDown,
	}

	-- Initialize face & hand
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

	scene.super.update( self )

	if self.timer.value >= self.gameTime or self.win then

		Noble.Input.setCrankIndicatorStatus( false )

		if GameController.getFlag( 'game.resetMicrogame' ) then
			self.happinessVal = 0
			self.win = false
			self:resetTimer()
			self.startTimer = true
			self.playCount += 1
			GameController.setFlag( 'game.resetMicrogame', false )
			return
		end

		if self.playCount > 1 then

			if self.win then
				GameController.setFlag( 'dialogue.showBark', true )
				GameController.bark:setEmote( NobleSprite( self.stat.icon ), nil, nil, 'assets/sound/win-game.wav' )
				GameController.pet.stats.friendship.value = math.clamp( GameController.pet.stats.friendship.value + math.random(3), 1, 5 )
			end

			Noble.transition( PlayScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )

			return

		end

		if GameController.dialogue:getState() == DialogueState.Hide and not self.finished then

			Timer.new( ONE_SECOND, function()

				local script = 'phase2PettingGameFinish1'
				if GameController.getFlag( 'game.phase2.playedPettingFirstTime' ) then
					local dialogueIndex = math.random(2)
					script = 'phase2PettingGameFinish' .. tostring( dialogueIndex )
				end

				GameController.setFlag( 'dialogue.currentScript', script )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)

			self.finished = true

			return

		end

		return

	end

	if pd.isCrankDocked() then
		Noble.Input.setCrankIndicatorStatus( true )
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

end

function scene:exit()

	scene.super.exit(self)
	Noble.Input.setCrankIndicatorStatus( false )

end

function scene:finish()
	scene.super.finish( self )
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