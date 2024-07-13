Playing_CopyGame_Phase3 = {}
class( "Playing_CopyGame_Phase3" ).extends( Microgame )
local scene = Playing_CopyGame_Phase3

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.background = nil
	self.gameTime = 15999
	self.glitchPet = false
	self.finished = false

	self.introText = "SIMON SAYS!"
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
	self.category = MicrogameType.playing
	self.stat = GameController.pet.stats.boredom
	self.actions = {
		up = {
			icon = 'assets/images/UI/up-btn-lg',
			action = 'up',
		},
		down = {
			icon = 'assets/images/UI/down-btn-lg',
			action = 'down',
		},
		left = {
			icon = 'assets/images/UI/left-btn-lg',
			action = 'left',
		},
		right = {
			icon = 'assets/images/UI/right-btn-lg',
			action = 'right',
		},
		aBtn = {
			icon = 'assets/images/UI/a-btn-lg',
			action = 'aBtn',
		},
		bBtn = {
			icon = 'assets/images/UI/b-btn-lg',
			action = 'bBtn',
		},
	}

	self.actionBox = NobleSprite( 'assets/images/UI/btn-bounds' )

	local randomActions = Utilities.randomElements( self.actions, math.random( 12, 15 ) )
	self.playActions = {}

	for _, action in pairs( randomActions ) do
		table.insert( self.playActions, {
			icon = NobleSprite( action.icon ),
			action = action.action,
		} )
	end

	self.currentAction = '';
	self.currentActionIdx = 0;

	self.animation = Noble.Animation.new( 'assets/images/pet-dance' )
	local animFinish = function()
		Timer.new( ONE_SECOND * 0.25, function() self.pet.animation:setState( 'idle' ) end )
	end

	self.pet = NobleSprite( 'assets/images/pet-bored' )

	scene.inputHandler = {
		AButtonDown = scene.super.inputHandler.AButtonDown,
	}

end

function scene:enter()

	scene.super.enter( self )

end

function scene:start()

	scene.super.start( self )

	local actionBoxW, actionBoxH = self.actionBox:getSize()
	local actionBoxCollideW, actionBoxCollideH = actionBoxW * 0.75, actionBoxH * 0.75
	local actionXPadding, actionYPadding = 20, 15

	self.pet:add( Utilities.screenSize().width / 2, Utilities.screenBounds().top + 80 )
	self.actionBox:setCollideRect( (actionBoxW / 2) - (actionBoxCollideW / 2), (actionBoxH / 2) - (actionBoxCollideH / 2), actionBoxCollideW, actionBoxCollideH )
	self.actionBox:add( Utilities.screenSize().width / 2, Utilities.screenBounds().bottom - 45 )

	for i, action in ipairs( self.playActions ) do
		local iconW, iconH = action.icon:getSize()
		local iconCollideW, iconCollideH = iconW / 2, iconH / 2
		action.icon:setCollideRect( (iconW / 2) - (iconCollideW / 2), (iconH / 2) - (iconCollideH / 2), iconCollideW, iconCollideH )
		action.icon:add( 300 + ((iconW + actionXPadding) * i), Utilities.screenBounds().bottom - iconH - actionYPadding )
	end

end

function scene:drawBackground()

	scene.super.drawBackground( self )

end

function scene:update()

	if GameController.getFlag( 'game.phase3.finished.' .. self.category ) then
		GameController.dialogue:hide()
		Noble.transition( LivingRoomScene, 0.75, Noble.TransitionType.SLIDE_OFF_UP )
		return
	end

	if self.timer.value >= ONE_SECOND * 3 and not self.finished then
		if GameController.dialogue:getState() == DialogueState.Hide then

			Timer.new( ONE_SECOND, function()
				GameController.setFlag( 'dialogue.currentScript', 'phase3PlayingGameFinish' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)

			self.finished = true

			return

		end
	end

	scene.super.update( self )

	if self.startTimer then
		self.timer:start()
		self.startTimer = false
	elseif self.timer.paused then
		return
	end

	self:moveActions()

end

function scene:moveActions()
	for _, action in ipairs( self.playActions ) do
		action.icon:moveBy( -2, 0 )
	end
end

function scene:exit()

	scene.super.exit( self )

end

function scene:finish()

	scene.super.finish( self )

end