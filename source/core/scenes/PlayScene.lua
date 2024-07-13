PlayScene = {}
class("PlayScene").extends(NobleScene)

local scene = PlayScene

local pet = nil
local dialogue = nil
local bark = nil
local uiButtons = {}

scene._CURSOR_SPEED_MULTIPLIER = 1

function scene:init()

	scene.super.init(self)

	scene.baseColor = Graphics.kColorBlack

	self.resetPos = false
	self.wanderX = false
	self.wanderY = false
	self.petStartX = Utilities.screenSize().width / 2
	self.petStartY = (Utilities.screenSize().height / 2) + 20

	-- Create cursor
	self.cursor = Cursor()

	-- Debug Menu
	self.dbgMenu = Noble.Menu.new( false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4,6,0, Noble.Text.FONT_SMALL )
	self:buildDebugMenu()

	self.bgMusic = Sound.fileplayer.new( "assets/sound/main" )
	self.bgMusic:setVolume( 0.25 )

	-- Create dialogue and bark objects
	if GameController.getFlag( 'dialogue.playedIntro' ) == false then

		GameController.setFlag( 'dialogue.currentScript', 'intro' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		dialogue = Dialogue( GameController.advanceDialogueLine() )

	else
		dialogue = Dialogue()
	end

	if GameController.dialogue ~= nil then
		dialogue = GameController.dialogue
	else
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
	self.playBtn = Button( "assets/images/UI/button-play" )
	self.sleepBtn = Button( "assets/images/UI/button-sleep" )
	-- self.groomBtn = Button( "assets/images/UI/button-groom" )

	-- Add UI Buttons to table
	uiButtons[1] = self.petBtn
	uiButtons[2] = self.feedBtn
	uiButtons[3] = self.playBtn
	uiButtons[4] = self.sleepBtn
	-- uiButtons[4] = self.groomBtn

	-- bug: statBars are recreated every time PlayScene is created which blows away the nag state
	-- Add StatBars to table
	self.statBars = {
		friendship = StatBar( pet.stats.friendship ),
		hunger =  StatBar( pet.stats.hunger ),
		boredom = StatBar( pet.stats.boredom ),
		tired = StatBar( pet.stats.tired ),
		-- groom = StatBar( "assets/images/UI/heart", "groom" ),
	}

	local sparkleAnim = Noble.Animation.new( 'assets/images/sparkle' )
	sparkleAnim:addState( 'default', 1, 5, nil, nil, nil, 15 )
	sparkleAnim:setState( 'default' )

	self.sparkle = NobleSprite( sparkleAnim )
	self.sparkle:setSize( 64, 64 )

	-- Create face animation
	local faceAnim = Noble.Animation.new( 'assets/images/pet-face' )
	faceAnim:addState( 'default', 1, 2, nil, nil, nil, 20 )
	faceAnim:setState( 'default' )

	self.face = NobleSprite( faceAnim )
	self.face:setSize( 150, 90 )
	self.face:setZIndex( 100 )

	-- Start the playTimer if it hasn't started
	if GameController.playTimer == nil then
		GameController.playTimer = Timer.new( 1000, GameController.playTimerCallback )
	end

	self.phaseManager = nil

end

function scene:enter()

	scene.super.enter(self)

end

function scene:start()

	scene.super.start(self)

	-- Add Pet to Scene
	if not GameController.getFlag( 'dialogue.playedIntro' ) then
		self.face:add( Utilities.screenSize().width / 2, Utilities.screenBounds().top + 40 )
	end

	pet:add( Utilities.screenSize().width / 2, (Utilities.screenSize().height / 2) + 20 )
	pet:setZIndex( 2 )
	pet:setVisible( false )

	if not GameController.getFlag( 'game.phase4.playedIntro' ) and GameController.getFlag( 'game.phase3.resetTriggered' ) then
		GameController.pet:setVisible( false )
		self.sparkle:add( Utilities.screenSize().width / 2, Utilities.screenBounds().top + 40 )
	end

	if GameController.getFlag( 'dialogue.showBark' ) then

		GameController.setFlag( 'dialogue.showBark', false )

		if bark:getState() == DialogueState.Hide then
			bark:show()
		end

	end

	-- Add Buttons to the Scene
	self:setupButtons()

	-- Add Stat Bars
	self:setupStatBars()

	-- Add Cursor to the Scene
	self.cursor:add( Utilities.screenSize().width / 2, Utilities.screenBounds().bottom )

	self.bgMusic:play( 0 ) -- repeatCount 0 = loop forever

	if GameController.getFlag( 'dialogue.playedIntro' ) == false then

		dialogue:show()

	else

		if GameController.getFlag( 'statBars.paused' ) then
			GameController.setFlag( 'statBars.paused', false )
		end

		if GameController.getFlag( 'pet.state' ) == GameController.pet.states.paused.id then
			GameController.setFlag( 'pet.state', GameController.pet.states.active.id )
		end

	end

	if not GameController.getFlag( 'pet.shouldTickStats' ) then
		GameController.pet._statTimer = nil
		Timer.new( ONE_SECOND * 1.5, function()
			GameController.setFlag( 'pet.shouldTickStats', true )
		end)
	end
end

function scene:softRestart()
	scene.super.start( self )
end

function scene:setupButtons()

	if GameController.getFlag( 'game.phase4.playedIntro' ) then
		return
	end

	local totalButtons = #uiButtons
	local buttonPanelWidth = ( Button.getDimensions().width + Button.getPadding() ) * totalButtons - Button.getPadding()
	local startX = math.floor( ( Utilities.screenSize().width - buttonPanelWidth ) / 2 + ( Button.getDimensions().width / 2 ) )
	local currentX = startX

	for i = 1, #uiButtons do
		uiButtons[i]:add( currentX, Utilities.screenBounds().bottom - 10 )
		uiButtons[i]:setZIndex( 2 )
		currentX = currentX + Button.getDimensions().width + Button.getPadding()
	end

end

function scene:setupStatBars()

	if GameController.getFlag( 'game.phase4.playedIntro' ) then
		return
	end

	local padding = 0
	local statBarTypes = {
		'friendship',
		'hunger',
		'boredom',
		'tired',
	}

	for i = 1, #statBarTypes do
		if not GameController.getFlag( self.statBars[statBarTypes[i]].FLAG_PREFIX .. '.disabled' ) then
			self.statBars[statBarTypes[i]]:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + padding )
			padding += 15
		end
	end
	-- self.statBars.friendship:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top )
	-- self.statBars.hunger:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 15 )
	-- self.statBars.boredom:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 30 )
	-- self.statBars.tired:add( Utilities.screenBounds().right - 40, Utilities.screenBounds().top + 45 )
