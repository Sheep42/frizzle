Dialogue = {}
class( "Dialogue" ).extends()

DialogueType = {
	Typewriter = "typewriter",
	Instant = "instant",
}

TextSpeed = {
	Slow = 1,
	Normal = 2,
	Fast = 3
}

DialogueState = {
	Show = 'show',
	Hide = 'hide',
}

-- Member variables
Dialogue.text = nil
Dialogue.emote = nil
Dialogue.x = 0
Dialogue.y = 0
Dialogue.backgroundColor = Graphics.kColorWhite
Dialogue.borderColor = Graphics.kColorBlack
Dialogue.textColor = Graphics.kColorBlack
Dialogue.boxWidth = 0.75 * Utilities.screenSize().width -- 75% of screen
Dialogue.boxHeight = 75
Dialogue.borderWidth = 0
Dialogue.borderHeight = 0
Dialogue.dialogueType = DialogueType.Typewriter
Dialogue.autohide = false
Dialogue.textDuration = 0
Dialogue.showDuration = 1000
Dialogue.finished = false

-- Dispatch Callbacks
Dialogue.onFinishCallback = function ()
end

Dialogue.onShowCallback = function ()
end

Dialogue.onHideCallback = function ()
end

-- Constants
Dialogue._BASE_TIMER_DURATION = 100
Dialogue._BASE_PITCH = 261.63 
Dialogue._BASE_VOLUME = 0.5
Dialogue._SYNTH_LENGTH = 0.15

-- Internals
Dialogue._dialoguePointer = 0
Dialogue._dialogueTimer = nil
Dialogue._showTimer = nil
Dialogue._canvas = nil
Dialogue._textSound = nil
Dialogue._state = DialogueState.Hide

-- Positioning 
Dialogue._innerX = 0
Dialogue._innerY = 0
Dialogue._textX = 0
Dialogue._textY = 0
Dialogue._emoteX = 0
Dialogue._emoteY = 0

-- Creates a new Dialogue
--
-- @param string|NobleSprite say Text or Emote to initialize the Dialogue with
function Dialogue:init( say, x, y, autohide, boxWidth, boxHeight, borderWidth, borderHeight, dialogueType, backgroundColor, borderColor, textColor )

	if say ~= nil then

		if type( say ) == "string" then
			self.text = say
		elseif type( say ) == "table" then
			self.emote = say	
		end

	end

	if autohide ~= nil then
		self.autohide = autohide	
	end

	if dialogueType ~= nil then
		self.dialogueType = dialogueType
	end

	if backgroundColor ~= nil then
		self.backgroundColor = backgroundColor
	end

	if borderColor ~= nil then
		self.borderColor = borderColor
	end

	if textColor ~= nil then
		self.textColor = textColor
	end

	if boxWidth ~= nil then
		self.boxWidth = boxWidth
	end

	if boxHeight ~= nil then
		self.boxHeight = boxHeight
	end

	self.borderWidth = 4
	if borderWidth ~= nil then
		self.borderWidth = borderWidth
	end

	self.borderHeight = 4
	if borderHeight ~= nil then
		self.borderHeight = borderHeight
	end

	self.textDuration = self._BASE_TIMER_DURATION
	self._canvas = Graphics.image.new( Utilities.screenSize().width, Utilities.screenSize().height )

	-- Positioning
	if x ~= nil then
		self.x = x
	else
		self.x = ( Utilities.screenSize().width / 2 ) - ( ( self.boxWidth + self.borderWidth ) / 2 )
	end

	if y ~= nil then
		self.y = y
	else
		self.y = Utilities.screenSize().height - self.boxHeight - 60
	end

	self._innerX = self.x + ( self.borderWidth / 2 )
	self._innerY = self.y + ( self.borderHeight / 2 )

	self._textX, self._textY = self._innerX + 10, self._innerY + 10 -- Inner box position, plus some padding
	self._emoteX, self._emoteY = self.x + ( self.boxWidth / 2 ), self.y + ( self.boxHeight / 2 )

	-- Set up dialogue timer
	self:resetTimers()

	-- Set up dispatch callbacks
	self.onShowCallback = function ()
		self:startTimers()
	end

	self.onHideCallback = function ()
		self:reset()
	end

	return self

end

function Dialogue:update()
	
	if self.autohide and self._showTimer.value >= self.showDuration then
		self:hide()
	end

	-- Yeah, I could use a real state machine here but, honestly, it feels a
	-- little overkill in this particular case. 
	if self._state == DialogueState.Show then
		self:draw()
		self:play()
	elseif self._state == DialogueState.Hide then
		self:clearCanvas()
	end

end

function Dialogue:show()
	self._state = DialogueState.Show
	self.onShowCallback()
end

function Dialogue:hide()
	self._state = DialogueState.Hide
	self.onHideCallback()
