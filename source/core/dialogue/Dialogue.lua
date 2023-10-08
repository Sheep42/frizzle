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
Dialogue.finished = false

-- Constants
Dialogue._BASE_TIMER_DURATION = 100

-- Internals
Dialogue._dialoguePointer = 0
Dialogue._timerDuration = 0
Dialogue._dialogueTimer = nil
Dialogue._showDialogue = false
Dialogue._canvas = nil

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
function Dialogue:new( say, x, y, boxWidth, boxHeight, borderWidth, borderHeight, dialogueType, backgroundColor, borderColor, textColor )

	if say ~= nil then

		if type( say ) == "string" then
			self.text = text
		elseif type( say ) == "table" then
			self.emote = say	
		end
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

	self._timerDuration = self._BASE_TIMER_DURATION
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
		self.y = Utilities.screenSize().height - self.boxHeight - 40
	end

	self._innerX = self.x + ( self.borderWidth / 2 )
	self._innerY = self.y + ( self.borderHeight / 2 )

	self._textX, self._textY = self._innerX + 10, self._innerY + 10 -- Inner box position, plus some padding
	self._emoteX, self._emoteY = self.x + ( self.boxWidth / 2 ), self.y + ( self.boxHeight / 2 )

	-- Set up dialogue timer
	self:resetTimer()

	return self

end

function Dialogue:update()
	
	if self._showDialogue then
		self:draw()
		self:play()
	else
		self:clearCanvas()
	end

end

function Dialogue:show()
	self._showDialogue = true
end

function Dialogue:hide()
	self._showDialogue = false
end

function Dialogue:drawCanvas()
	self._canvas:draw( 0, 0 )
end

function Dialogue:clearCanvas()
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

	if self.finished then
		self:drawText( self.text )
		return
	end

	if self.text ~= nil then
		
		if self.dialogueType == DialogueType.Instant then
			
			self:drawText( self.text )
			self.finished = true
		
		elseif self.dialogueType == DialogueType.Typewriter then
			buildText( self )
		end

	elseif self.emote ~= nil then
		self.emote:add( self._emoteX, self._emoteY )
		-- Noble.currentScene():addSprite( self.emote )
	end
		
end

function Dialogue:resetTimer( textSpeed )
	
	if self.dialogueType == DialogueType.Instant then
		return
	end

	if textSpeed == nil then
		textSpeed = Noble.Settings.get( "text_speed" )
	end

	if textSpeed < TextSpeed.Fast then
		self._timerDuration = self._BASE_TIMER_DURATION / textSpeed
	else
		self._timerDuration = 0
	end

	self._dialogueTimer = playdate.timer.new( self._timerDuration, 0, self._timerDuration )

end

function Dialogue:reset()

	self._dialoguePointer = 0
	self:resetTimer()
	self.finished = false
	
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

-- Utility Functions --
function buildText( self )
	
	local textToShow = self.text:sub( 0, self._dialoguePointer )
	self:drawText( textToShow )

	if self._dialogueTimer.value < self._timerDuration then
		return
	end

	if self._dialoguePointer < #self.text then
		self._dialoguePointer += 1
		self:resetTimer()
	else
		self.finished = true
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