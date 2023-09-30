PlayScene = {}
class("PlayScene").extends(NobleScene)

local CURSOR_SPEED_MULTIPLIER = 1

local scene = PlayScene
local background
local sequence
local petSprite = nil
local dialogue = nil
cursor = nil
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
	downButtonUp = function ()
		if cursor ~= nil then
			if cursor.velocity.y < 0 then
				return
			end

			cursor.velocity.y = 0
		end
	end,
	upButtonUp = function ()
		if cursor ~= nil then
			if cursor.velocity.y > 0 then
				return
			end

			cursor.velocity.y = 0
		end	
	end,
	leftButtonUp = function ()
		if cursor ~= nil then
			if cursor.velocity.x > 0 then
				return
			end

			cursor.velocity.x = 0
		end	
	end,
	rightButtonUp = function ()
		if cursor ~= nil then
			if cursor.velocity.x < 0 then
				return
			end

			cursor.velocity.x = 0
		end	
	end,
	downButtonDown = function ()

		if cursor ~= nil then
			cursor.velocity.y = CURSOR_SPEED_MULTIPLIER
		end

	end,
	upButtonDown = function ()
		if cursor ~= nil then
			cursor.velocity.y = -CURSOR_SPEED_MULTIPLIER
		end	
	end,
	leftButtonDown = function ()
		if cursor ~= nil then
			cursor.velocity.x = -CURSOR_SPEED_MULTIPLIER
		end	
	end,
	rightButtonDown = function ()
		if cursor ~= nil then
			cursor.velocity.x = CURSOR_SPEED_MULTIPLIER
		end	
	end,
}

function scene:init()

	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background" )
	dialogue = Dialogue:new( "Hello, Game World" )
	petSprite = NobleSprite( "assets/images/player" )
	cursor = Cursor()

end

function scene:enter()

	scene.super.enter(self)

	sequence = Sequence.new():from(0):to( 100, 1.5, Ease.outBounce )
	sequence:start();

end

function scene:start()
	
	scene.super.start(self)

	-- Add Pet to Scene
	petSprite:add( Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 )

	-- Add Cursor to the Scene
	cursor:add( Utilities.screenSize().width * 0.25, Utilities.screenSize().height * 0.25 )

end

function scene:drawBackground()

	scene.super.drawBackground(self)
	background:draw( 0, 0 )

end

function scene:update()

	scene.super.update(self)

	if cursor ~= nil then
		cursor:update()
	end

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