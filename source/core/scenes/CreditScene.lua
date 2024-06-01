CreditScene = {}
class("CreditScene").extends(NobleScene)
local scene = CreditScene

scene.baseColor = Graphics.kColorBlack
scene.TEXT_POS_LIMIT = 400

local background
local menu
local sequence
local bgMusic = nil

function scene:init()
	scene.super.init(self)

	self.finished = false
	self.textPos = 0
	self.futuraHand = Graphics.font.new( 'assets/fonts/FuturaHandwritten' )
	bgMusic = Sound.fileplayer.new( "assets/sound/title" )

	background = Graphics.image.new( Utilities.screenSize().width, Utilities.screenSize().height, Graphics.kColorBlack )

	local crankTick = 0

	scene.inputHandler = {
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			if( crankTick > 30 ) and self.textPos < scene.TEXT_POS_LIMIT then
				self.textPos += 2
			end
		end,
		AButtonDown = function()
			self.textPos = scene.TEXT_POS_LIMIT
		end
	}
end

function scene:enter()
	scene.super.enter(self)

	Timer.keyRepeatTimer( function()
		if self.textPos < scene.TEXT_POS_LIMIT then
			self.textPos += 1
		end
	end)
end

function scene:start()
	scene.super.start(self)
	Noble.Input.setCrankIndicatorStatus( false )
	bgMusic:play( 0 )
end

function scene:drawBackground()
	scene.super.drawBackground(self)
	-- background:draw(0, 0)
end

function scene:update()
	scene.super.update(self)

	Graphics.setColor( Graphics.kColorWhite )

	local textX, textY = Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 - self.textPos

	Noble.Text.draw( "Thanks for playing!", textX, textY , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Programming & Art By: Dan Shedd", textX, textY + 30 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Story By: Dan Shedd & Ridley4Eve", textX, textY + 50 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Frizzle Font: Futura Handwritten\nBy Billy Snyder", textX, textY + 100 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Built with Noble Engine By Noble Robot", textX, textY + 160 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Playtesters:", textX, textY + 225 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Chris Hickman, Ben Ehrlich (Benergize)", textX, textY + 250 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "The End", textX, textY + 385, Noble.Text.ALIGN_CENTER, nil, self.futuraHand )

	if self.textPos >= scene.TEXT_POS_LIMIT and not self.finished then
		self.finished = true

		Timer.new( ONE_SECOND * 2, function()
			Noble.transition( TitleScene, 1.5, Noble.TransitionType.DIP_TO_BLACK )
		end)
	end

end

function scene:exit()
	scene.super.exit(self)
	bgMusic:stop()
end

function scene:finish()
	scene.super.finish(self)
end