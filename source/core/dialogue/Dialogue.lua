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
Dialogue.dialogueType = DialogueType.Fade

-- Constants
local BOX_WIDTH = 275
local BOX_HEIGHT = 75

local BORDER_WIDTH = BOX_WIDTH + 4
local BORDER_HEIGHT = BOX_HEIGHT + 4

-- Internals
local isPlayingDialogue = false
local dialoguePointer = 0
local innerX = ( 400 / 2 ) - ( BOX_WIDTH / 2 )
local innerY = 240 - 90 -- 150px
local outerX = ( 400 / 2 ) - ( BORDER_WIDTH / 2 )
local outerY = innerY - 2 -- border size, plus positioning offset
local textX, textY = innerX + 10, innerY + 10 -- Inner box position, plus some padding

function Dialogue:new( text, dialogueType, backgroundColor, borderColor )

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
	-- TODO: Dialogue types
	Noble.Text.draw( self.text, textX, textY, Noble.Text.ALIGN_LEFT )
end

function Dialogue:pause()
end