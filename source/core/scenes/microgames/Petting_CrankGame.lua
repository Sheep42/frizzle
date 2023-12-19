Petting_CrankGame = {}
class( "Petting_CrankGame" ).extends( NobleScene )
local scene = Petting_CrankGame

scene.baseColor = Graphics.kColorBlack

local HandStates = {
	Move = 'move',
	Rotate = 'rotate',
}

function scene:init()

	scene.super.init(self)

	self.background = nil
	self.bgMusic = nil
	self.hand = nil
	self.face = nil
	self.crankTick = 0
	self.cranked = 0
	self.crankDelta = 0
	self.crankAcceleration = 0
	self.maxFrameDuration = 15
	self.handState = HandStates.Move

	scene.inputHandler = {
		cranked = function(change, acceleratedChange)
			self.crankTick += change
			self.cranked += change
			self.crankDelta = change
			self.crankAcceleration = acceleratedChange
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

end

function scene:drawBackground()
	scene.super.drawBackground( self )
end

function scene:update()

	scene.super.update( self )

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

function scene:exit()
	scene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus( false )
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