Petting_ShakeGame = {}
class( "Petting_ShakeGame" ).extends( NobleScene )
local scene = Petting_ShakeGame

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.background = nil
	self.bgMusic = nil
	self.hand = NobleSprite( 'assets/images/hand-petting' )
	self.hand2 = NobleSprite( 'assets/images/hand-petting' )
	self.hand3 = NobleSprite( 'assets/images/hand-petting' )
	self.hand4 = NobleSprite( 'assets/images/hand-petting' )

end

function scene:enter()

	scene.super.enter( self )
	pd.startAccelerometer()

	self.hand:add( Utilities.screenSize().width / 2, Utilities.screenSize().height / 2 )
	self.hand2:add( (Utilities.screenSize().width / 2) + 50, Utilities.screenSize().height / 2 )
	self.hand3:add( (Utilities.screenSize().width / 2) - 50, Utilities.screenSize().height / 2 )
	self.hand4:add( (Utilities.screenSize().width / 2), (Utilities.screenSize().height / 2) - 50)

end

function scene:start()

	scene.super.start( self )

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	scene.super.update( self )
	local x, y, z = pd.readAccelerometer()

	self.hand:moveBy( x, y )
	self.hand2:moveBy( x, z )
	self.hand3:moveBy( y, z )
	self.hand4:moveBy( z, y )


end

function scene:exit()

	pd.stopAccelerometer()
	scene.super.exit( self )

end

function scene:finish()

	scene.super.finish( self )

end
