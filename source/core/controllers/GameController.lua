GameController = {}
class( "GameController" ).extends()


-- This is a really gross way to make VirtualPet a singleton, but I'm the 
-- only person who has to read this stinky code, so it's probably fine
-- Famous last words
	

GameController.pet = VirtualPet( "assets/images/pet" )

GameController.dialogue = nil
GameController.flags = {
	dialogue = {
		currentScript = 'intro',
		currentLine = 1,
		playedIntro = false,
		showBark = nil,
	},
	game = {
		phase = 1,
		gamesPlayed = {
			petting = 0,
			feeding = 0,
			sleeping = 0,
			grooming = 0,
			playing = 0,
		},
		startLowStatGame = false,
		playTime = 0,
	},
	statBars = {
		paused = true,
	}
}

GameController.STAT_BAR_FAIL_STAGE_1_TIME = 5
GameController.STAT_BAR_FAIL_STAGE_2_TIME = 10

GameController.PHASE_2_TIME_TRIGGER = 300
GameController.PHASE_2_GAME_TRIGGERS = {
	petting = 1,
	feeding = 1,
	sleeping = 1,
	grooming = 0,
	playing = 0,
}

GameController.playTimer = nil
GameController.playTimerCallback = function() 
	GameController.flags.game.playTime += 1
	GameController.playTimer = Timer.new( 1000, GameController.playTimerCallback )
end

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

		-- Cannot create flags this way because I said so, define game flags 
		-- in the flags table, ya nerd
		if current == nil then
			print( "WARNING: Cannot create a flag with setFlag. Skipping. flag: " .. flag )
            return
        end

    end

    local lastKey = keys[#keys]
    current[lastKey] = value

    if Noble.Settings.get( "debug_mode" ) then
    	print( "Set " .. flag .. " = " .. tostring( value ) )
    end

end

function GameController.getFlag( flag )

    local current = GameController.flags

    for key in string.gmatch( flag, "[^%.]+" ) do

		current = current[key]

		-- Cannot create flags this way
		if current == nil then
			print( "WARNING: Flag not found. Returning nil. flag: " .. flag )
            return nil
        end

    end

    return current

end

GameController.dialogueLines = {
	intro = {
		"Congratulations on meeting your new\nbest friend Frizzle!",
		"Frizzle needs your love and attention\nin order to thrive.",
		"Make sure you keep an eye on their\nstats in the upper right.",
		"You can use the buttons at the\nbottom of your screen to interact\nwith Frizzle.",
		"Good luck, and have fun!",
		function() GameController.setFlag( 'dialogue.playedIntro', true ) end,
		function() GameController.setFlag( 'statBars.paused', false ) end,
	},
	lowStatNag = {
		function() GameController.setFlag( 'statBars.paused', true ) end,
		"Hey there, I noticed that Frizzle\ndoesn't seem too happy right now.",
		"Are you having trouble playing the\ngame, or do you just like that\nterrible noise?",
		"It looks like Frizzle just needs some\nlove.",
		"Let me help you with that.\nGive this game a try.",
		function()
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'game.startLowStatGame', true )
		end,
	},
}