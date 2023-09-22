PlayScene = {}
class("PlayScene").extends(NobleScene)

local scene = PlayScene
local background
local sequence
local playerSprite = nil
local dialogue = nil

scene.baseColor = Graphics.kColorBlack
scene.inputHandler = {
	AButtonDown = function()
	end,
}

function scene:init()

	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background" )

	local playerImg = Graphics.image.new( "assets/images/player" )
	playerSprite = NobleSprite.new( playerImg )
	playerSprite:moveTo( 200, 120 )
	playerSprite:add()

	dialogue = Dialogue:new( "Hello, Game World!" )

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

	dialogue:draw()
	dialogue:play()

end

function scene:update()

	scene.super.update(self)

	playdate.timer.new( 2000, function ()
		dialogue.text = "New thing"
		dialogue:play()
	end)

end

function scene:exit()

	scene.super.exit(self)

	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish(self)
end