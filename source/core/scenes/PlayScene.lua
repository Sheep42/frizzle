PlayScene = {}
class("PlayScene").extends(NobleScene)

local _CURSOR_SPEED_MULTIPLIER = 1

local scene = PlayScene
local background
local sequence
local petSprite = nil
local dialogue = nil
local cursor = nil
local petBtn = nil
local feedBtn = nil
local playBtn = nil
local uiButtons = {}

scene.baseColor = Graphics.kColorBlack
scene.inputHandler = {
	AButtonDown = function()
		checkBtnPress()
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
			cursor.velocity.y = _CURSOR_SPEED_MULTIPLIER
		end
	end,
	upButtonDown = function ()
		if cursor ~= nil then
			cursor.velocity.y = -_CURSOR_SPEED_MULTIPLIER
		end	
	end,
	leftButtonDown = function ()
		if cursor ~= nil then
			cursor.velocity.x = -_CURSOR_SPEED_MULTIPLIER
		end	
	end,
	rightButtonDown = function ()
		if cursor ~= nil then
			cursor.velocity.x = _CURSOR_SPEED_MULTIPLIER
		end	
	end,
}

function scene:init()

	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background" )
	dialogue = Dialogue:new( "Hello, Game World" )
	petSprite = NobleSprite( "assets/images/player" )
	cursor = Cursor()
	
	petBtn = Button( "assets/images/UI/button-pet" )
	feedBtn = Button( "assets/images/UI/button-pet" )
	playBtn = Button( "assets/images/UI/button-pet" )

	-- TODO: Implement Button click handlers 
	petBtn:setPressedCallback( function()

		dialogue:show()

		if dialogue.finished == true then
			dialogue:hide()
			dialogue:reset()
		end

	end)

	uiButtons[1] = petBtn
	uiButtons[2] = feedBtn
	uiButtons[3] = playBtn

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

	-- Add Buttons to the Scene
	setupButtons()

	-- Add Cursor to the Scene
	cursor:add( Utilities.screenSize().width * 0.25, Utilities.screenSize().height * 0.25 )

end

function setupButtons()
	
	local totalButtons = #uiButtons
	local buttonPanelWidth = ( Button.getDimensions().width + Button.getPadding() ) * totalButtons - Button.getPadding()
	local startX = math.floor( ( Utilities.screenSize().width - buttonPanelWidth ) / 2 + ( Button.getDimensions().width / 2 ) )
	local currentX = startX

	for i = 1, #uiButtons do
		uiButtons[i]:add( currentX, Utilities.screenBounds().bottom - 10 )
		currentX = currentX + Button.getDimensions().width + Button.getPadding()
	end

end

function checkBtnPress()
	for i = 1, #uiButtons do
		uiButtons[i]:press()
	end
end

function scene:drawBackground()

	scene.super.drawBackground(self)
	background:draw( 0, 0 )
	dialogue:drawCanvas()

end

function scene:update()

	scene.super.update( self )
	dialogue:update()

end

function scene:exit()

	scene.super.exit( self )

	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish( self )
end