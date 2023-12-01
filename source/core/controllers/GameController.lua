GameController = {}
class( "GameController" ).extends()

GameController.pet = VirtualPet( "assets/images/pet" )
GameController.dialogue = nil
GameController.flags = {
	dialogue = {
		currentScript = 'intro',
		currentLine = 1,
		playedIntro = false,
	},
	statBars = {
		paused = true,
	},
}

function GameController.getDialogue( script, line )

	local _script = GameController.flags.dialogue.currentScript
	local _line = GameController.flags.dialogue.currentLine

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
		GameController.flags.dialogue.currentLine += 1
		line = GameController.getDialogue()
	end

	if GameController.flags.dialogue.currentLine < #GameController.dialogueLines[GameController.flags.dialogue.currentScript] + 1 then
		GameController.flags.dialogue.currentLine += 1
		return line
	end
	
	return nil

end

function GameController.setFlag( flag, value )
 
	local keys = {}
    local current = GameController.flags

    for key in string.gmatch( flag, "[^%.]+" ) do     
		keys[#keys + 1] = key
	end

	for i = 1, #keys - 1 do
		
		current = current[keys[i]]

		-- Cannot create flags this way
		if current == nil then
			warn( "WARNING: Cannot create a flag with setFlag. Skipping. flag: " .. flag )
            return 
        end

    end

    local lastKey = keys[#keys]
    current[lastKey] = value

end

function GameController.getFlag( flag )
	 
    local current = GameController.flags

    for key in string.gmatch( flag, "[^%.]+" ) do
        
		current = current[key]

		-- Cannot create flags this way
		if current == nil then
			warn( "WARNING: Flag not found. Returning nil. flag: " .. flag )
            return nil
        end

    end

    return current

end

GameController.dialogueLines = {
	intro = {
		"Welcome to the world of [GameTitle]!",
		"You'll be responsible for the care of\nyour very own pet",
		"Blah, blah, blah",
		"Blah, blah, blah",
		function() GameController.setFlag( 'dialogue.playedIntro', true ) end,
		function() GameController.setFlag( 'statBars.paused', false ) end,
	}
}