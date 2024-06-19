CreditScene = {}
class("CreditScene").extends(NobleScene)
local scene = CreditScene

scene.baseColor = Graphics.kColorBlack
scene.TEXT_POS_LIMIT = 510

local background
local menu
local sequence
local bgMusic = nil

function scene:init()
	scene.super.init(self)

	self.finished = false
	self.textPos = 0
	self.futuraHand = Graphics.font.new( 'assets/fonts/FuturaHandwritten' )
	bgMusic = Sound.fileplayer.new( "assets/sound/credits" )
	bgMusic:setVolume( 0.75 )

	background = Graphics.image.new( Utilities.screenSize().width, Utilities.screenSize().height, Graphics.kColorBlack )

	local crankTick = 0

	scene.inputHandler = {
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change

			if change >= 10 then
				change = 10
			elseif change <= -10 then
				change = -10
			end

			if self.textPos < scene.TEXT_POS_LIMIT and self.textPos >= 10 then
				self.textPos += change
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
	Noble.Text.draw( "Programming, Art, & Music By: Dan Shedd", textX, textY + 30 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Story By: Dan Shedd & Ridley4Eve", textX, textY + 50 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Frizzle Font: Futura Handwritten\nBy Billy Snyder", textX, textY + 100 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Menu Font: PixelSplitter\nBy Manfred Klein", textX, textY + 150 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Built with Noble Engine By Noble Robot", textX, textY + 225 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Playtesters:", textX, textY + 275 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Chris Hickman, Ben Ehrlich (Benergize),", textX, textY + 300 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Ridley4Eve, theswellpenguin, Brian Bahia", textX, textY + 330 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "Ryan Szrama (roguewombat), Jon Shedd", textX, textY + 360 , Noble.Text.ALIGN_CENTER, nil, self.futuraHand )
	Noble.Text.draw( "The End", textX, textY + 500, Noble.Text.ALIGN_CENTER, nil, self.futuraHand )

	if self.textPos >= scene.TEXT_POS_LIMIT then

		if bgMusic:getVolume() > 0 then
			bgMusic:setVolume( bgMusic:getVolume() - 0.009 )
		end

		if not self.finished then
			self.finished = true
			Timer.new( ONE_SECOND * 3, function()
				Noble.transition( TitleScene, 1.5, Noble.TransitionType.DIP_TO_BLACK )
			end)
		end
	end

end

function scene:exit()
	scene.super.exit(self)
	bgMusic:stop()
end

function scene:finish()
	scene.super.finish(self)
end