end

function Dialogue:drawCanvas()
	self._canvas:draw( 0, 0 )
end

function Dialogue:clearCanvas()

	if self.emote ~= nil then
		self.emote:remove()
	end

	self._canvas:clear( Graphics.kColorClear )

end

function Dialogue:draw()
	
	Graphics.lockFocus( self._canvas )

	-- Draw the outer dialogue box
	Graphics.setColor( self.borderColor )
	Graphics.fillRoundRect( self.x, self.y, self.boxWidth + self.borderWidth, self.boxHeight + self.borderHeight, 5 )
	
	-- Draw the inner dialogue box
	Graphics.setColor( self.backgroundColor )
	Graphics.fillRoundRect( self._innerX, self._innerY, self.boxWidth, self.boxHeight, 5 )

	Graphics.unlockFocus()

end

function Dialogue:play()

	if self.text ~= nil then
		
		if self.finished then
			self:drawText( self.text )
			return
		end

		if self.dialogueType == DialogueType.Instant then
			
			self:drawText( self.text )
			self:finish()
		
		elseif self.dialogueType == DialogueType.Typewriter then
			buildText( self )
		end

	elseif self.emote ~= nil then

		if self.finished then
			return
		end

		self.emote:add( self._emoteX, self._emoteY )
		self:finish()

	end
		
end

function Dialogue:reset()

	self._dialoguePointer = 0
	self:resetTimers()
	self.finished = false
	
end

function Dialogue:resetTimers( textSpeed )
	
	self:resetAutohideTimer()
	self:resetDialogueTimer()

end

function Dialogue:resetAutohideTimer()

	self._showTimer = Timer.new( self.showDuration, 0, self.showDuration )
	self._showTimer:pause()
	self._showTimer:reset()

end

function Dialogue:resetDialogueTimer()

	if self.dialogueType == DialogueType.Instant then
		return
	end

	if textSpeed == nil then
		textSpeed = Noble.Settings.get( "text_speed" )
	end

	if textSpeed < TextSpeed.Fast then
		self.textDuration = self._BASE_TIMER_DURATION / textSpeed
	else
		self.textDuration = 0
	end

	self._dialogueTimer = Timer.new( self.textDuration, 0, self.textDuration )
	self._dialogueTimer:pause()
	self._dialogueTimer:reset()

end

function Dialogue:startTimers()

	self._dialogueTimer:start()
	self._showTimer:start()

end

-- Sets the current text for this Dialogue and cleans up any internals
--
-- @param string text The text to set
--
-- @param int textX Optional x position for the text, relative to innerX
--
-- @param int textY Optional y position for the text, relative to innerY
function Dialogue:setText( text, textX, textY )

	self.text = text
	self.emote = nil

	if textX ~= nil then
		self._textX = self._innerX + textX
	end

	if textY ~= nil then
		self._textY = self._innerY + textY
	end

	self:reset()

end

-- Sets the current emote for this Dialogue and cleans up any internals
--
-- @param NobleSprite emote The emote to set
--
-- @param int textX Optional x position for the emote, relative to innerX
--
-- @param int textY Optional y position for the emote, relative to innerY
function Dialogue:setEmote( emote, emoteX, emoteY )

	self.emote = emote
	self.text = nil
	
	if emoteX ~= nil then
		self._emoteX = self._innerX + emoteX
	end

	if emoteY ~= nil then
		self._emoteY = self._innerY + emoteY
	end

	self:reset()

end

function Dialogue:enableSound()
	
	local textSound = Sound.synth.new( Sound.kWavePOVosim )
	self._textSound = textSound

end

function Dialogue:disableSound()
	self._textSound = nil
end

function Dialogue:getState()
	return self._state
end

function Dialogue:finish()
	
	self.finished = true
	self.onFinishCallback()

end

-- Utility Functions --
function buildText( self )

	local textToShow = self.text:sub( 0, self._dialoguePointer )
	self:drawText( textToShow )

	if self._dialogueTimer.value < self.textDuration then
		return
	end

	if self._textSound ~= nil and self.text:sub( self._dialoguePointer, self._dialoguePointer ) ~= ' ' then
		self._textSound:playNote( self._BASE_PITCH + math.random( -10, 10 ), self._BASE_VOLUME, self._SYNTH_LENGTH )
	end

	if self._dialoguePointer < #self.text then
		self._dialoguePointer += 1
		self:resetDialogueTimer()
		self._dialogueTimer:start()
	else
		self:finish()
	end
	
end

function Dialogue:drawText( text, align )

	if text == nil then
		return
	end

	if align == nil then
		align = Noble.Text.ALIGN_LEFT
	end

	Graphics.lockFocus( self._canvas )
	Noble.Text.draw( text, self._textX, self._textY, align )
	Graphics.unlockFocus()

end