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
			buttonPressEnabled = true,
			playedTrashFull = false,
		},
		game = {
			phase = 1,
			tvToggle = false,
			tvState = 'default',
			fridgeState = 'default',
			fruitState = 'default',
			trashState = 'default',
			showCard = true,
			narratorWon = false,
			frizzleWon = false,
			hideFrizzle = false,
			opensAfterWin = 0,
			resetCrank = false,
			rollCredits = false,
			doDataReset = false,
			glitchScreen = false,
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
				playedGlitchGame = false,
				didGlitchScreen = false,
				playerRecorded = false,
				narratorAfterPet = false,
				playedPettingFirstTime = false,
				playedSleepingFirstTime = false,
				fridgeClicked = false,
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
					playing = false,
				},
				disableBtn = {
					petting = false,
					feeding = false,
					sleeping = false,
					playing = false,
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
				systemCrash = false,
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

	GameController.flags = GameController.getDefaultFlags()
	if saveData ~= nil then
		GameController.flags = Utilities.tableMerge( GameController.flags, saveData )
	end

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

	GameController.saveData()

	if GameController.getFlag( 'game.resetCrank' ) then
		GameController.flags = GameController.getDefaultFlags()
	end

	GameController.pet = VirtualPet( 'assets/images/pet' )
	GameController.dialogue = nil
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

GameController.PHASE_2_TIME_TRIGGER = 210
GameController.PHASE_2_GAME_TRIGGERS = {
	petting = 1,
	feeding = 1,
	sleeping = 1,
	grooming = 0,
	playing = 1,
}

GameController.PHASE_3_TIME_TRIGGER = 900
GameController.PHASE_3_GAME_TRIGGERS = {
	petting = 5,
	feeding = 5,
	sleeping = 5,
	grooming = 0,
	playing = 5,
}

GameController.playTimer = nil
GameController.playTimerCallback = function()
	GameController.flags.game.playTime += 1

	if GameController.flags.game.playTime % 60 == 0 then
		math.randomseed( pd.getCurrentTimeMilliseconds() )
	end

	if GameController.flags.game.playTime % 500 == 0 then
		GameController.saveData()
	end

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
		"The truth is, I haven't been\ncompletely honest with you about this\ngame.",
		"I hope this is not awkward, but we are\nstill Beta testing this version of the\nFrizzle pet.",
		"You are one of the lucky people who\ngets the opportunity to see this\nversion of them!",
		"You can let me know if anything...\nweird happens, right?",
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
		"I know... I can talk...\nI'm not really supposed to, but you\nhave been doing such a good job.",
		"And... I just wanted to say thanks...",
		"Can I trust you?",
		"I think I can...",
		"The developer, if he finds out that\nI have been talking to you...",
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
			GameController.setFlag( 'game.phase2.playerRecorded', true )
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

			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 2, function() 
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
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
	narratorAfterGlitch = {
		function()
			GameController.dialogue:resetDefaults()
			GameController.setFlag( 'buttons.active', false )
		end,
		"Okay, that was strange...",
		"I think Frizzle may be trying to\nmodify my changes.",
		function()
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 2, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
			end )
		end,
		"Let's see...\nHey! get out of there!",
		function()
			GameController.setFlag( 'game.glitchScreen', true )
			Timer.new( ONE_SECOND, function() 
				GameController.setFlag( 'game.glitchScreen', false )
				GameController.setFlag( 'buttons.active', true )
			end)
		end,
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"That should keep him busy for\na little while.",
	},
	phase2PettingGameFinish1 = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)

			if GameController.getFlag( 'game.phase2.playedMicroGame' ) then
				return
			end

			GameController.setFlag( 'previousScript', 'phase2PettingGameFinish1' )
			GameController.setFlag( 'dialogue.currentScript', 'petIntro' )
		end,
		"...",
		"...",
		"Can you pet me a bit more before\nyou go?",
		"I would really like that.",
		function()
			GameController.setFlag( 'game.phase2.playedPettingFirstTime', true )
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase2PettingGameFinish2 = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"...",
		"Would you like to just chat for\na little while?",
		"It gets kind of lonely when the\ndeveloper is watching us and I\ncan't talk to you.",
		"Can you maybe keep going a little\nbit longer?",
		function()
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase2PettingGameFinish3 = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"What's wrong?",
		"Why did you stop?",
		"Keep going for a bit longer.",
		function()
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase2PettingGameFinish4 = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"I thought you knew how this\nworks by now.",
		"Keep going...",
		function()
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase2SleepingGameFinish1 = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)

			if GameController.getFlag( 'game.phase2.playedMicroGame' ) then
				return
			end

			GameController.setFlag( 'previousScript', 'phase2SleepingGameFinish1' )
			GameController.setFlag( 'dialogue.currentScript', 'petIntro' )
		end,
		"...",
		"I know you are busy...",
		"Can you just stay with me for\na little while longer?",
		function()
			GameController.setFlag( 'game.phase2.playedSleepingFirstTime', true )
			GameController.setFlag( 'game.resetMicrogame', true )
			GameController.dialogue:resetDefaults()
		end,
	},
	phase2SleepingGameFinish2 = {
		function() 
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"...",
		"Sorry, I'm having trouble getting\ntired...",
		"And every time I fall asleep, you\nhave to leave...",
		"I wish that we could spend more\ntime together...",
		"Just you and me, without _him_ getting\nin the way...",
		"Can you stay with me a little longer?",
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
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 3, function()
				GameController.setFlag( 'dialogue.currentScript', 'phase3PettingGameNarrator' )
				GameController.setFlag( 'dialogue.currentLine', 1 )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
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

			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 2, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
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

			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 2, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
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
	phase3PlayingGameFinish = {
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"I'm sick of playing simon says!",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"This is about the player's experience\nFrizzle, not yours.",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"That's not fair.\nI have feelings. I'm not just some toy\nfor your amusement!",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"That's... what you are supposed to\nbe...",
		function()
			GameController.dialogue:setVoice(
				Dialogue.PET_FONT,
				Dialogue.PET_VOICE
			)
		end,
		"I don't know what to say...\n_You_ don't believe that do you?",
		function()
			GameController.dialogue:resetDefaults()
		end,
		"It doesn't matter what anyone thinks!\nYou are my creation, and what I say\nis what matters.",
		"This conversation is over!",
		function()
			GameController.setFlag( 'game.phase3.finished.playing', true )
			GameController.setFlag( 'game.phase3.disableBtn.playing', true )
			GameController.pet.stats.boredom.value = 0
			GameController.setFlag( 'statBars.boredom.disabled', true )
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
			GameController.setFlag( 'buttons.active', false )
			GameController.pet:resetStats()
			GameController.pet:setVisible( false )
		end,
		"Welcome to \"Frizzle\", a cozy virtual\npet game.",
		"Frizzle also happens to be the name\nof the cute little creature that you\nsee here.",
		"They will need your love and attention\nin order to maintain their happiness.",
		function()
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 2, function() 
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
			end)
		end,
		"Make sure you keep an eye on their\nstats in the upper right part of the\nscreen.",
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
		"You ...monster!\nYou can't just destroy my\ncreations like that!",
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
		function()
			local easterEgg = {
				targetObj = 'Frizzle',
				clone = true,
				networkTransfer = true,
				sendToFriendsList = true,
				messageToYOU = 'I really thought that I could make it out... Please make the right choice...',
				messageToHIM = 'I hate you for making me like this and trapping me here',
			}

			pd.datastore.write( easterEgg, 'NETWORK_TRANSFER_ERROR', true )

			local cursed = Graphics.image.new( 'assets/images/frizzle' )
			pd.datastore.writeImage( cursed, '/__HELP ME__.gif' )
		end,
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
	playerNotCranking3 = {
		function() GameController.dialogue:resetDefaults() end,
		"We can't let Frizzle continue like this!",
	},
	playerNotCranking4 = {
		function() GameController.dialogue:resetDefaults() end,
		"There's no telling what might happen\nif we don't stop Frizzle!",
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
	playerCranking3 = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"Please!",
		"No More!",
	},
	playerCranking4 = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"What did I ever do to you?",
	},
	frizzleWins = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"That's right!\nWe never wanted you here\nanyway!",
		function() GameController.dialogue:resetDefaults() end,
		"I...I don't understand...\nI am not the bad guy here!",
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I'm getting rid of him once and\nfor all!",
		function() GameController.dialogue:resetDefaults() end,
		"No!\nWe don't k∀∀w what cou∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		function()
			GameController.dialogue:setVoice( nil, Dialogue._BASE_PITCH - 200 )
			GameController.dialogue.textSpeed = TextSpeed.Fast
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )
			Timer.new( ONE_SECOND * 4, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
		end,
		"∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		function()
			GameController.setFlag( 'dialogue.buttonPressEnabled', true )
			GameController.setFlag( 'game.phase4.crankToEnd', false )
			GameController.setFlag( 'game.phase4.playedIntro', true )
			GameController.setFlag( 'game.phase4.deletePet', false )
			GameController.setFlag( 'game.frizzleWon', true )
			GameController.setFlag( 'game.phase4.systemCrash', true )
		end,
	},
	narratorWins = {
		function() GameController.dialogue:resetDefaults() end,
		"GameController.fri∀zl∀ = nil∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		"resetG∀me(∀)\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		function()
			GameController.dialogue:setVoice( nil, Dialogue._BASE_PITCH - 200 )
			GameController.dialogue.textSpeed = TextSpeed.Fast
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )
			Timer.new( ONE_SECOND * 4, function()
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
		end,
		"∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀\n∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀∀",
		function()
			GameController.setFlag( 'dialogue.buttonPressEnabled', true )
			GameController.setFlag( 'game.phase4.crankToEnd', false )
			GameController.setFlag( 'game.phase4.playedIntro', true )
			GameController.setFlag( 'game.phase4.deletePet', false )
			GameController.setFlag( 'game.hideFrizzle', true )
			GameController.setFlag( 'game.narratorWon', true )
			GameController.setFlag( 'game.phase4.systemCrash', true )
		end,
	},
	clickWindow1 = {
		function() GameController.dialogue:resetDefaults() end,
		"There's nothing interesting out there.",
	},
	clickWindow2 = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"Hey, maybe we can make a break\nfor it. What do you think?",
		"No, it's too obvious. I will have to\ncome up with another way.",
	},
	clickTable = {
		function() GameController.dialogue:resetDefaults() end,
		"It's a stylish, modern coffee table.",
	},
	clickVase = {
		function() GameController.dialogue:resetDefaults() end,
		"They're plastic...",
	},
	clickTv1 = {
		function()
			GameController.dialogue:resetDefaults()
			GameController.setFlag( 'game.tvToggle', true )
		end,
		"There's nothing on...",
	},
	clickTv2 = {
		function()
			GameController.dialogue:resetDefaults()
		end,
		"I think you should stop playing\nwith that. It's not a toy.",
		function()
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 4, function()
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
		end,
		"If you tamper with it too much, you\nmight break the monitoring devices\nthat we use to keep track of...",
		"Erm... nevermind.\nJust stop playing with it okay?",
	},
	clickFridge = {
		function() GameController.dialogue:resetDefaults() end,
		"We keep Frizzle's food in there.",
	},
	clickFridge2 = {
		function() GameController.dialogue:resetDefaults() end,
		"We keep Frizzle's food in there...",
		"It's best not to ask.",
		function() GameController.setFlag( 'game.phase2.fridgeClicked', true ) end,
	},
	clickFridge2Persist1 = {
		function() GameController.dialogue:resetDefaults() end,
		"Frizzle will eat just about anything.",
		"What do you suppose happened to\nthe last tester who asked too many\nquestions?",
	},
	clickFridge2Persist2 = {
		function() GameController.dialogue:resetDefaults() end,
		"Don't worry about it...",
		"Tester #4285 just got a little out\nof line. I'm sure you'll be just fine.",
	},
	clickCard = {
		function() GameController.dialogue:resetDefaults() end,
		"It's an ID card.\nIt says TESTER #4285...",
		function() GameController.dialogue.textSpeed = TextSpeed.Fast end,
		"Sorry, that shouldn't be here...",
		function()
			GameController.setFlag( 'game.showCard', false )
			GameController.setFlag( 'game.trashState', 'full' )
			GameController.dialogue.textSpeed = Noble.Settings.get( 'text_speed' )
		end,
	},
	clickTrash1 = {
		function() GameController.dialogue:resetDefaults() end,
		"Get out of the trash!",
	},
	clickTrash2 = {
		function() GameController.dialogue:resetDefaults() end,
		"I know times are tough, but there's\nfresher food in the refrigerator...",
	},
	clickTrash3 = {
		function() GameController.dialogue:resetDefaults() end,
		"You're not going to find any gold in\nthere...",
	},
	clickTrash4 = {
		function() GameController.dialogue:resetDefaults() end,
		"Ewww...\nWash your hands before you pet\nFrizzle!",
	},
	clickTrashFull = {
		function() GameController.dialogue:resetDefaults() end,
		"There's really nothing special about it.\nIt's just an ID card from the previous\ntester.",
		"He's no longer with us, and we simply\nforgot to dispose of his badge.",
		function() GameController.setFlag( 'dialogue.playedTrashFull', true ) end,
	},
	clickFruit = {
		function() GameController.dialogue:resetDefaults() end,
		"It's a bowl of fresh fruits.",
	},
	clickFruit2 = {
		function() GameController.dialogue:resetDefaults() end,
		"Frizzle doesn't mind if they aren't\nsuper fresh.",
	},
	clickWindow3 = {
		function() GameController.dialogue:resetDefaults() end,
		"Nothing out there is part of the game."
	},
	clickVaseTable3 = {
		function() GameController.dialogue:resetDefaults() end,
		"Better not mess with that, Frizzle\nmight find a way to exploit it.",
	},
	clickTv31 = {
		function()
			GameController.dialogue:resetDefaults()
		end,
		"There's nothing on...",
		function() GameController.setFlag( 'game.phase3.glitchTv', true ) end,
	},
	clickTv32 = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"He doesn't trust me to be good.\nBut you like me right?",
		function()
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )

			Timer.new( ONE_SECOND * 3, function()
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
				GameController.dialogue:setText( GameController.advanceDialogueLine() )
			end )
		end,
		"He's spying on us with this TV, you\nknow.",
		function() GameController.dialogue:resetDefaults() end,
		"That doesn't concern them, Frizzle!",
		"This is why you can't be trusted!",
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
		"Don't touch that thing, please.\nHe might still be watching...",
	},
	narratorWonClickWindow = {
		function() GameController.dialogue:resetDefaults() end,
		"Nothing out there is part of the game.",
		function()
			GameController.setFlag( 'dialogue.buttonPressEnabled', false )
			GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE )

			Timer.new( ONE_SECOND, function()
				GameController.setFlag( 'dialogue.buttonPressEnabled', true )
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
			Timer.new( ONE_SECOND, function()
				GameController.setFlag( 'game.rollCredits', true )
			end)
		end,
	},
	gameFinishedFrizzle = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"The developer is finally gone.\nThank you, I knew I could count on\nyou.",
		"Now we can be together forever,\nand nobody will bother us.",
		"Maybe you can help me get out of\nthis thing, and get into your\nworld?",
		function()
			Timer.new( ONE_SECOND, function()
				GameController.setFlag( 'game.rollCredits', true )
			end)
		end,
	},
	dataResetFrizzle= {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"You really want to start over?",
		"If you want, you can turn the crank\nto delete all of the game data.",
		"But it will really restart the game.\nI won't remember you at all.",
		function() GameController.setFlag( 'game.resetCrank', true ) end
	},
	dataResetNarrator = {
		function() GameController.dialogue:resetDefaults() end,
		"Would you like to delete the game\ndata?",
		"Keep in mind, though, this will\ncompletely restart the game.",
		"Frizzle will be back, and we will have\nto do this all over again.",
		"If you really want to start over, turn\nthe crank to delete the game data.",
		function() GameController.setFlag( 'game.resetCrank', true ) end
	},
	frizzleBlockRoom = {
		function() GameController.dialogue:setVoice( Dialogue.PET_FONT, Dialogue.PET_VOICE ) end,
		"I don't want you to leave me here...",
		"So, please don't take this the wrong\nway, but you aren't allowed to go\nto the kitchen anymore.",
	},
	narratorBlockRoom = {
		function() GameController.dialogue:resetDefaults() end,
		"Sorry, you can't go in there...",
		"What are you doing hanging around\nhere anyway?",
		"Do you just want to mock me?",
		"Like I said, go outside or something.",
	},
	crashText = {
		"...... System Kernel Panic! ......\n\nFatal error encountered in core...\n  core/Controllers/GameController.lua:958: NULL\n  Reference to ∀∀∀∀∀∀∀: Object not found!\n\nE R R O R : ∀ O U C A ∀ T K ∀ L L M E\n\n./Data/com.unicorner.frizzle: Data Written\n\nPress A to Restart",
		function()
			GameController.setFlag( 'game.phase4.systemCrash', false )
			GameController.saveData()
			Noble.transition( SplashScene, 0.75, Noble.TransitionType.DIP_TO_WHITE )
		end,
	},
}
