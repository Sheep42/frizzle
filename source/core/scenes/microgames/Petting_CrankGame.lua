Petting_CrankGame = {}
class( "Petting_CrankGame" ).extends( NobleScene )
local scene = Petting_CrankGame

scene.baseColor = Graphics.kColorBlack

local HandStates = {
	Move = 'move',
	Rotate = 'rotate',
}

local background
local bgMusic = nil
local hand = nil
local face = nil
local crankTick = 0
local crankElapsed = 0
local cranked = 0
local crankDelta = 0
local crankAccelleration = 0
local handState = HandStates.Move

function scene:init()

	scene.super.init(self)

	scene.inputHandler = {
		cranked = function(change, acceleratedChange)
			crankTick += change
			cranked += change
			crankDelta = change
			crankAccelleration = acceleratedChange
		end,
		BButtonDown = function()
			Noble.transition( PlayScene )
		end
	}

	local faceAnim = Noble.Animation.new( 'assets/images/pet-face' )

	faceAnim:addState( 'wait', 1, 1, nil, nil, nil, 0 )
	faceAnim:addState( 'beingPet', 1, 2, nil, nil, nil, 15 )
	faceAnim:setState( 'wait' )

	face = NobleSprite( faceAnim )
	face:setSize( 150, 90 )

	hand = NobleSprite( 'assets/images/hand-petting' )

end

function scene:enter()
	
	scene.super.enter(self)

end

function scene:start()
	
	scene.super.start(self)
	Noble.Input.setCrankIndicatorStatus(true)

	local faceWidth, faceHeight = face:getSize()

	face:add( Utilities.screenSize().width / 2, Utilities.screenSize().height - ( faceHeight / 2 ) )
	hand:add( Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 )

end

function scene:drawBackground()
	scene.super.drawBackground( self )
end

function scene:update()

	scene.super.update( self )

	if cranked > 0 then
		cranked = 0
		moveHand()

		if handState == HandStates.Rotate then
			face.animation:setState( 'beingPet' )
		end
	else
		face.animation:setState( 'wait' )
	end
	
end

function scene:exit()
	scene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
end

function scene:finish()
	scene.super.finish(self)
end


function moveHand()
	
	local x, y = hand:getPosition()
	local faceX, faceY = face:getPosition()
	local headPos = faceY - 30
	local handSpeed = math.clamp( crankAccelleration, 0.001, 10 )

	if handState == HandStates.Move then
		
		hand:moveBy( 0, handSpeed )
		if y >= headPos then
			hand:moveTo( x, headPos )
			handState = HandStates.Rotate
		end
	
	elseif handState == HandStates.Rotate then

		local radius = 10
		local maxAngle = 2 * math.pi
		local angle = (crankTick % 360) * (math.pi / 180)
		angle = math.min( angle, maxAngle )
		angle = math.max( angle, 0 )

		local xOffset = radius * math.cos( angle )
		local yOffset = radius * math.sin( angle )

		hand:moveTo( faceX + xOffset, headPos + yOffset )

	end


end