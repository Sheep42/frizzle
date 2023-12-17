Petting_CrankGame = {}
class( "Petting_CrankGame" ).extends( NobleScene )
local scene = Petting_CrankGame

scene.baseColor = Graphics.kColorBlack

local background
local bgMusic = nil
local face = nil
local crankTick = 0

function scene:init()

	scene.super.init(self)

	scene.inputHandler = {
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			print( crankTick )
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
	face:setSize( 81, 49 )

end

function scene:enter()
	
	scene.super.enter(self)

end

function scene:start()
	
	scene.super.start(self)
	Noble.Input.setCrankIndicatorStatus(true)

	local faceWidth, faceHeight = face:getSize()
	face:add( Utilities.screenSize().width / 2, Utilities.screenSize().height - ( faceHeight / 2 ) )

end

function scene:drawBackground()
	scene.super.drawBackground( self )
end

function scene:update()

	scene.super.update( self )

	if crankTick > 0 then
		face.animation:setState( 'beingPet' )
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