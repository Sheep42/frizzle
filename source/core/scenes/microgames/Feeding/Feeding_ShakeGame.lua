Feeding_ShakeGame = {}
class( "Feeding_ShakeGame" ).extends( Microgame )
local scene = Feeding_ShakeGame

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.background = nil
	self.bgMusic = nil

	self.introText = "SHAKE!"
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

	self.minMovement = 0.1
	self.accelerometerPos = { x = 0, y = 0, z = 0 }
	self.accelerometerLastPos = { x = 0, y = 0, z = 0 }
	self.happinessVal = 0
	self.motionTimer = nil
	self.category = MicrogameType.feeding

end

function scene:enter()

	scene.super.enter( self )
	pd.startAccelerometer()
	self.accelerometerPos.x, self.accelerometerPos.y, self.accelerometerPos.z = pd.readAccelerometer()

end

function scene:start()

	scene.super.start( self )

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	if self.timer.value >= self.gameTime or self.win then
		
		if self.win then
			GameController.setFlag( 'dialogue.showBark', NobleSprite( 'assets/images/UI/heart' ) )
			GameController.pet.stats.hunger.value = math.clamp( GameController.pet.stats.hunger.value + math.random(3), 1, 5 )
		end

		Noble.transition( PlayScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		return

	end

	scene.super.update( self )

	if self.startTimer then
		self.timer:start()
		self.startTimer = false
	else
		return
	end

	self:readAccelerometer()

	self:renderDebugInfo()
	self:handleShake()

end

function scene:readAccelerometer() 

	if pd.accelerometerIsRunning() == false then
		return
	end

	self.accelerometerLastPos = {
		x = self.accelerometerPos.x,
		y = self.accelerometerPos.y,
		z = self.accelerometerPos.z,
	}

	self.accelerometerPos.x, self.accelerometerPos.y, self.accelerometerPos.z = pd.readAccelerometer()
	
end

function scene:renderDebugInfo()

	if Noble.Settings.get( "debug_mode" ) ~= true then
		return
	end

	-- Draw debug coords
	local x, y, z = self:getAccelerometerPos()
	local lastX, lastY, lastZ = self:getAccelerometerLastPos()
	local dx, dy, dz = ( x - lastX ), ( y - lastY ), ( z - lastZ )

	local pos = string.format("x: %f, y: %f, z: %f", x, y, z)
	local deltas = string.format("dx: %f, dy: %f, dz: %f", dx, dy, dz)

	local posW, posH = Graphics.getTextSize(pos)
	local deltasW, deltasH = Graphics.getTextSize(deltas)

	Noble.Text.draw(pos, (Utilities.screenSize().width / 2) - (posW / 2), Utilities.screenBounds().top + 20)
	Noble.Text.draw(deltas, (Utilities.screenSize().width / 2) - (deltasW / 2), Utilities.screenBounds().top + 40)

end

function scene:handleShake() 

	local x, y, z = self:getAccelerometerPos()
	local lastX, lastY, lastZ = self:getAccelerometerLastPos()

	local dx, dy, dz = ( x - lastX ), ( y - lastY ), ( z - lastZ )

	if dz >= self.minMovement or dz <= -self.minMovement then
		self.happinessVal += 0.01
		self.motionTimer = nil
	else
		self.motionTimer = Timer.new( 500, function() end)
	end

end

function scene:getAccelerometerPos() 
	return self.accelerometerPos.x, self.accelerometerPos.y, self.accelerometerPos.z
end

function scene:getAccelerometerLastPos() 
	return self.accelerometerLastPos.x, self.accelerometerLastPos.y, self.accelerometerLastPos.z
end

function scene:exit()

	pd.stopAccelerometer()
	scene.super.exit( self )

end

function scene:finish()

	scene.super.finish( self )

end