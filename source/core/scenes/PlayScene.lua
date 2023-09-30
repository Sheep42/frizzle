PlayScene = {}
class("PlayScene").extends(NobleScene)

local scene = PlayScene
local background
local sequence
local petSprite = nil
local cursor = nil
local dialogue = nil
startDialogue = false

scene.baseColor = Graphics.kColorBlack
scene.inputHandler = {
	AButtonDown = function()
		
		startDialogue = true

		if dialogue.finished == true then
			startDialogue = false
			dialogue:reset()
		end

	end,
	downButtonHold = function ()
		
	end,
	upButtonHold = function ()
		
	end,
	leftButtonHold = function ()
		
	end,
	rightButtonHold = function ()
		
	end,
}

local deltaTime = 0

function scene:init()

	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background" )

	cursor = Cursor:new( 50, 100 )

	local petImage = Graphics.image.new( "assets/images/player" )
	petSprite = NobleSprite.new( petImage )
	petSprite:moveTo( 200, 120 )
	petSprite:add()

	dialogue = Dialogue:new( "Hello, Game World" )

end

function scene:enter()

	scene.super.enter(self)

	sequence = Sequence.new():from(0):to( 100, 1.5, Ease.outBounce )
	sequence:start();

end

function scene:start()
	
	scene.super.start(self)

end

function scene:drawBackground()

	scene.super.drawBackground(self)
	background:draw( 0, 0 )

end

function scene:update()

	scene.super.update(self)

	if startDialogue then
		showDialogue()	
	end

end

function scene:exit()

	scene.super.exit(self)

	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish(self)
end

function showDialogue()
	dialogue:draw()
	dialogue:play()
end