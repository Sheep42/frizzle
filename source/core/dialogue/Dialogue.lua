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
Dialogue.text = ""
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

function Dialogue:new( text, x, y, boxWidth, boxHeight, borderWidth, borderHeight, dialogueType, backgroundColor, borderColor, textColor )

	if text ~= nil then
		self.text = text
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

	if self.dialogueType == DialogueType.Instant then
		
		self:drawText( self.text )
		self.finished = true
	
	elseif self.dialogueType == DialogueType.Typewriter then
		buildText( self )
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

	Noble.Text.draw( text, self._textX, self._textY, align )

end