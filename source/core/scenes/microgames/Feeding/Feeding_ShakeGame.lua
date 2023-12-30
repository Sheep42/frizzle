Feeding_ShakeGame = {}
class( "Feeding_ShakeGame" ).extends( NobleScene )
local scene = Feeding_ShakeGame

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.background = nil
	self.bgMusic = nil
	self.minMovement = 0.1
	self.accelerometerPos = { x = 0, y = 0, z = 0 }
	self.accelerometerLastPos = { x = 0, y = 0, z = 0 }
	self.happinessVal = 0
	-- self.hand = NobleSprite( 'assets/images/hand-petting' )

end

function scene:enter()

	scene.super.enter( self )
	pd.startAccelerometer()
	self.accelerometerPos.x, self.accelerometerPos.y, self.accelerometerPos.z = pd.readAccelerometer()

	-- self.hand:add( Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 )

end

function scene:start()

	scene.super.start( self )

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	scene.super.update( self )

	self:readAccelerometer()

	renderDebugInfo( self )
	handleShake( self )

end

function scene:exit()

	pd.stopAccelerometer()
	scene.super.exit( self )

end

function scene:finish()

	scene.super.finish( self )

end

function scene:readAccelerometer() 

	self.accelerometerLastPos = {
		x = self.accelerometerPos.x,
		y = self.accelerometerPos.y,
		z = self.accelerometerPos.z,
	}

	self.accelerometerPos.x, self.accelerometerPos.y, self.accelerometerPos.z = pd.readAccelerometer()
	
end

function scene:getAccelerometerPos() 
	return self.accelerometerPos.x, self.accelerometerPos.y, self.accelerometerPos.z
end

function scene:getAccelerometerLastPos() 
	return self.accelerometerLastPos.x, self.accelerometerLastPos.y, self.accelerometerLastPos.z
end

function renderDebugInfo( self )

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

	-- Draw happinessVal
	Noble.Text.draw(self.happinessVal, Utilities.screenSize().width / 2, Utilities.screenBounds().top + 70)

end

function handleShake( self ) 

	local x, y, z = self:getAccelerometerPos()
	local lastX, lastY, lastZ = self:getAccelerometerLastPos()

	local dx, dy, dz = ( x - lastX ), ( y - lastY ), ( z - lastZ )

	if dz >= self.minMovement or dz <= -self.minMovement then
		self.happinessVal += math.abs(dz)
	end

end