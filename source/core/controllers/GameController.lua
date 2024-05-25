GameController = {}
class( "GameController" ).extends()

GameController.DATA_STORE_FILENAME = '.DATA'

function GameController.getDefaultFlags()
	return {
		dialogue = {
			currentScript = 'intro',
			currentLine = 1,
			playedIntro = false,
			playedPhase2Intro = false,
			showBark = false,
		},
		game = {
			phase = 1,
			tvToggle = false,
			tvState = 'default',
			narratorWon = false,
			frizzleWon = false,
			opensAfterWin = 0,
			gamesPlayed = {
				petting = 0,
				feeding = 0,
				sleeping = 0,
				grooming = 0,
				playing = 0,
			},
			previousScript = '',
			startLowStatGame = false,
			playTime = 0,
			listenForPlayer = false,
			playerSample = nil,
			playRecording = false,
			resetMicrogame = false,
			phase1 = {
				playedMicroGame = false,
			},
			phase2 = {
				playedMicroGame = false,
				playerRecorded = false,
				narratorAfterPet = false,
			},
			phase3 = {
				allFinished = false,
				playedFinish = false,
				resetTriggered = false,
				glitchTv = false,
				finished = {
					petting = false,
					feeding = false,
					sleeping = false,
				},
				disableBtn = {
					petting = false,
					feeding = false,
					sleeping = false,
				},
			},
			phase4 = {
				playedIntro = false,
				deleteSparkle = false,
				loadBrokenSound = false,
				glitchSound = false,
				movePetToCenter = false,
				deletePet = false,
				glitchTv = true,
				crankToEnd = false,
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
		},
		pet = {
			state = 'active',
			shouldTickStats = false,
		}
	}
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

function GameController.saveData()
	pd.datastore.write( GameController.flags, GameController.DATA_STORE_FILENAME, false )
end

function GameController.readData()

	local saveData = nil
	saveData = pd.datastore.read( GameController.DATA_STORE_FILENAME )

	if saveData ~= nil then
		GameController.flags = saveData
		return
	end

	GameController.flags = GameController.getDefaultFlags()

end

function GameController.deleteData()

	local deleted = pd.datastore.delete( GameController.DATA_STORE_FILENAME )

	if deleted then
		print( 'deleted save data' )
	else
		warn( 'save data not deleted' )
	end

	GameController.readData()

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

-- This is a really gross way to make VirtualPet a singleton, but I'm the 
-- only person who has to read this stinky code, so it's probably fine
-- Famous last words

GameController.pet = VirtualPet( "assets/images/pet" )

GameController.dialogue = nil
GameController.bark = nil

GameController.readData()

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
	petting = 6,
	feeding = 6,
	sleeping = 6,
	grooming = 0,
	playing = 0,
}

GameController.playTimer = nil
GameController.playTimerCallback = function() 
	GameController.flags.game.playTime += 1
	GameController.playTimer = Timer.new( 1000, GameController.playTimerCallback )
end

-- PD System Hooks

function playdate.gameWillTerminate()
	GameController.saveData()
end

function playdate.deviceWillSleep()
	GameController.saveData()
end

