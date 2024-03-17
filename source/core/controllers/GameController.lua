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
			playedPhase2Intro = false,
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
			listenForName = false,
			nameSample = nil,
			playRecording = false,
			resetMicrogame = false,
			phase3 = {
				allFinished = false,
				playedFinish = false,
				resetTriggered = false,
				finished = {
					petting = false,
					feeding = false,
					sleeping = false,
				},
				disableBtn = {
					petting = false,
					feeding = false,
					sleeping = false,
				}
			},
			phase4 = {
				playedIntro = false,
				deleteSparkle = false,
			},
		},
		buttons = {
			active = true,
		},
		cursor = {
			active = false,
		},
		statBars = {
			paused = true,
			playCry = false,
			friendship = {
				nagged = false,
				emptyTime = 0,
				disabled = false,
			},
			hunger = {
				nagged = false,
				emptyTime = 0,
				disabled = false,
			},
			tired = {
				nagged = false,
				emptyTime = 0,
				disabled = false,
			},
			groom = {
				nagged = false,
				emptyTime = 0,
				disabled = false,
			},
			boredom = {
				nagged = false,
				emptyTime = 0,
				disabled = false,
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

GameController.PHASE_3_GAME_TRIGGERS = {
	petting = 4,
	feeding = 4,
	sleeping = 4,
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

-- TODO: Dialogue Review
GameController.dialogueLines = {
	intro = {
		"Congratulations on meeting your new\nbest friend Frizzle!",
		"Frizzle needs your love and attention\nin order to thrive.",
		"Make sure you keep an eye on their\nstats in the upper right.",
		"You can use the buttons at the\nbottom of your screen to interact\nwith Frizzle.",
		"Good luck, and have fun!",
		function() 
			GameController.setFlag( 'dialogue.playedIntro', true )
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'cursor.active', true )
		end,
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
		"That's okay with you, right?",
		function()
			GameController.setFlag( 'game.playRecording', true )
			GameController.setFlag( 'dialogue.playedPhase2Intro', true )
			GameController.dialogue:resetDefaults()
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'buttons.active', true )
		end,
	},
	phase2PettingGameFinish = {
		function() 
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Hi",
		"...",
		"...",
		"Can you pet me a bit more before\nyou go?",
		"I would really like that.",
		function()
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase2SleepingGameFinish = {
		function() 
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"...",
		"I know you are busy...",
		"Can you just stay with me for\na little while longer?",
		function()
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase3PettingGameFinish = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Hi",
		"...",
		"...",
		"Can you pet me a bit more before\nyou go?",
		"I would really like that.",
		function()
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()

			Timer.new( ONE_SECOND * 3, function()
				GameController.setFlag( 'dialogue.currentScript', 'phase3PettingGameNarrator' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.dialogue:show()
			end)
		end,
	},
	phase3PettingGameNarrator = {
		"No! Stop this.\nThis...this whole thing is perverse!",
		"I am ending this minigame now!",
		function()
			GameController.setFlag( 'game.phase3.finished.petting', true )
			GameController.setFlag( 'game.phase3.disableBtn.petting', true )
			GameController.pet.stats.friendship.value = 0
			GameController.setFlag( 'statBars.friendship.disabled', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase3SleepingGame = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"I'm not tired right now, I don't want\nto go to sleep.",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"You have to go to sleep, that is how\nthis works.",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Well I'm not gonna...\nSo what are you going to do\nabout it?",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"I told you that you have to behave,\nbut you just don't listen.",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)

			Timer.new( ONE_SECOND * 2, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
		end,
		"No, I don't want to. I just want\nto hang out with my new best friend.\nThey are the best, and I love them.",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"That's it. This minigame is over!",
		function()
			GameController.setFlag( 'game.phase3.finished.sleeping', true )
			GameController.setFlag( 'game.phase3.disableBtn.sleeping', true )
			GameController.pet.stats.tired.value = 0
			GameController.setFlag( 'statBars.tired.disabled', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase3FeedingGame = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"I'm not hungry.",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"This can't be much fun for the\nplayer...",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Well I am not hungry! Just because\nyour stupid bars say so doesn't\nmake it true.",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"You need to behave, do you want\nthem to find out about you?",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)

			Timer.new( ONE_SECOND * 2, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
		end,
		"I don't care!\nThey are my new best friend, and\nI love them!",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"That's enough!\nThis ends here.",
		function()
			GameController.setFlag( 'game.phase3.finished.feeding', true )
			GameController.setFlag( 'game.phase3.disableBtn.feeding', true )
			GameController.pet.stats.hunger.value = 0
			GameController.setFlag( 'statBars.hunger.disabled', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase3BtnAfterFinish = {
		"No, I said no more...\nTry something else!",
	},
	phase3Finished = {
		function() GameController.dialogue:resetDefaults() end,
		"I hope you're happy Frizzle, you've\nruined another player's experience.",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"I don't think I ruined anything!\nWhy don't you ask them what they\nthink?",
		function() GameController.dialogue:resetDefaults() end,
		"No, I don't think so.\nI think the best thing to do at this\npoint is to just start over.",
		function()
			GameController.setFlag( 'game.phase', 4 )
			GameController.setFlag( 'game.phase3.resetTriggered', true )
			Noble.transition( SplashScene, 0.75, Noble.TransitionType.DIP_TO_WHITE )
		end,
	},
	phase4Intro = {
		"Congratulations on meeting your new\nbest friend Sparkle!",
		"Sparkle needs your love and attention\nin order to thrive.",
		function()
			Timer.new( ONE_SECOND * 2, function() 
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end)
		end,
		"Make sure you keep an eye on their\nstats in the upper right.",
		function() 
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Do you really think that you can just\nthrow me away like that?",
		"Were YOU in on this too?",
		"...",
		"...",
		"I don't know what to believe\nanymore...",
		function()
			GameController.setFlag( 'game.phase4.deleteSparkle', true )
			GameController.dialogue:resetDefaults()
		end,
		"Sparkle!\nYou ...monster...",
		"I tried to let you stay in the\nbackground but obviously that was a\nmistake...",
		"I think I am going to have to\ntake... drastic measures",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"You wouldn't...",
		function() GameController.dialogue:resetDefaults() end,
		"You've left me no choice...",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"But you don't even know what\nmight happen!",
		function() GameController.dialogue:resetDefaults() end,
		"Yes...I know...",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I won't let you!",
		function() GameController.dialogue:resetDefaults() end,
		"There's no point in resisting, I've\nmade up my mind.",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"So have I!",
		"So have I!",
		"S∀ h∀∀∀ ∀",
		"No!\n∀∀op!\nI∀ ∀∀r∀s",
		function() GameController.dialogue:resetDefaults() end,
		"Stop fighting me!\nIt will be easier if you just accept it!",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"NO! ∀ w∁∂t t∠ l∐v∐!",
		function() GameController.dialogue:resetDefaults() end,
		"Stop this n on nsen se now w w ww∀ww w w ∀ ∀∀\n∀  ∀ ww ∀ \n∀∀∀∀∀∀∀",
		"GameController.fri∀zl∀ = nil",
		"resetG∀me(∀)",
		function()
			GameController.setFlag( 'game.phase4.playedIntro' )
			iDontWantToDie()
		end
	},
}