Playing_CopyGame = {}
class( "Playing_CopyGame" ).extends( Microgame )
local scene = Playing_CopyGame

scene.baseColor = Graphics.kColorBlack

function scene:init()

	scene.super.init( self )

	self.background = nil
	self.gameTime = 15999

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

	local randomActions = Utilities.randomElements( self.actions, math.random( 10, 15 ) )
	self.playActions = {}

	for _, action in pairs( randomActions ) do
		table.insert( self.playActions, {
			icon = NobleSprite( action.icon ),
			action = action.action,
		} )
	end

	self.currentAction = '';
	self.currentActionIdx = 0;

	scene.inputHandler = {
		upButtonDown = function()
			if self.currentAction ~= self.actions.up.action then
				self:handleActionFail()
				return
			end

			self:handleActionSuccess()
		end,
		downButtonDown = function()
			if self.currentAction ~= self.actions.down.action then
				self:handleActionFail()
				return
			end

			self:handleActionSuccess()
		end,
		leftButtonDown = function()
			if self.currentAction ~= self.actions.left.action then
				self:handleActionFail()
				return
			end

			self:handleActionSuccess()
		end,
		rightButtonDown = function()
			if self.currentAction ~= self.actions.right.action then
				self:handleActionFail()
				return
			end

			self:handleActionSuccess()
		end,
		AButtonDown = function()
			if self.currentAction ~= self.actions.aBtn.action then
				self:handleActionFail()
				return
			end

			self:handleActionSuccess()
		end,
		BButtonDown = function()
			if self.currentAction ~= self.actions.bBtn.action then
				self:handleActionFail()
				return
			end

			self:handleActionSuccess()
		end,
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

	if self.timer.value >= self.gameTime or self.win then

		if self.win then
			GameController.setFlag( 'dialogue.showBark', true )
			GameController.bark:setEmote( self.stat.icon, nil, nil, 'assets/sound/win-game.wav' )
			GameController.pet.stats.boredom.value = math.clamp( GameController.pet.stats.boredom.value + math.random(3), 1, 5 )
		end

		Noble.transition( LivingRoomScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
		return

	end

	scene.super.update( self )

	if self.startTimer then
		self.timer:start()
		self.startTimer = false
	elseif self.timer.paused then
		return
	end

	self:checkActions()
	self:moveActions()

end

function scene:checkActions()
	for i, action in ipairs( self.playActions ) do
		if #action.icon:overlappingSprites() > 0 then
			self.currentAction = action.action
			self.currentActionIdx = i
			return
		end
	end

	if self.currentAction ~= 'fail' then
		self.currentAction = ''
	end
end

function scene:moveActions()
	for _, action in ipairs( self.playActions ) do
		action.icon:moveBy( -2, 0 )
	end
end

function scene:handleActionSuccess()
	self.playActions[self.currentActionIdx].icon:clearCollideRect()
	self.currentAction = ''

	if self.happinessVal < 1.0 then
		self.happinessVal += 0.1
	end
end

function scene:handleActionFail()
	if self.currentActionIdx + 1 > #self.playActions or self.currentAction == 'fail' then
		return
	end

	local notAllowedSample = Sound.sampleplayer.new( 'assets/sound/not-allowed.wav' )
	notAllowedSample:setVolume( 0.10 )
	notAllowedSample:play()

	self.playActions[self.currentActionIdx + 1].icon:clearCollideRect()
	self.currentAction = 'fail'

	if self.happinessVal > 0 then
		self.happinessVal -= 0.1
	end
end

function scene:exit()

	scene.super.exit( self )

end

function scene:finish()

	scene.super.finish( self )

end