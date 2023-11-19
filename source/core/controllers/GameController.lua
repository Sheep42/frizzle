GameController = {}
class( "GameController" ).extends()

GameController.pet = nil
GameController.dialogue = nil
GameController.flags = {
	currentDialogueScript = 'intro',
	currentDialogueLine = 1,
}
GameController.dialogueLines = {
	intro = {
		"Welcome to the world of [GameTitle]!",
		"You'll be responsible for the care of\nyour very own pet",
		"Blah, blah, blah",
		"Blah, blah, blah",
	}
}

function GameController.getDialogue( script, line )

	local _script = GameController.flags.currentDialogueScript
	local _line = GameController.flags.currentDialogueLine

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

	if GameController.flags.currentDialogueLine < #GameController.dialogueLines[GameController.flags.currentDialogueScript] + 1 then
		GameController.flags.currentDialogueLine += 1
		return line
	end
	
	return nil

end