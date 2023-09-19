PlayScene = {}
class("PlayScene").extends(NobleScene)

local scene = PlayScene
local background
local sequence
local playerSprite = nil
local states = {}
local stateMachine = nil

scene.baseColor = Graphics.kColorBlack
scene.inputHandler = {
	AButtonDown = function()
		stateMachine:changeStateById( "test_state_2" )
	end,
	BButtonDown = function()
		stateMachine:changeToDefault()
	end
}

function scene:init()

	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background" )

	-- TODO: Remove Me - Testing SateMachine system
	table.insert( states, TestState:new( "test_state_1" ) )
	table.insert( states, TestState2:new( "test_state_2" ) )
	stateMachine = StateMachine:new( states[1], states )

	local playerImg = Graphics.image.new( "assets/images/player" )
	playerSprite = NobleSprite.new( playerImg )
	playerSprite:moveTo( 200, 120 )
	playerSprite:add()

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
	stateMachine:update()

end

function scene:exit()

	scene.super.exit(self)

	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish(self)
end