Petting_CrankGame = {}
class( "Petting_CrankGame" ).extends( NobleScene )
local scene = Petting_CrankGame

scene.baseColor = Graphics.kColorBlack

local background
local bgMusic = nil

function scene:init()

	scene.super.init(self)

	local crankTick = 0

	scene.inputHandler = {
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			print( crankTick )
		end,
		BButtonDown = function()
			Noble.transition( PlayScene )
		end
	}

end

function scene:enter()
	scene.super.enter(self)
end

function scene:start()
	scene.super.start(self)
	Noble.Input.setCrankIndicatorStatus(true)
end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:update()

	scene.super.update(self)
	
end

function scene:exit()
	scene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
end

function scene:finish()
	scene.super.finish(self)
end