end

function scene:checkABtnPress()

	if GameController.dialogue:getState() == DialogueState.Show and GameController.getFlag( 'dialogue.buttonPressEnabled' ) then
		GameController.dialogue:buttonPressedCallback()
		return
	end

	if self.dbgMenu:isActive() then
		self.dbgMenu:click()
		return
	end

	for i = 1, #uiButtons do
		uiButtons[i]:press()
	end

	self.arrowBtn:press()

end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:drawBarkCanvas()
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
		self.dbgMenu:draw( Utilities.screenBounds().left, Utilities.screenBounds().top )
	end

	for i, statBar in pairs( self.statBars ) do
		statBar:update()
	end

	if self.phaseManager ~= nil then
		self.phaseManager:update()
	end

	if GameController.getFlag( 'dialogue.showBark' ) then

		GameController.setFlag( 'dialogue.showBark', false )
		if bark:getState() == DialogueState.Hide then
			bark:show()
		end

	end

end

function scene:exit()

	scene.super.exit( self )

	GameController.setFlag( 'statBars.paused', true )
	pet:remove()
	self.bgMusic:stop()

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
		"Pet: Crank It - Phase 2 Glitch",
		function()
			Noble.transition( Petting_CrankGame_Phase2_Glitch, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Pet: Crank It - Phase 3",
		function()
			Noble.transition( Petting_CrankGame_Phase3, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
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
		"Feed: Crank It - Phase 2 Glitch",
		function()
			Noble.transition( Feeding_CrankGame_Phase2_Glitch, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Feed: Crank It - Phase 3",
		function()
			Noble.transition( Feeding_CrankGame_Phase3, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Play: Simon Says",
		function()
			Noble.transition( Playing_CopyGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Play: Simon Says Phase 2",
		function()
			Noble.transition( Playing_CopyGame_Phase2, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Play: Simon Says Phase 2 Glitch",
		function()
			Noble.transition( Playing_CopyGame_Phase2_Glitch, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Play: Simon Says Phase 3",
		function()
			Noble.transition( Playing_CopyGame_Phase3, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
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

	self.dbgMenu:addItem(
		"Sleep: Say It - Phase 2 Glitch",
		function()
			Noble.transition( Sleeping_MicGame_Phase2_Glitch, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Sleep: Say It - Phase 3",
		function()
			Noble.transition( Sleeping_Phase3, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		end
	)

	self.dbgMenu:addItem(
		"Play: Simon Says",
		function()
			Noble.transition( Playing_CopyGame, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
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
				bark:setEmote( statBar.icon, nil, nil, statBar.crySound )
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

function scene:petWanderY()

	local _, currY = pet:getPosition()
	local moveY = 1

	if currY < (Utilities.screenSize().height / 2) + 20 or currY >= (Utilities.screenSize().height / 2) + 50 then
		moveY = 0
		self.wanderY = false

		Timer.new( ONE_SECOND * math.random( 3, 6 ), function()
			self.wanderX = true
			if math.random( 2 ) % 2 == 0 then
				self.randX = -1
			else 
				self.randX = 1
			end
		end )
	end

	if self.petStartY <= (Utilities.screenSize().height / 2) + 20 then
		moveY = 1
	else
		moveY = -1
	end

	pet:moveBy( 0, moveY )

end

function scene:petWanderX()

	local currX, _ = pet:getPosition()
	local moveX = 1 * self.randX

	if currX <= Utilities.screenBounds().left + 40 or currX >= Utilities.screenBounds().right - 30 then
		moveX = 0
		self.wanderX = false

		Timer.new( ONE_SECOND * math.random( 3, 5 ), function()

			if math.random( 2 ) % 2 == 0 then
				self.resetPos = true
			else
				self.wanderX = true
				if currX <= Utilities.screenBounds().left + 40 then
					self.randX = 1
					pet:moveBy( self.randX, 0 )
				else 
					self.randX = -1
					pet:moveBy( self.randX, 0 )
				end
			end

		end)
	end

	pet:moveBy( moveX, 0 )

end

function scene:petResetPos()

	local currX, currY = pet:getPosition()
	local moveX, moveY = 1, -1

	if currX <= Utilities.screenSize().width / 2 then
		moveX = 1
	else
		moveX = -1
	end

	if currX ~= Utilities.screenSize().width / 2 then
		pet:moveBy( moveX, 0 )
	elseif currY > (Utilities.screenSize().height / 2) + 20 then
		pet:moveBy( 0, moveY )
	else
		self.resetPos = false
		self.petStartX = currX
		self.petStartY = currY

		Timer.new( ONE_SECOND * math.random( 5, 10 ), function() self.wanderY = true end)
	end

end


function scene.setInputHandler( inputHandler )
	scene.inputHandler = inputHandler
end

-- OVERRIDE WITH ROOM FUNCTIONALITY --
function scene:phase1Interact()
	return false
end

function scene:phase1Tick()
end

function scene:phase2Interact()
	return false
end

function scene:phase2Tick()
end

function scene:phase3Interact()
	return false
end

function scene:phase3Tick()
end

function scene:phase4Interact()
	return false
end

function scene:phase4Tick()
end