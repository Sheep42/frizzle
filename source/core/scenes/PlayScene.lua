PlayScene = {}
class("PlayScene").extends(NobleScene)

local scene = PlayScene

local background
local sequence
local pet = nil
local dialogue = nil
local bark = nil
local bgMusic = nil
local uiButtons = {}

scene._CURSOR_SPEED_MULTIPLIER = 1

function scene:init()

	scene.super.init(self)

	scene.baseColor = Graphics.kColorBlack

	-- Create cursor
	self.cursor = Cursor()

	-- Debug Menu
	self.dbgMenu = Noble.Menu.new( false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4,6,0, Noble.Text.FONT_SMALL )
	self:buildDebugMenu()

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

	if GameController.bark == nil then

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

		GameController.bark = bark

	else
		bark = GameController.bark
	end

	-- Create Pet
	pet = GameController.pet

	-- Create UI Buttons
	self.petBtn = Button( "assets/images/UI/button-pet" )
	self.feedBtn = Button( "assets/images/UI/button-feed" )
	-- self.playBtn = Button( "assets/images/UI/button-play" )
	-- self.groomBtn = Button( "assets/images/UI/button-groom" )
	self.sleepBtn = Button( "assets/images/UI/button-sleep" )

	-- Add UI Buttons to table
	uiButtons[1] = self.petBtn
	uiButtons[2] = self.feedBtn
	-- uiButtons[3] = self.playBtn
	-- uiButtons[4] = self.groomBtn
	uiButtons[3] = self.sleepBtn

	-- bug: statBars are recreated every time PlayScene is created which blows away the nag state
	-- TODO: Create new icons and update
	-- Add StatBars to table
	self.statBars = {
		friendship = StatBar( pet.stats.friendship ),
		hunger =  StatBar( pet.stats.hunger ),
		tired = StatBar( pet.stats.tired ),
		-- boredom = StatBar( "assets/images/UI/heart", "boredom" ),
		-- groom = StatBar( "assets/images/UI/heart", "groom" ),
	}

	-- Start the playTimer if it hasn't started
	if GameController.playTimer == nil then
		GameController.playTimer = Timer.new( 1000, GameController.playTimerCallback )
	end

	-- Create the game states
	scene.phases = {
		phase1 = GamePhase_Phase1( self ),
		phase2 = GamePhase_Phase2( self ),
	}
	scene.phaseManager = StateMachine( scene.phases.phase1, scene.phases )

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

	if GameController.getFlag( 'dialogue.showBark' ) then

		GameController.setFlag( 'dialogue.showBark', false )

		if bark:getState() == DialogueState.Hide then
			bark:show()
		end

	end

	-- Add Buttons to the Scene
	self:setupButtons()

	-- TOOD: These should not be hardcoded like this
	self.statBars.friendship:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top )
	self.statBars.hunger:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 10 )
	-- self.statBars.boredom:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 20 )
	-- self.statBars.groom:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 30 )
	self.statBars.tired:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 40 )

	-- Add Cursor to the Scene
	self.cursor:add( Utilities.screenSize().width * 0.25, Utilities.screenSize().height * 0.25 )

	-- bgMusic:play( 0 ) -- repeatCount 0 = loop forever

	if GameController.getFlag( 'dialogue.playedIntro' ) == false then

		dialogue:show()

	else

		if GameController.getFlag( 'statBars.paused' ) then
			GameController.setFlag( 'statBars.paused', false )
		end

	end

end

function scene:softRestart()
	scene.super.start( self )
end

function scene:setupButtons()

	local totalButtons = #uiButtons
	local buttonPanelWidth = ( Button.getDimensions().width + Button.getPadding() ) * totalButtons - Button.getPadding()
	local startX = math.floor( ( Utilities.screenSize().width - buttonPanelWidth ) / 2 + ( Button.getDimensions().width / 2 ) )
	local currentX = startX

	for i = 1, #uiButtons do
		uiButtons[i]:add( currentX, Utilities.screenBounds().bottom - 10 )
		currentX = currentX + Button.getDimensions().width + Button.getPadding()
	end

end

