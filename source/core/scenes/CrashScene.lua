CrashScene = {}
class("CrashScene").extends(NobleScene)
local scene = CrashScene

scene.baseColor = Graphics.kColorBlack

function scene:init()
	scene.super.init(self)

	GameController.setFlag( 'dialogue.currentScript', 'crashText' )
	GameController.setFlag( 'dialogue.currentLine', 1 )

	self.dialogue = Dialogue(
		GameController.advanceDialogueLine(),
		0, 0,	-- x, y
		false,	-- autohide
		Utilities.screenSize().width - 10, -- boxWidth
		Utilities.screenSize().height - 10, -- boxHeight
		0, 0	-- borderWidth, borderHeight
	)

	self.dialogue:enableSound()
	self.dialogue:setVoice( nil, Dialogue._BASE_PITCH - 200 )
	self.dialogue.textSpeed = TextSpeed.Fast
	self.dialogue:disableIndicator()
	self.dialogue.buttonPressedCallback = function()
		if not self.dialogue.finished then
			return
		end

		local line = GameController.advanceDialogueLine()
		if line ~= nil then
			self.dialogue:setText( line )
		end
	end

	self.finished = false
	self.textPos = 0

	self.inputHandler = {
		AButtonDown = function()
			self.dialogue:buttonPressedCallback()
		end
	}

end

function scene:enter()
	scene.super.enter(self)
end

function scene:start()
	scene.super.start(self)
	Noble.Input.setCrankIndicatorStatus( false )
	self.dialogue:show()
end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:update()
	scene.super.update(self)
	self.dialogue:drawCanvas()
	self.dialogue:update()
end

function scene:exit()
	scene.super.exit(self)
end

function scene:finish()
	scene.super.finish(self)
end
