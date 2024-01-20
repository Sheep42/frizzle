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

function scene:init()

	scene.super.init(self)

	scene.baseColor = Graphics.kColorBlack

	-- Create cursor
	cursor = Cursor()

	-- Debug Menu
	dbgMenu = Noble.Menu.new( false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4,6,0, Noble.Text.FONT_SMALL )
	dbgMenu:addItem( 
		"Pet: Crank It", 
		function() 
			Noble.transition( Petting_CrankGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)
	dbgMenu:addItem( 
		"Pet: Shake It", 
		function() 
			Noble.transition( Petting_ShakeGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)
	dbgMenu:addItem( 
		"Feed: Shake It", 
		function() 
			Noble.transition( Feeding_ShakeGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)
	dbgMenu:addItem( 
		"Sleep: Say It", 
		function() 
			Noble.transition( Sleeping_MicGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	-- Input Listener Callbacks
	scene.inputHandler = {
		AButtonDown = function()
			checkABtnPress()
		end,
		BButtonDown = function()
			-- TODO: REMOVE ME
			Noble.transition( TitleScene )
		end,
		downButtonUp = function ()

			if cursor ~= nil then
				if cursor.velocity.y < 0 then
					return
				end

				self:setCursorVelocity( { x = cursor.velocity.x, y = 0 } )
			end

		end,
		upButtonUp = function ()

			if cursor ~= nil then
				if cursor.velocity.y > 0 then
					return
				end

				self:setCursorVelocity( { x = cursor.velocity.x, y = 0 } )
			end	

		end,
		leftButtonUp = function ()

			if cursor ~= nil then
				if cursor.velocity.x > 0 then
					return
				end

				self:setCursorVelocity( { x = 0, y = cursor.velocity.y } )
			end	

		end,
		rightButtonUp = function ()

			if cursor ~= nil then
				if cursor.velocity.x < 0 then
					return
				end

				self:setCursorVelocity( { x = 0, y = cursor.velocity.y } )
			end	

		end,
		downButtonDown = function ()
			dbgMenu:selectNext()
			self:setCursorVelocity( { x = cursor.velocity.x, y =_CURSOR_SPEED_MULTIPLIER } )
		end,
		upButtonDown = function ()
			dbgMenu:selectPrevious()
			self:setCursorVelocity( { x = cursor.velocity.x, y = -_CURSOR_SPEED_MULTIPLIER } )
		end,
		leftButtonDown = function ()
			self:setCursorVelocity( { x = -_CURSOR_SPEED_MULTIPLIER, y = cursor.velocity.y } )
		end,
		rightButtonDown = function ()
			self:setCursorVelocity( { x = _CURSOR_SPEED_MULTIPLIER, y = cursor.velocity.y } )
		end,
	}

	background = Graphics.image.new( "assets/images/background" )
	-- bgMusic = Sound.fileplayer.new( "assets/sound/gameplay.mp3" )
	-- bgMusic:setVolume( 0.25 )

	-- Create dialogue and bark objects
	if GameController.getFlag( 'dialogue.playedIntro' ) == false then
		
		GameController.setFlag( 'dialogue.currentScript', 'intro' )
		GameController.setFlag( 'dialogue.currentLine', 1 )

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

		GameController.dialogue = dialogue

	else 
		dialogue = GameController.dialogue
	end

	bark = Dialogue( 
		'',
		Utilities.screenSize().width / 2 - 26, -- center of screen minus half width of outer box
		Utilities.screenBounds().top + 20, -- 20 px down from top of allowable screen area
		true,
		50,
		50,
		2,
		2
	)

	-- Create Pet
	pet = GameController.pet
	
	-- Create UI Buttons
	petBtn = Button( "assets/images/UI/button-pet" )
	feedBtn = Button( "assets/images/UI/button-feed" )
	playBtn = Button( "assets/images/UI/button-play" )
	groomBtn = Button( "assets/images/UI/button-groom" )
	sleepBtn = Button( "assets/images/UI/button-sleep" )

	-- TODO: Implement Button click handlers 
	petBtn:setPressedCallback( function()

		cursor.velocity = { x = 0, y = 0 }

		if Noble.Settings.get( "debug_mode" ) then
			dbgMenu:activate()
		else
			-- TODO: Load a random game type
			Noble.transition( Petting_CrankGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end

	end)

	feedBtn:setPressedCallback( function ()
		cursor.velocity = { x = 0, y = 0 }

		if Noble.Settings.get( "debug_mode" ) then
			dbgMenu:activate()
		else
			-- TODO: Load a random game type
			Noble.transition( Feeding_ShakeGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	end)

	playBtn:setPressedCallback( function ()
	end)

	groomBtn:setPressedCallback( function ()
	end)

	sleepBtn:setPressedCallback( function ()
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

	if GameController.playTimer == nil then
		GameController.playTimer = Timer.new( 1000, GameController.playTimerCallback )
	end
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

	if GameController.getFlag( 'dialogue.showBark' ) ~= nil then

		local emote = GameController.getFlag( 'dialogue.showBark' )
		GameController.setFlag( 'dialogue.showBark', nil )

		bark:setEmote( emote, nil, nil, "assets/sound/win-game.mp3" )	
		
		if bark:getState() == DialogueState.Hide then
			bark:show()
		end

	end

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

	-- bgMusic:play( 0 ) -- repeatCount 0 = loop forever

	if GameController.getFlag( 'dialogue.playedIntro' ) == false then
		
		dialogue:show()

	else 

		if GameController.getFlag( 'statBars.paused' ) then
			GameController.setFlag( 'statBars.paused', false )
		end

	end

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

	if dialogue:getState() == DialogueState.Show then
		
		dialogue:buttonPressedCallback()

	else

		if dbgMenu:isActive() then
			dbgMenu:click()
			return
		end

		for i = 1, #uiButtons do
			uiButtons[i]:press()
		end

	end

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

	-- Draw Debug Menu
	if dbgMenu:isActive() then
		dbgMenu:draw( Utilities.screenBounds().left, Utilities.screenSize().height / 2 )
	end

	for i, statBar in pairs( statBars ) do
		statBar:update()
	end

	self:handlePhaseChange()

end

function scene:exit()

	scene.super.exit( self )

	GameController.setFlag( 'statBars.paused', true )
	pet:remove()
	-- bgMusic:stop()
	
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish( self )
end

function scene:setCursorVelocity( velocity ) 

	if type( velocity ) ~= "table" then
		return
	end

	if dbgMenu:isActive() then
		return
	end

	if cursor ~= nil then
		cursor.velocity = velocity
	end

end

function scene:handlePhaseChange()

	if GameController.getFlag( 'game.phase' ) == 1 then
		GameController.phaseHandlers.phase1()
		return
	elseif GameController.getFlag( 'game.phase' ) == 2 then
		GameController.phaseHandlers.phase2()
		return
	end

end