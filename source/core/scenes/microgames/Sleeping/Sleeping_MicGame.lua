Sleeping_MicGame = {}
class( "Sleeping_MicGame" ).extends( Microgame )
local scene = Sleeping_MicGame

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.background = nil
	self.bgMusic = nil
	self.micSource = "device"
	self.micLevel = 0
	self.buffer = nil

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

	self.happinessVal = 0
	
	scene.inputHandler = {
		AButtonDown = function() 

			self.buffer = playdate.sound.sample.new( 5, playdate.sound.kFormat16bitMono )
			Sound.micinput.recordToSample( self.buffer, function ()
				self.buffer:play()
			end)

		end,
		BButtonDown = function()
			Noble.transition( PlayScene )
		end
	}

end

function scene:enter()

	scene.super.enter( self )

end

function scene:start()

	scene.super.start( self )
	Sound.micinput.startListening()
	self:checkMicInput()

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	if self.timer.value >= self.gameTime or self.win then
		
		if self.win then
			GameController.setFlag( 'dialogue.showBark', NobleSprite( 'assets/images/UI/heart' ) )
			GameController.pet.stats.tired.value = math.clamp( GameController.pet.stats.tired.value + math.random(3), 1, 5 )
		end

		Noble.transition( PlayScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		return

	end

	scene.super.update( self )

	if self.startTimer then
		-- self.timer:start()
		self.startTimer = false
	else
		return
	end

	self:checkMicInput()
	self:renderDebugInfo()

end

function scene:checkMicInput() 
	
	self.micSource = Sound.micinput.getSource()
	self.micLevel = Sound.micinput.getLevel()

end

function scene:renderDebugInfo()

	if Noble.Settings.get( "debug_mode" ) ~= true then
		return
	end

	local source = "Input Source: " .. self.micSource
	local sourceW, sourceH = Graphics.getTextSize(source)
	
	local level = "Input Level: " .. math.floor( self.micLevel * 100 ) .. "%"
	local levelW, levelH = Graphics.getTextSize(level)

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