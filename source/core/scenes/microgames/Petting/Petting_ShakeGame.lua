Petting_ShakeGame = {}
class( "Petting_ShakeGame" ).extends( Microgame )
local scene = Petting_ShakeGame

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.background = nil

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
	self.rotation = 0
	self.hand = NobleSprite( 'assets/images/hand-petting' )
	self.motionTimer = nil
	self.category = MicrogameType.petting
	self.stat = GameController.pet.stats.friendship

	-- Initialize face & hand
	local faceAnim = Noble.Animation.new( 'assets/images/pet-face' )
	faceAnim:addState( 'wait', 1, 1, nil, nil, nil, 0 )
	faceAnim:addState( 'beingPet', 1, 2, nil, nil, nil, 15 )
	faceAnim:setState( 'wait' )

	self.face = NobleSprite( faceAnim )
	self.face:setSize( 150, 90 )

end

function scene:enter()

	scene.super.enter( self )
	pd.startAccelerometer()
	self.accelerometerPos.x, self.accelerometerPos.y, self.accelerometerPos.z = pd.readAccelerometer()

end

function scene:start()

	scene.super.start( self )

	local faceWidth, faceHeight = self.face:getSize()
	self.face:add( Utilities.screenSize().width / 2, Utilities.screenSize().height - ( faceHeight / 2 ) )

	local faceX, faceY = self.face:getPosition()
	self.hand:add( Utilities.screenSize().width / 2, faceY )

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	scene.super.update( self )

	if self.timer.value >= self.gameTime or self.win then

		if self.win then
			GameController.setFlag( 'dialogue.showBark', true )
			GameController.bark:setEmote( self.stat.icon, nil, nil, 'assets/sound/win-game.wav' )
			GameController.pet.stats.friendship.value = math.clamp( GameController.pet.stats.friendship.value + math.random(3), 1, 5 )
		end

		Noble.transition( LivingRoomScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		return

	end

	if self.startTimer then
		self.timer:start()
		self.startTimer = false
	elseif self.timer.paused then
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
		self:moveHand()

		self.face.animation:setState( 'beingPet' )
		self.motionTimer = nil
	else
		-- xxx: Note this does not work great on the simulator, but looks pretty good on the playdate
		self.motionTimer = Timer.new( 500, function()
			self.face.animation:setState( 'wait' )
		end)
	end

end

function scene:moveHand()

	self.rotation += 15
	if self.rotation > 360 then
		self.rotation = self.rotation % 360
	end

	local radius = 10
	local maxAngle = 2 * math.pi
	local angle = (self.rotation % 360) * (math.pi / 180)
	local screenSize = Utilities.screenSize()
	local faceX, faceY = self.face:getPosition()

	angle = math.min( angle, maxAngle )
	angle = math.max( angle, 0 )

	local xOffset = radius * math.cos( angle )
	local yOffset = radius * math.sin( angle )

	self.hand:moveTo( (screenSize.width / 2) + xOffset, faceY + yOffset )

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