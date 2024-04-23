Sleeping_Phase3 = {}
class( "Sleeping_Phase3" ).extends( Microgame )
local scene = Sleeping_Phase3

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
	self.maxFrameDuration = 25

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
	self.finished = false
	self.playScript = false

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

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	if self.timer.value >= self.gameTime or self.win then

		if GameController.getFlag( 'game.phase3.finished.sleeping' ) then
			GameController.dialogue:hide()
			Noble.transition( PlayScene, 0.75, Noble.TransitionType.SLIDE_OFF_DOWN )
			return
		end

		if GameController.dialogue:getState() == DialogueState.Hide and not self.finished then
			GameController.setFlag( 'dialogue.currentScript', 'phase3SleepingGame' )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.advanceDialogueLine() )
			GameController.dialogue:show()
			self.finished = true
		end

		return

	end

	scene.super.update( self )

	if self.startTimer then
		self.timer:start()
		self.startTimer = false
	elseif self.timer.paused then
		return
	end

end

function scene:exit()

	scene.super.exit( self )
	Sound.micinput.stopListening()

end

function scene:finish()

	scene.super.finish( self )

end