Microgame = {}
class( "Microgame" ).extends( NobleScene )
local scene = Microgame

MicrogameType = {
	petting = "petting",
	feeding = "feeding",
	sleeping = "sleeping",
	grooming = "grooming",
	playing = "playing",
}

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.introText = nil
	self.introFont = Noble.Text.FONT_LARGE

	self.happinessLabel = "Happiness"
	self.happinessFont = Noble.Text.FONT_LARGE
	self.timerLabel = "Time"
	self.timerFont = Noble.Text.FONT_LARGE

	self.playMusic = true
	self.musicIndex = math.random( 3 )

	self.bgMusic = Sound.fileplayer.new( "assets/sound/minigame-" .. tostring( self.musicIndex ) )
	self.bgMusic:setVolume( 0.25 )

	self.background = nil
	self.happinessVal = 0
	self.win = false
	self.dialogue = nil
	self.gameTime = 5999
	self.startTimer = false
	self.category = ""

	self:resetTimer()

	scene.inputHandler = {
		AButtonDown = function()
			if GameController.dialogue:getState() == DialogueState.Show then
				GameController.dialogue:buttonPressedCallback()
			end
		end,
		BButtonDown = function()
			if Noble.Settings.get( 'debug_mode' ) then
				Noble.transition( PlayScene )
			end
		end
	}

end

function scene:enter()

	scene.super.enter( self )
	self:resetTimer()

	if not GameController.getFlag( 'game.phase1.playedMicroGame' ) then

		GameController.dialogue.onHideCallback = function()
			if self.dialogue ~= nil then
				self.dialogue:show()
			end

			GameController.onHideCallback = function() end
		end
	else
		if self.dialogue ~= nil then
			self.dialogue:show()
		end
	end

	local totalGames = GameController.getFlag( 'game.gamesPlayed.' .. self.category ) + 1
	GameController.setFlag( 'game.gamesPlayed.' .. self.category, totalGames )

	-- print( self.className )

end

function scene:start()

	scene.super.start( self )

	if self.playMusic and self.bgMusic ~= nil then
		self.bgMusic:play( 0 )
	end

end

function scene:drawBackground()
	scene.super.drawBackground( self )
end

function scene:update()

	GameController.dialogue:drawCanvas()
	GameController.dialogue:update()

	if not GameController.getFlag( 'game.phase1.playedMicroGame' ) then
		if GameController.dialogue:getState() == DialogueState.Hide then
			GameController.setFlag( 'dialogue.currentScript', 'firstTimeGame' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:resetDefaults()
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
		end

		return
	end

	scene.super.update( self )

	if self.dialogue ~= nil then

		self.dialogue:drawCanvas()
		self.dialogue:update()

		if self.dialogue:getState() == DialogueState.Show then
			return
		end

	end

	self:drawHappinessBar()
	self:drawTimer()

	if self.happinessVal >= 1.0 then
		self.win = true
		return
	end

end

function scene:resetTimer()

	self.timer = Timer.new( self.gameTime, 0, self.gameTime )
	self.timer:pause()
	self.timer:reset()

end

function scene:drawHappinessBar() 

	local labelWidth, labelHeight = Graphics.getTextSize( self.happinessLabel, self.happinessFont )

	Graphics.fillRect( 120, 20, 200*self.happinessVal, 20 )

	Noble.Text.draw( 
		self.happinessLabel,
		Utilities.screenBounds().left,
		20,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.happinessFont
	)

	Noble.Text.draw( 
		math.floor( self.happinessVal * 100 ) .. "%",
		Utilities.screenBounds().left,
		40,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.happinessFont
	)

end

function scene:drawTimer() 

	local labelWidth, labelHeight = Graphics.getTextSize( self.timerLabel, self.timerFont )

	-- Graphics.fillRect( 100, 100, 200*self.timer.value, 20 )

	Noble.Text.draw( 
		self.timerLabel,
		Utilities.screenBounds().left,
		Utilities.screenBounds().bottom - 10,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.timerFont
	)

	Noble.Text.draw(
		math.floor( 5.999 - (self.timer.value / 1000)  ),
		Utilities.screenBounds().left + labelWidth + 20,
		Utilities.screenBounds().bottom - 10,
		Noble.Text.ALIGN_LEFT,
		nil,
		self.timerFont
	)

end

function scene:exit()
	scene.super.exit(self)
	GameController.setFlag( 'pet.shouldTickStats', false )
	self.bgMusic:stop()
end

function scene:finish()
	scene.super.finish( self )
end