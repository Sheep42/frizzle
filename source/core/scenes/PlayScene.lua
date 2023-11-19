PlayScene = {}
class("PlayScene").extends(NobleScene)

local _CURSOR_SPEED_MULTIPLIER = 1

local scene = PlayScene
local background
local sequence
local pet = nil
local dialogue = nil
local bark = nil
local cursor = nil
local petBtn = nil
local feedBtn = nil
local playBtn = nil
local bgMusic = nil
local uiButtons = {}
local statBars = {}

scene.baseColor = Graphics.kColorBlack
scene.inputHandler = {
	AButtonDown = function()
		checkABtnPress()
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

	bgMusic = Sound.fileplayer.new( "assets/sound/tamagotchi-music.mp3" )

	-- Create dialogue and bark objects
	dialogue = Dialogue( GameController.advanceDialogueLine() )
	dialogue:enableSound()
	dialogue.buttonPressedCallback = function ()
		
		if dialogue.finished == false then
			dialogue.finished = true
			return	
		end

		if dialogue:getState() == DialogueState.Hide then
			return
		end

		local line = GameController.advanceDialogueLine()
		if line ~= nil then
			dialogue:setText( line )
		else
			dialogue:hide()
		end

	end

	bark = Dialogue( 
		NobleSprite( "assets/images/UI/heart" ), 
		Utilities.screenSize().width / 2 - 26, -- center of screen minus half width of outer box
		Utilities.screenBounds().top + 20, -- 20 px down from top of allowable screen area
		true,
		50,
		50,
		2,
		2 
	)

	-- Create Pet
	pet = VirtualPet( "assets/images/pet" )

	-- Create cursor
	cursor = Cursor()
	
	-- Create UI Buttons
	petBtn = Button( "assets/images/UI/button-pet" )
	feedBtn = Button( "assets/images/UI/button-feed" )
	playBtn = Button( "assets/images/UI/button-play" )
	groomBtn = Button( "assets/images/UI/button-groom" )
	sleepBtn = Button( "assets/images/UI/button-sleep" )

	-- TODO: Implement Button click handlers 
	petBtn:setPressedCallback( function()

		-- if dialogue:getState() == DialogueState.Hide then
		-- 	dialogue:show()
		-- elseif dialogue:getState() == DialogueState.Show then
		-- 	dialogue:hide()
		-- end

		if bark:getState() == DialogueState.Hide then
			bark:show()
		end

		-- petBtn:deactivate()
		GameController.pet.stats.friendship += 1

	end)

	feedBtn:setPressedCallback( function ()
		GameController.pet.stats.hunger += 1
	end)

	playBtn:setPressedCallback( function ()
		GameController.pet.stats.boredom += 1
	end)

	groomBtn:setPressedCallback( function ()
		GameController.pet.stats.groom += 1
	end)

	sleepBtn:setPressedCallback( function ()
		GameController.pet.stats.tired += 1
	end)

	-- Add UI Buttons to table
	uiButtons[1] = petBtn
	uiButtons[2] = feedBtn
	uiButtons[3] = playBtn
	uiButtons[4] = groomBtn
	uiButtons[5] = sleepBtn

	-- TODO: Create new icons and update
	-- Add StatBars to table

	statBars = {
		hunger =  StatBar( "assets/images/UI/heart", "hunger" ),
		boredom = StatBar( "assets/images/UI/heart", "boredom" ),
		friendship = StatBar( "assets/images/UI/heart", "friendship" ),
		tired = StatBar( "assets/images/UI/heart", "tired" ),
		groom = StatBar( "assets/images/UI/heart", "groom" ),
	}

end

function scene:enter()

	scene.super.enter(self)

	sequence = Sequence.new():from(0):to( 100, 1.5, Ease.outBounce )
	sequence:start();

end

function scene:start()
	
	scene.super.start(self)

	-- Add Pet to Scene
	pet:add( Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 )

	-- Add Buttons to the Scene
	setupButtons()

	-- TOOD: These should not be hardcoded like this
	statBars.friendship:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top )
	statBars.hunger:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 10 )
	statBars.boredom:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 20 )
	statBars.groom:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 30 )
	statBars.tired:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 40 )

	-- Add Cursor to the Scene
	cursor:add( Utilities.screenSize().width * 0.25, Utilities.screenSize().height * 0.25 )

	bgMusic:play( 0 ) -- repeatCount 0 = loop forever

	dialogue:show()

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

function checkABtnPress()

	for i = 1, #uiButtons do
		uiButtons[i]:press()
	end

	dialogue:buttonPressedCallback()

end

function scene:drawBackground()

	scene.super.drawBackground(self)
	-- background:draw( 0, 0 )

	-- Draw Bark Canvas
	bark:drawCanvas()	

end

function scene:update()

	scene.super.update( self )

	-- Draw dialogue canvas over sprites
	dialogue:drawCanvas()

	dialogue:update()
	bark:update()

	for i, statBar in pairs( statBars ) do
		statBar:update()
	end

end

function scene:exit()

	scene.super.exit( self )

	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish( self )
end