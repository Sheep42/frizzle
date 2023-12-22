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
	local textW, textH = Graphics.getTextSize( introText )

	self.happinessLabel = "Happiness"
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
		(Utilities.screenSize().width / 2) - ((textW + 20) / 2), 
		(Utilities.screenSize().height / 2) - ((textH + 20) / 2),  
		true, 
		textW + 20, 
		textH + 20,
		4,
		4,
		DialogueType.Instant,
		2000
	)
	self.gameTime = 5
	self.timer = Timer.new( self.gameTime, 0, self.gameTime )
	self.timer:pause()
	self.timer:reset()

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
			
			if self.crankTick >= 360 then
				self.crankTick = ( self.crankTick % 360 )

				if self.happinessVal < 1.0 then
					self.happinessVal += 0.1
				end
			end

		end,
		BButtonDown = function()
			Noble.transition( PlayScene )
		end
	}

	local faceAnim = Noble.Animation.new( 'assets/images/pet-face' )

	faceAnim:addState( 'wait', 1, 1, nil, nil, nil, 0 )
	faceAnim:addState( 'beingPet', 1, 2, nil, nil, nil, self.maxFrameDuration )
	faceAnim:setState( 'wait' )

	scene.face = NobleSprite( faceAnim )
	scene.face:setSize( 150, 90 )

	scene.hand = NobleSprite( 'assets/images/hand-petting' )

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

	self.dialogue:show()

end

function scene:drawBackground()
	scene.super.drawBackground( self )
end

function scene:update()

	if self.win then
		Noble.transition( PlayScene, 0.75, Noble.TransitionType.CROSS_DISSOLVE )
		return
	end

	scene.super.update( self )

	self.dialogue:drawCanvas()
	self.dialogue:update()

	drawHappinessBar( self )

	if self.happinessVal >= 1.0 then
		self.win = true
		return	
	end

	if self.cranked > 0 then
		self.cranked = 0
		moveHand( self )

		if self.handState == HandStates.Rotate then
			self.face.animation:setState( 'beingPet' )
			self.face.animation.frameDuration = self.maxFrameDuration / math.clamp( self.crankAcceleration, 1, self.maxFrameDuration )
		end
	else
		self.face.animation:setState( 'wait' )
	end

end

function drawHappinessBar( self ) 

	local labelWidth, labelHeight = Graphics.getTextSize( self.happinessLabel )

	Graphics.fillRect( 100, 20, 200*self.happinessVal, 20 )

	Noble.Text.draw( self.happinessLabel, 100 - labelWidth - 10, 20 )
	Noble.Text.draw( math.floor( self.happinessVal * 100 ) .. "%", 100 - labelWidth - 10, 40 )

end

function scene:exit()
	scene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus( false )
	GameController.setFlag( 'dialogue.showBark', NobleSprite( 'assets/images/UI/heart' ) )
end

function scene:finish()
	scene.super.finish( self )
end


function moveHand( self )
	
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