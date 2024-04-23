Sleeping_MicGame = {}
class( "Sleeping_MicGame" ).extends( Microgame )
local scene = Sleeping_MicGame

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self._INCREMENT_FREQ = 750
	self._INCREMENT_AMT = 0.25
	self._THRESHOLD_TIME = 0.25
	self._LEVEL_AMPLIFIER = 1000

	self.background = nil
	self.bgMusic = nil
	self.micSource = "device"
	self.micLevel = 0
	self.buffer = nil
	self.happinessTimer = nil
	self.passThreshold = false
	self.maxFrameDuration = 15

	self.introText = "SHHH!"
	local textW, textH = Graphics.getTextSize( self.introText, self.introFont )
	self.dialogue = Dialogue(
		self.introText,
		(Utilities.screenSize().width / 2) - ((textW + 50) / 2),
		(Utilities.screenSize().height / 2) - ((textH + 15) / 2),
		true,
		textW + 50,
		textH + 15,
		4,
		4,
		DialogueType.Instant,
		2000,
		self.introFont
	)

	self.dialogue.onHideCallback = function ()
		self.startTimer = true
	end

	self.noiseThreshold = (10 / self._LEVEL_AMPLIFIER) -- 10% == 0.010
	self.category = MicrogameType.sleeping
	self.stat = GameController.pet.stats.tired

	scene.inputHandler = {
		AButtonDown = scene.super.inputHandler.AButtonDown,
		BButtonDown = scene.super.inputHandler.BButtonDown,
	}

	-- Initialize face & hand
	local faceAnim = Noble.Animation.new( 'assets/images/pet-face-sleep' )
	faceAnim:addState( 'awake', 1, 1, nil, nil, nil, 0 )
	faceAnim:addState( 'tired', 2, 3, nil, nil, nil, self.maxFrameDuration )
	faceAnim:addState( 'sleeping', 4, 5, nil, nil, nil, self.maxFrameDuration )
	faceAnim:setState( 'awake' )

	self.face = NobleSprite( faceAnim )
	self.face:setSize( 150, 90 )

end

function scene:enter()

	scene.super.enter( self )

end

function scene:start()

	scene.super.start( self )

	local faceWidth, faceHeight = self.face:getSize()
	self.face:add( Utilities.screenSize().width / 2, Utilities.screenSize().height - ( faceHeight / 2 ) )

	Sound.micinput.startListening()
	self:checkMicInput()

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	self:handleAnimation()

	if self.timer.value >= self.gameTime or self.win then

		if self.win then
			GameController.setFlag( 'dialogue.showBark', true )
			GameController.bark:setEmote( NobleSprite( self.stat.icon ), nil, nil, 'assets/sound/win-game.wav' )
			GameController.pet.stats.tired.value = math.clamp( GameController.pet.stats.tired.value + math.random(3), 1, 5 )
		end

		Noble.transition( PlayScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		return

	end

	scene.super.update( self )

	if self.startTimer then
		self.timer:start()
		self.startTimer = false
	elseif self.timer.paused then
		return
	end

	-- TODO: Animation for Pet reactions

	if self.happinessTimer == nil then

		-- Delay the initial setting by 1 second, then use a repeat timer to
		-- continue increasing each second
		self.happinessTimer = Timer.new( self._INCREMENT_FREQ, function()
			self.happinessTimer = Timer.keyRepeatTimerWithDelay(self._INCREMENT_FREQ, self._INCREMENT_FREQ, function()

				if self.passThreshold then
					return
				end

				if self.happinessVal + self._INCREMENT_AMT <= 1 then
					self.happinessVal += self._INCREMENT_AMT
				else
					self.happinessVal = 1
				end

			end)
		end)

	end

	self:checkMicInput()
	self:checkNoiseThreshold()
	self:renderDebugInfo()

end

function scene:handleAnimation()

	if self.happinessVal < 0.3 then
		self.face.animation:setState( 'awake' )
	elseif self.happinessVal < 0.7 then
		self.face.animation:setState( 'tired' )
	else
		self.face.animation:setState( 'sleeping' )
	end

end

function scene:checkMicInput()

	self.micSource = Sound.micinput.getSource()
	self.micLevel = Sound.micinput.getLevel()

end

function scene:checkNoiseThreshold()

	if self.micLevel >= self.noiseThreshold then

		if not self.passThreshold then
			self.passThreshold = true
			playdate.resetElapsedTime()
		end

		if playdate.getElapsedTime() >= self._THRESHOLD_TIME then

			if self.happinessVal - self._INCREMENT_AMT >= 0 then
				self.happinessVal -= self._INCREMENT_AMT
			else
				self.happinessVal = 0
			end

			playdate.resetElapsedTime()

		end

	else

		if playdate.getElapsedTime() >= 0.5 then

			self.passThreshold = false
			playdate.resetElapsedTime()

		end

	end

end

function scene:renderDebugInfo()

	if Noble.Settings.get( "debug_mode" ) ~= true then
		return
	end

	local source = "Input Source: " .. self.micSource
	local sourceW, _ = Graphics.getTextSize(source)

	local level = "Input Level: " .. math.floor( self.micLevel * self._LEVEL_AMPLIFIER ) .. "%"
	local levelW, _ = Graphics.getTextSize(level)

	Noble.Text.draw(source, (Utilities.screenSize().width / 2) - (sourceW / 2), Utilities.screenBounds().top + 20)
	Noble.Text.draw(level, (Utilities.screenSize().width / 2) - (levelW / 2), Utilities.screenBounds().top + 50)

end

function scene:exit()

	scene.super.exit( self )
	Sound.micinput.stopListening()

end

function scene:finish()

	scene.super.finish( self )

end