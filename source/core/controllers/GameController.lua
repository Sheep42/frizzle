GameController = {}
class( "GameController" ).extends()

GameController.pet = nil
GameController.dialogue = nil
GameController.flags = {
	currentDialogueScript = 'intro',
	currentDialogueLine = 1,
	playedIntro = false,
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

	while type(line) == 'function' do
		line()
		GameController.flags.currentDialogueLine += 1
		line = GameController.getDialogue()
	end

	if GameController.flags.currentDialogueLine < #GameController.dialogueLines[GameController.flags.currentDialogueScript] + 1 then
		GameController.flags.currentDialogueLine += 1
		return line
	end
	
	return nil

end

function GameController.setFlag( flag, value )
	GameController.flags[flag] = value
end

function GameController.getFlag( flag )
	return GameController.flags[flag]
end

GameController.dialogueLines = {
	intro = {
		"Welcome to the world of [GameTitle]!",
		"You'll be responsible for the care of\nyour very own pet",
		"Blah, blah, blah",
		function() GameController.setFlag( 'playedIntro', false ) end,
		"Blah, blah, blah",
		function() GameController.setFlag( 'playedIntro', true ) end,
	}
}