GameController = {}
class( "GameController" ).extends()

GameController.pet = nil
GameController.currentDialogueScript = 'intro'
GameController.currentDialogeLine = 1
GameController.dialogueLines = {
	intro = {
		"Welcome to the world of [GameTitle]!",
		"You'll be responsible for the care of\nyour very own pet",
		"Blah, blah, blah",
		-- TODO: Allow execution of dialogue and game manipulation functions
		"Blah, blah, blah",
	}
}

function GameController.getDialogue( script, line )

	local _script = GameController.currentDialogueScript
	local _line = GameController.currentDialogeLine

	if script ~= nil then
		_script = script
	end

	if line ~= nil then
		_line = line
	end

	return GameController.dialogueLines[_script][_line]

end

function GameController.advanceDialogueLine() 

	local line = GameController.getDialogue()

	if GameController.currentDialogeLine < #GameController.dialogueLines[GameController.currentDialogueScript] + 1 then
		GameController.currentDialogeLine += 1
		return line
	end
	
	return nil

end