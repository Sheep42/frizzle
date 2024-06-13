KitchenScene = {}
class( "KitchenScene" ).extends( PlayScene )

local scene = KitchenScene

local background

scene._CURSOR_SPEED_MULTIPLIER = 1

function scene:init()

	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background" )

	-- Create Pet
	pet = GameController.pet

	-- Create the game states
	scene.phases = {
		phase1 = GamePhase_Phase1( self ),
		phase2 = GamePhase_Phase2( self ),
		phase3 = GamePhase_Phase3( self ),
		phase4 = GamePhase_Phase4( self ),
	}

	local startScene = nil
	if GameController.getFlag( 'game.phase' ) == 1 then
		startScene = scene.phases.phase1
	elseif GameController.getFlag( 'game.phase' ) == 2 then
		startScene = scene.phases.phase2
	elseif GameController.getFlag( 'game.phase' ) == 3 then
		startScene = scene.phases.phase3
	elseif GameController.getFlag( 'game.phase' ) == 4 then
		startScene = scene.phases.phase4
	end

	scene.phaseManager = StateMachine( startScene, scene.phases )

end

function scene:enter()
	scene.super.enter(self)
end

function scene:start()
	scene.super.start( self )
end

function scene:softRestart()
	scene.super.start( self )
end

function scene:drawBackground()
	scene.super.drawBackground(self)
	background:draw( 0, 0, kImageFlippedX )
end

function scene:update()

	scene.super.update( self )

end

function scene:exit()

	scene.super.exit( self )

end

function scene:finish()
	scene.super.finish( self )
end