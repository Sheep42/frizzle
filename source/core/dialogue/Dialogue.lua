Dialogue = {}
class( "Dialogue" ).extends()

DialogueType = {
	Typewriter = "typewriter",
	Instant = "instant",
	Fade = "fade"
}

TextSpeed = {
	Slow = 1,
	Normal = 2,
	Fast = 3
}

-- Member variables
Dialogue.text = ""
Dialogue.backgroundColor = Graphics.kColorWhite
Dialogue.borderColor = Graphics.kColorBlack
Dialogue.textColor = Graphics.kColorBlack
Dialogue.dialogueType = DialogueType.Typewriter
Dialogue.finished = false

-- Constants
Dialogue._BASE_TIMER_DURATION = 100
Dialogue._BOX_WIDTH = 0.75 * Utilities.screenSize().width -- 75% of screen
Dialogue._BOX_HEIGHT = 75

Dialogue._borderWidth = 0
Dialogue._boderHeight = 0

-- Internals
Dialogue._dialoguePointer = 0
Dialogue._timerDuration = 0
Dialogue._dialogueTimer = nil
Dialogue._showDialogue = false
Dialogue._canvas = nil

-- Positioning 
Dialogue._innerX = 0
Dialogue._innerY = 0
Dialogue._outerX = 0
Dialogue._outerY = 0
Dialogue._textX = 0
Dialogue._textY = 0

function Dialogue:new( text, dialogueType, backgroundColor, borderColor, textColor )

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

	self._borderWidth = self._BOX_WIDTH + 4
	self._boderHeight = self._BOX_HEIGHT + 4
	self._timerDuration = self._BASE_TIMER_DURATION
	self._canvas = Graphics.image.new( Utilities.screenSize().width, Utilities.screenSize().height )

	-- Positioning
	self._innerX = ( Utilities.screenSize().width / 2 ) - ( self._BOX_WIDTH / 2 )
	self._innerY = Utilities.screenSize().height - 90 -- 150px
	self._outerX = ( Utilities.screenSize().width / 2 ) - ( self._borderWidth / 2 )
	self._outerY = self._innerY - 2 -- border size, plus positioning offset
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
	Graphics.fillRoundRect( self._outerX, self._outerY, self._borderWidth, self._boderHeight, 5 )
	
	-- Draw the inner dialogue box
	Graphics.setColor( self.backgroundColor )
	Graphics.fillRoundRect( self._innerX, self._innerY, self._BOX_WIDTH, self._BOX_HEIGHT, 5 )

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