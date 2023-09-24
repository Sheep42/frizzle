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
local SCREEN_WIDTH, SCREEN_HEIGHT = Utilities.screenSize()
local BASE_TIMER_DURATION = 100
local BOX_WIDTH = 0.75 * SCREEN_WIDTH -- 75% of screen
local BOX_HEIGHT = 75

local BORDER_WIDTH = BOX_WIDTH + 4
local BORDER_HEIGHT = BOX_HEIGHT + 4

-- Internals
local dialoguePointer = 0
local timerDuration = BASE_TIMER_DURATION
local dialogueTimer = nil

-- Positioning
local innerX = ( SCREEN_WIDTH / 2 ) - ( BOX_WIDTH / 2 )
local innerY = SCREEN_HEIGHT - 90 -- 150px
local outerX = ( SCREEN_WIDTH / 2 ) - ( BORDER_WIDTH / 2 )
local outerY = innerY - 2 -- border size, plus positioning offset
local textX, textY = innerX + 10, innerY + 10 -- Inner box position, plus some padding

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

	-- Set up dialogue timer
	self:resetTimer()

	return self

end

function Dialogue:draw()

	-- Draw the outer dialogue box
	Graphics.setColor( self.borderColor )
	Graphics.fillRoundRect( outerX, outerY, BORDER_WIDTH, BORDER_HEIGHT, 5 )
	
	-- Draw the inner dialogue box
	Graphics.setColor( self.backgroundColor )
	Graphics.fillRoundRect( innerX, innerY, BOX_WIDTH, BOX_HEIGHT, 5 )

end

function Dialogue:play()

	if self.finished then
		drawText( self.text )
		return
	end

	if self.dialogueType == DialogueType.Instant then
		
		drawText( self.text )
		self.finished = true
	
	elseif self.dialogueType == DialogueType.Typewriter then
		buildText( self )
	end
		
end

function Dialogue:resetTimer()
	
	if self.dialogueType == DialogueType.Instant then
		return
	end

	local textSpeed = Noble.Settings.get( "text_speed" )

	if textSpeed < TextSpeed.Fast then
		timerDuration = BASE_TIMER_DURATION / textSpeed
	else
		timerDuration = 0
	end

	dialogueTimer = playdate.timer.new( timerDuration, 0, timerDuration )

end

function Dialogue:reset()

	dialoguePointer = 0
	self:resetTimer()
	self.finished = false
	
end

-- Utility Functions --
function buildText( self )
	
	local textToShow = self.text:sub( 0, dialoguePointer )
	drawText( textToShow )

	if dialogueTimer.value < timerDuration then
		return
	end

	if dialoguePointer < #self.text then
		dialoguePointer += 1
		self:resetTimer()
	else
		self.finished = true
	end
	
end

function drawText( text, align )

	if text == nil then
		return
	end

	if align == nil then
		align = Noble.Text.ALIGN_LEFT
	end

	Noble.Text.draw( text, textX, textY, align )

end