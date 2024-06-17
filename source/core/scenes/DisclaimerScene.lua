DisclaimerScene = {}
class("DisclaimerScene").extends(NobleScene)
local scene = DisclaimerScene

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
	self.font = Graphics.font.new( 'assets/fonts/pixelsplitter' )
	self.icon = Graphics.image.new( 'assets/images/UI/microphone' )

	scene.inputHandler = {
		AButtonDown = function()
			self.timer:reset()
			self.timer:pause()
			self:transitionScreen()
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

	self.timer = Timer.new( ONE_SECOND * 3, function()
		self:transitionScreen()
	end)
end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:update()
	scene.super.update(self)

	Graphics.setColor( Graphics.kColorWhite )

	local textX, textY = Utilities.screenSize().width / 2, Utilities.screenSize().height / 2
	local iconWidth, iconHeight = self.icon:getSize()

	self.icon:draw( textX - ( iconWidth / 2 ), textY - ( iconHeight / 2 ) - 40 )

	Noble.Text.draw( "This game uses the microphone", textX, textY , Noble.Text.ALIGN_CENTER, nil, self.font )
	Noble.Text.draw( "Best experienced in a quiet", textX, textY + 30 , Noble.Text.ALIGN_CENTER, nil, self.font )
	Noble.Text.draw( "environment", textX, textY + 50 , Noble.Text.ALIGN_CENTER, nil, self.font )

end

function scene:exit()
	scene.super.exit(self)
end

function scene:finish()
	scene.super.finish(self)
end

function scene:transitionScreen()
	Noble.transition( TitleScene, 1, Noble.TransitionType.DIP_TO_WHITE )
end