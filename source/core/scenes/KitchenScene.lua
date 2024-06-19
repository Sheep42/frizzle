KitchenScene = {}
class( "KitchenScene" ).extends( PlayScene )

local scene = KitchenScene

local background

scene._CURSOR_SPEED_MULTIPLIER = 1

function scene:init()

	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background" )

	self.arrowBtn = Button( "assets/images/UI/button-arrow-left", 5 )
	self.arrowBtn:setPressedCallback( function()
		Noble.transition( LivingRoomScene, 1, Noble.TransitionType.DIP_TO_BLACK )
	end )


	-- Create Pet
	pet = GameController.pet


	-- Create room sprites
	self.counter = NobleSprite( 'assets/images/kitchen/counter' )

	self.counter:setCollideRect( 0, 0, self.counter:getSize() )
	self.counter:setGroups( Utilities.collisionGroups.interactables )
	self.counter:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )

	local fridgeAnim = Noble.Animation.new( 'assets/images/kitchen/fridge' )
	fridgeAnim:addState( 'default', 1, 1, nil, nil, nil, 0 )
	fridgeAnim:addState( 'bloody', 2, 2, nil, nil, nil, 0 )

	fridgeAnim:setState( GameController.getFlag( 'game.fridgeState' ) )
	self.fridge = NobleSprite( fridgeAnim )
	self.fridge:setSize( 64, 128 )
	self.fridge:setCollideRect( 0, 0, self.fridge:getSize() )
	self.fridge:setGroups( Utilities.collisionGroups.interactables )
	self.fridge:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )

	local fruitAnim = Noble.Animation.new( 'assets/images/kitchen/fruit' )
	fruitAnim:addState( 'default', 1, 1, nil, nil, nil, 0 )
	fruitAnim:addState( 'rotten', 2, 5, nil, nil, nil, 4 )
	fruitAnim:setState( GameController.getFlag( 'game.fruitState' ) )

	self.fruit = NobleSprite( fruitAnim )
	self.fruit:setSize( 32, 32 )
	self.fruit:setCollideRect( 0, 0, self.fruit:getSize() )
	self.fruit:setGroups( Utilities.collisionGroups.interactables )
	self.fruit:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )


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
	scene.super.enter( self )

	if GameController.getFlag( 'game.phase' ) >= 2 then
		GameController.setFlag( 'game.fridgeState', 'bloody' )
		GameController.setFlag( 'game.fruitState', 'rotten' )
		self.fridge.animation:setState( GameController.getFlag( 'game.fridgeState' ) )
		self.fruit.animation:setState( GameController.getFlag( 'game.fruitState' ) )
	end
end

function scene:start()
	scene.super.start( self )

	local counterW, counterH = self.counter:getSize()
	local fridgeW, fridgeH = self.fridge:getSize()

	self.fridge:add( Utilities.screenBounds().right - fridgeW - 100, Utilities.screenBounds().top + 100 )
	self.counter:add( Utilities.screenBounds().right - (counterW / 2) + 5, Utilities.screenBounds().bottom - ( counterH / 2 ) )

	local counterX, counterY = self.counter:getPosition()
	self.fruit:add( counterX - 40, counterY + 15 )

	self.arrowBtn:add( Utilities.screenBounds().left + 10, Utilities.screenBounds().bottom - 30 )

end

function scene:softRestart()
	scene.super:softRestart( self )
end

function scene:drawBackground()
	scene.super.drawBackground(self)
	background:draw( 0, 0, imageFlippedX )
end

function scene:update()

	scene.super.update( self )
	scene.super:drawBarkCanvas()

end

function scene:exit()

	scene.super.exit( self )

end

function scene:finish()
	scene.super.finish( self )
end

function scene:phase1Interact()

	local collision = self.fridge:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickFridge' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	local collision = self.fruit:overlappingSprites()
	if #collision > 0 then
		GameController.setFlag( 'dialogue.currentScript', 'clickFruit' )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	return false

end

function scene:phase2Interact()

	local collision = self.fridge:overlappingSprites()
	if #collision > 0 then
		local script = 'clickFridge2'
		if GameController.getFlag( 'game.phase2.fridgeClicked' ) then
			script = 'clickFridge2Persist'
		end

		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end

	local collision = self.fruit:overlappingSprites()
	if #collision > 0 then
		local script = 'clickFruit2'

		GameController.setFlag( 'dialogue.currentScript', script )
		GameController.setFlag( 'dialogue.currentLine', 1 )
		GameController.dialogue:setText( GameController.advanceDialogueLine() )
		GameController.dialogue:show()
		return true
	end


	return false

end