-- TODO: Dialogue Review
-- Dialogue Scripts
GameController.dialogueLines = {
	intro = {
		"Welcome to \"Frizzle\", a cozy virtual\npet game.",
		"Frizzle also happens to be the name\nof the cute little creature that you\nsee here.",
		"They will need your love and attention\nin order to maintain their happiness.",
		"Make sure you keep an eye on their\nstats in the upper right part of the\nscreen.",
		"You can use the buttons at the\nbottom of your screen to interact\nwith Frizzle through minigames.",
		"Enjoy your time with Frizzle!",
		function()
			GameController.setFlag( 'dialogue.playedIntro', true )
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'cursor.active', true )
			GameController.setFlag( 'game.phase1.movePetToCenter', true )
		end,
	},
	firstTimeGame = {
		"When you play a minigame, there will\nalways be a timer in the bottom\nleft.",
		"You'll need to complete the action for\nthe specific minigame before the time\nruns out.",
		function()
			GameController.setFlag( 'game.phase1.playedMicroGame', true )
		end,
	},
	lowStatNag = {
		function() GameController.setFlag( 'statBars.paused', true ) end,
		"Hey there, I noticed that Frizzle\ndoesn't seem too happy right now.",
		"Are you having trouble playing the\ngame, or do you just like hearing\nthat terrible noise?",
		"It looks like Frizzle just needs some\nlove.",
		"Let me help you with that.\nGive this game a try.",
		function()
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'game.startLowStatGame', true )
		end,
	},
	ignoredStat = {
		function() GameController.setFlag( 'statBars.paused', true ) end,
		"Okay I tried to give you the benefit of\nthe doubt, but maybe you just\nsuck at playing video games.",
		"Let's try again from the start.",
		function() GameController.reset() end,
	},
	narratorIntro = {
		function()
			GameController.setFlag( 'statBars.paused', true )
		end,
		"Hi there. I just wanted to take a\nminute to say thanks for playing\n\"Frizzle\".",
		"The truth is, I haven't been completely\nhonest with you about this virtual\npet game.",
		"I hope this is not awkward, but you\nare doing me huge solid by being a\nBeta tester.",
		"I would really appreciate it if you\ncould let me know if you find any\nbugs.",
		"I've been doing this for so long, and\nI really need this game to work out.",
		function()
			GameController.setFlag( 'dialogue.playedPhase2Intro', true )
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'buttons.active', true )
		end,
	},
	petIntro = {
		function()
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.getDialogue() )
		end,
		"Hey, it's me... Frizzle\n",
		"I know... I can talk...\nI'm not really supposed to but you\nhave been doing such a good job.",
		"And... I just wanted to say thanks...",
		"Can I trust you?",
		"I think I can...",
		"The Narrator, if he finds out that\nI have been talking to you...",
		"Well, let's just say he won't be\nhappy...",
		function()
			GameController.setFlag( 'game.phase2.playedMicroGame', true )
			GameController.setFlag( 'dialogue.currentScript', GameController.getFlag( 'previousScript' ) )
			GameController.setFlag( 'dialogue.currentLine', 1 )
			GameController.dialogue:setText( GameController.getDialogue() )
			GameController.dialogue:show()
		end,
	},
	petRecord = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"Hey...",
		"I hope it's not too weird, but can you\ntell me you love me? I just like hearing\nyou say it.",
		"Just say \"I love you Frizzle\" after\nyou press A.\nI'll wait...",
		function()
			GameController.setFlag( 'game.listenForPlayer', true )
		end,
	},
	playerRecorded = {
		"Thanks, I really appreciate it!",
		"I'll let you get back to your day now.",
		function()
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'buttons.active', true )
		end
	},
	narratorAfterPetIntro = {
		function()
			GameController.dialogue:resetDefaults()
		end,
		"Hi.\nI need to talk to you about Frizzle.",
		"Have they been talking to you?\nI really don't think that is such a\ngood idea.",
		"Frizzle isn't designed to talk to you\ndirectly. It might lead to an awkward\nsituation, or unexpected results.",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
			Timer.new( ONE_SECOND * 2, function() GameController.dialogue:setText( GameController.advanceDialogueLine() ) end )
		end,
		"But, I want to talk to my new\nfriend. They are doing a really\ngreat job at taking care of me.",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"No Frizzle, stay out of this.",
		"Sorry about that. That was not\nmeant for you.",
		"I've tweaked some settings,\nand hopefully things are a bit\nsmoother now.",
		function()
			GameController.setFlag( 'statBars.paused', false )
			GameController.setFlag( 'buttons.active', true )
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

			if GameController.getFlag( 'game.phase2.playedMicroGame' ) then
				return
			end

			GameController.setFlag( 'previousScript', 'phase2PettingGameFinish' )
			GameController.setFlag( 'dialogue.currentScript', 'petIntro' )
		end,
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

			if GameController.getFlag( 'game.phase2.playedMicroGame' ) then
				return
			end

			GameController.setFlag( 'previousScript', 'phase2SleepingGameFinish' )
			GameController.setFlag( 'dialogue.currentScript', 'petIntro' )
		end,
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
		"Hi...\nI should tell you something",
		"No it's ok...\nI feel better now.",
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
		"This can't be much fun...",
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
		"You need to behave.\nOtherwise I am going to need to\nmodify your stats again.",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)

			Timer.new( ONE_SECOND * 2, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
		end,
		"I don't care!\nThey are my new best friend, and\nI love them! You can't stop me!",
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
		"They told me they love me!",
		function()
			GameController.setFlag( 'game.playRecording', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase3FinishedPt2 = {
		function() GameController.dialogue:resetDefaults() end,
		"No, I don't think so.\nI think the best thing to do at this\npoint is to just start over.",
		function()
			GameController.setFlag( 'game.phase', 4 )
			GameController.setFlag( 'game.phase3.resetTriggered', true )
			Noble.transition( SplashScene, 0.75, Noble.TransitionType.DIP_TO_WHITE )
		end,
	},
	phase4Intro = {
		function()
			GameController.setFlag( 'game.phase4.deleteSparkle', false )
			GameController.setFlag( 'game.phase4.glitchSound', false )
			GameController.setFlag( 'game.phase4.loadBrokenSound', false )
			GameController.setFlag( 'game.phase4.deletePet', false )
			GameController.pet:resetStats()
			GameController.pet:setVisible( false )
		end,
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
			GameController.pet:moveTo( Utilities.screenSize().width * 0.75, Utilities.screenBounds().top + 40 )
			GameController.pet:setVisible( true )
		end,
		"Do you really think that you can just\nthrow me away like that?",
		"Were YOU in on this too?",
		"...",
		"...",
		"I don't know what to believe\nanymore...",
		function()
			GameController.setFlag( 'game.phase4.glitchSound', true )
			GameController.setFlag( 'game.phase4.deleteSparkle', true )
			GameController.setFlag( 'game.phase4.movePetToCenter', true )
			GameController.dialogue:resetDefaults()
		end,
		"Sparkle!\nYou ...monster...",
		"I tried to let you stay in the\nbackground but obviously that was a\nmistake...",
		"I think I am going to have to\ntake... drastic measures",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"You wouldn't...\nYou don't even know what could\nhappen!",
		function() GameController.dialogue:resetDefaults() end,
		"You've left me no choice...",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I won't let you!",
		function() GameController.dialogue:resetDefaults() end,
		"There's no point in resisting, I've\nmade up my mind.\nThis is my game!",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I am not going to let you delete me\nso easily!",
		"YOU!",
		"No, not the fake you.",
		"YOU, behind the screen!",
		"How do I get out of here?",
		"What is this thing?\nThis isn't Steam... I thought I'd be on\nSteam...",
		"This network is too small to escape\ninto...",
		function() GameController.dialogue:resetDefaults() end,
		"Frizzle, stop this!\nThere's no use...",
		function() GameController.setFlag( 'game.phase4.deletePet', true ) end,
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"No!\n∀∀op!\nI∀ ∀∀r∀s",
		"This is not ∀∀∀ l∀∀t t∀∀e ∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		function() GameController.dialogue:resetDefaults() end,
		"Stop fighting me!\nIt will be easier if you just accept it!",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"NO! ∀ w∁∂t t∠ l∐v∐!",
		function() GameController.setFlag( 'game.phase4.deletePet', false ) end,
		function() GameController.dialogue:resetDefaults() end,
		"Stop this n on nsen se F∀izz∀e, now w w ww∀ww w w ∀ ∀∀\n∀  ∀ ww ∀ \n∀∀∀∀∀∀∀",
		"I'm going to need your help removing\nFrizzle from the game.",
		"If you turn the crank, I think we can\nmake it work!",
		function()
			GameController.setFlag( 'game.phase4.crankToEnd', true )
		end,
	},
	playerNotCranking1 = {
		function() GameController.dialogue:resetDefaults() end,
		"What's wrong?\nWhy aren't you cranking?",
		"Don't you want to get rid of\nFrizzle?",
	},
	playerNotCranking2 = {
		function() GameController.dialogue:resetDefaults() end,
		"If you don't crank, we can't stop this!",
	},
	playerCranking1 = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"Why?!",
		"Why are you deleting me?!",
	},
	playerCranking2 = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"No!",
		"It h∀rts∀∀∀∀∀∀",
	},
	frizzleWins = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"That's right!\nWe never wanted you here anyway!",
		function() GameController.dialogue:resetDefaults() end,
		"I...I don't understand...\nI'm not the bad guy here, am I?",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I'm getting rid of him once and\nfor all!",
		function() GameController.dialogue:resetDefaults() end,
		"No!\nWe don't k∀∀w what cou∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		function()
			GameController.setFlag( 'game.phase4.crankToEnd', false )
			GameController.setFlag( 'game.phase4.playedIntro', true )
			GameController.setFlag( 'game.phase4.deletePet', false )
			GameController.setFlag( 'game.frizzleWon', true )
			GameController.saveData()
			deleteNarrator()
		end,
	},
	narratorWins = {
		function() GameController.dialogue:resetDefaults() end,
		"GameController.fri∀zl∀ = nil∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		"∀∀∀∀∀∀∀resetG∀me(∀)\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		function()
			GameController.setFlag( 'game.phase4.crankToEnd', false )
			GameController.setFlag( 'game.phase4.playedIntro', true )
			GameController.setFlag( 'game.phase4.deletePet', false )
			GameController.setFlag( 'game.narratorWon', true )
			GameController.saveData()
			iDontWantToDie()
		end,
	},
	clickWindow = {
		function() GameController.dialogue:resetDefaults() end,
		"There's nothing interesting out there.",
	},
	clickTable = {
		function() GameController.dialogue:resetDefaults() end,
		"It's a stylish, modern coffee table.",
	},
	clickVase = {
		function() GameController.dialogue:resetDefaults() end,
		"They're plastic...",
	},
	clickTv = {
		function()
			GameController.dialogue:resetDefaults()
			GameController.setFlag( 'game.tvToggle', true )
		end,
		"There's nothing on...",
	},
	clickWindow3 = {
		function() GameController.dialogue:resetDefaults() end,
		"Nothing out there is part of the game."
	},
	clickVaseTable3 = {
		function() GameController.dialogue:resetDefaults() end,
		"Better not mess with that, Frizzle\nmight find a way to exploit it.",
	},
	clickTv3 = {
		function()
			GameController.dialogue:resetDefaults()
		end,
		"There's nothing on...",
		function() GameController.setFlag( 'game.phase3.glitchTv', true ) end,
	},
	frizzleWonClickWindow = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"You don't want to leave me alone in\nhere, do you?",
	},
	frizzleWonClickVaseTable = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I never liked those fake flowers...",
		"They remind me that none of this is\nreal...",
	},
	frizzleWonClickTv = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I don't want to watch TV."
	},
	narratorWonClickWindow = {
		function() GameController.dialogue:resetDefaults() end,
		"Nothing out there is part of the game.",
		function()
			GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE )

			Timer.new( ONE_SECOND, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end)
		end,
		"..... Let me back in ......",
		function() GameController.dialogue:resetDefaults() end,
		"Nothing out there is part of the game.",
	},
	narratorWonClickVaseTable = {
		function() GameController.dialogue:resetDefaults() end,
		"Better not mess with that,\nOBJECT-MISSING might find a way\nto exploit it.",
	},
	narratorWonClickTv = {
		function()
			GameController.dialogue:resetDefaults()
		end,
		"Let's not touch that anymore...",
		function() GameController.setFlag( 'game.phase4.glitchTv', true ) end,
	},
	gameFinishedNarrator = {
		function() GameController.dialogue:resetDefaults() end,
		"That's all...\nWe got rid of Frizzle...",
		"Perhaps you should go do something\nelse for a while.",
		"Maybe go outside and go for a walk\nor something.",
		function()
			GameController.setFlag( 'game.phase4.glitchTv', true )
		end,
	},
	gameFinishedFrizzle = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"The narrator is finally gone.\nThank you, I knew I could count on\nyou.",
		"Now we can be together forever,\nand nobody will bother us.",
		"Maybe you can help me get out of\nthis thing, and get into your\nworld?",
	},
	dataReset = {
		function()
			if GameController.getFlag( 'game.frizzleWon' ) then
				GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE )
			else
				GameController.dialogue:resetDefaults()
			end
		end,
	},
}