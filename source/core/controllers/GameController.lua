GameController = {}
class( "GameController" ).extends()


-- This is a really gross way to make VirtualPet a singleton, but I'm the 
-- only person who has to read this stinky code, so it's probably fine
-- Famous last words

GameController.pet = VirtualPet( "assets/images/pet" )

GameController.dialogue = nil
GameController.bark = nil

function GameController.getDefaultFlags()
	return {
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
			listenForName = false,
			playTime = 0,
			nameSample = nil,
			playRecording = false,
		},
		buttons = {
			active = true,
		},
		statBars = {
			paused = true,
			playCry = false,
			friendship = {
				nagged = false,
				emptyTime = 0,
			},
			hunger = {
				nagged = false,
				emptyTime = 0,
			},
			tired = {
				nagged = false,
				emptyTime = 0,
			},
			groom = {
				nagged = false,
				emptyTime = 0,
			},
			boredom = {
				nagged = false,
				emptyTime = 0,
			},
		}
	}
end
GameController.flags = GameController.getDefaultFlags()

GameController.STAT_BAR_CRY_TIME = 2
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

function GameController.reset()

	if Noble.Settings.get( 'debug_mode' ) then
		print( 'RESET GAME' )
	end

	Noble.transition( TitleScene, 0.75, Noble.TransitionType.DIP_WIDGET_SATCHEL )
	GameController.flags = GameController.getDefaultFlags()
	GameController.pet = VirtualPet( 'assets/images/pet' )
	GameController.playTimer = nil

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
	ignoredStat = {
		function() GameController.setFlag( 'statBars.paused', true ) end,
		"Okay, I tried to give you the benefit of\nthe doubt but it seems that you just\nsuck at playing video games.",
		"Git gud.",
		function() GameController.reset() end,
	},
	petIntro = {
		function() 
			GameController.setFlag( 'statBars.paused', true )
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Hey, it's me... Frizzle\n",
		"Yeah, I know... I can talk...\nI'm supposed to stay quiet, but you\nhave been doing such a good job.",
		"I just wanted to say thanks.",
		"...",
		"...",
		"Hey... can you do me a little favor?",
		"I hope it's not weird, but can you\nsay my name? I just like hearing you\nsay it.",
		"Just say \"Frizzle\" after you press A.\nI'll wait...",
		function()
			GameController.setFlag( 'game.listenForName', true )
		end,
	},
	nameRecorded = {
		"Thanks, I really appreciate it!",
		"I'll let you get back to the game now.",
		function()
			GameController.setFlag( 'dialogue.showBark', true )
			GameController.bark:setEmote( NobleSprite( 'assets/images/UI/heart' ), nil, nil, 'assets/sound/win-game.wav' )
			GameController.pet:resetStats()

			Timer.new( ONE_SECOND * 2, function()
				GameController.setFlag( 'dialogue.currentScript', 'narratorAfterPetIntro' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:resetDefaults()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)

		end,
	},
	narratorAfterPetIntro = {
		"Hi there, I noticed that you and Frizzle\nwere chatting. I think it would be in\nyour best interest to avoid direct",
		"conversation with them.",
		"It's just that Frizzle isn't really\nsupposed to talk to you. It ruins the\nimmersion, you know?",
		"If they talk to you again, just try to\nignore it and stick to playing\nthe game.",
		function()
			Timer.new( ONE_SECOND * 2, function()
				GameController.setFlag( 'dialogue.currentScript', 'playRecording' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)

		end,
	},
	playRecording = {
		function()
			GameController.setFlag( 'statBars.paused', true )
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Hey... it's me again...",
		"Sorry if I got you in trouble with the\nnarrator. If you ask me, he's too\nuptight anyway.",
		"Anyways, I hope it's not weird, but I\nreally liked hearing you say my name\nso I kept it as a momento...",
		function() GameController.setFlag( 'game.playRecording', true ) end,
		"That's okay with you, right?",
		function()
			GameController.dialogue:resetDefaults()
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'buttons.active', true )
		end,
	}
}