function scene:checkABtnPress()

	if dialogue:getState() == DialogueState.Show then
		dialogue:buttonPressedCallback()
	else

		if self.dbgMenu:isActive() then
			self.dbgMenu:click()
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
	if self.dbgMenu:isActive() then
		self.dbgMenu:draw( Utilities.screenBounds().left, Utilities.screenSize().height / 2 )
	end

	for i, statBar in pairs( self.statBars ) do
		statBar:update()
	end

	self.phaseManager:update()

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

function scene:buildDebugMenu()

	self.dbgMenu:addItem(
		"game_phase",
		function()
			local phase = GameController.getFlag( 'game.phase' )
			local nextPhase = math.ringInt( phase + 1, 1, 4 )
			GameController.setFlag( 'game.phase', nextPhase )
			self.dbgMenu:setItemDisplayName( 'game_phase', "Game phase: " .. nextPhase )
			self.dbgMenu:deactivate()
		end,
		nil,
		"Game phase: " .. GameController.getFlag( 'game.phase' )
	)

	self.dbgMenu:addItem(
		"Pet: Crank It",
		function()
			Noble.transition( Petting_CrankGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Pet: Shake It",
		function()
			Noble.transition( Petting_ShakeGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Pet: Crank It - Phase 2",
		function()
			Noble.transition( Petting_CrankGame_Phase2, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Feed: Crank It",
		function()
			Noble.transition( Feeding_CrankGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Feed: Crank It - Phase 2",
		function()
			Noble.transition( Feeding_CrankGame_Phase2, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)


	self.dbgMenu:addItem(
		"Sleep: Say It",
		function()
			Noble.transition( Sleeping_MicGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Sleep: Say It - Phase 2",
		function()
			Noble.transition( Sleeping_MicGame_Phase2, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

end

function scene:setCursorVelocity( velocity )

	if type( velocity ) ~= "table" then
		return
	end

	if self.dbgMenu:isActive() then
		return
	end

	if self.cursor ~= nil then
		self.cursor.velocity = velocity
	end

end

function scene:stopCursor() 
	self.cursor.velocity = { x = 0, y = 0 }
end

function scene:handleBtnPress( gameType, games )

	self:stopCursor()

	if Noble.Settings.get( "debug_mode" ) then
		self.dbgMenu:activate()
		self.dbgMenu:select( 1 )
	else
		self:loadRandomGameOfType( gameType, games )
	end

end

function scene:loadRandomGameOfType( gameType, games )

	if type( games ) ~= "table" then
		print( "WARNING: Cannot load game. Invalid value provided for games table." )
		return
	end

	local validType = false
	for k, v in pairs( MicrogameType ) do
		if gameType == v then
			validType = true
			break
		end
	end

	if not validType then
		print( "WARNING: Cannot load game. Invalid value provided for game type. got: " .. tostring( gameType ) )
		return
	end

	local gameList = games[gameType]
	local game = gameList[math.random( #gameList )]

	if game == nil then
		print( "WARNING: Cannot load game. Something went wrong." )
		return
	end

	Noble.transition( game, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )

end

function scene:handleStatNag( games )

	local launchingGame = GameController.getFlag( 'game.startLowStatGame' )
	local statBarsPaused = GameController.getFlag( 'statBars.paused' )

	if not statBarsPaused and not launchingGame then

		for key, statBar in pairs( self.statBars ) do

			local alreadyNagged = GameController.getFlag( statBar.NAG_FLAG )
			if statBar.ignored then
				GameController.setFlag( 'dialogue.currentScript', 'ignoredStat' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
				return
			end

			if statBar.nag and not alreadyNagged then
				table.insert( pet.lowStats, statBar.gameType )
				GameController.setFlag( statBar.NAG_FLAG, true )
				GameController.setFlag( 'dialogue.currentScript', 'lowStatNag' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end

			if statBar.playCry and bark:getState() == DialogueState.Hide then
				bark:setEmote( NobleSprite( statBar.icon ), nil, nil, statBar.crySound )
				statBar.playCry = false
				bark:show()
			end

		end

	end

	if launchingGame then
		local type = pet.lowStats[math.random( #pet.lowStats )]
		GameController.setFlag( 'game.startLowStatGame', false )
		pet.lowStats = {}
		self:loadRandomGameOfType( type, games )
	end

end

function scene.setInputHandler( inputHandler )
	scene.inputHandler = inputHandler
end