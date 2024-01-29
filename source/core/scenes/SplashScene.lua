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
			self:transitionToTitle()
		end
	}

end

function scene:enter()
	scene.super.enter(self)
end

function scene:start()
	scene.super.start(self)
	Timer.new( ONE_SECOND, function()
		self:transitionToTitle()
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

function scene:transitionToTitle()
	Noble.transition( TitleScene, 1, Noble.TransitionType.DIP_TO_WHITE )
end