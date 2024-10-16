SplashScene = {}
class("SplashScene").extends(NobleScene)
local scene = SplashScene

scene.baseColor = Graphics.kColorBlack

local background

function scene:init()
	scene.super.init(self)

	background = Graphics.image.new( "assets/images/SplashScreen/logo" )

	scene.inputHandler = {
		AButtonDown = function()
			self.timer:reset()
			self.timer:pause()
			self:transitionScreen()
		end
	}

	self.sample = Sound.sampleplayer.new( 'assets/sound/startup' )

end

function scene:enter()
	scene.super.enter(self)
	Timer.new( ONE_SECOND * 0.5, function()
		self.sample:play()
	end)
end

function scene:start()
	scene.super.start(self)

	self.timer = Timer.new( ONE_SECOND, function()
		self:transitionScreen()
	end)
end

function scene:drawBackground()
	scene.super.drawBackground(self)

	background:draw(0, 0)
end

function scene:update()
end

function scene:exit()
	scene.super.exit(self)
end

function scene:finish()
	scene.super.finish(self)
end

function scene:transitionScreen()
	Noble.transition( DisclaimerScene, 1, Noble.TransitionType.DIP_TO_WHITE )
end