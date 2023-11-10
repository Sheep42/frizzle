-- Imports
import 'libraries/noble/Noble'
import 'utilities/Utilities'

import 'core/scenes/TitleScene'
import 'core/scenes/PlayScene'

import "core/states/State"
import "core/states/StateMachine"
import "core/states/TestState"
import "core/states/TestState2"

import "core/UI/Cursor"
import "core/UI/Button"
import "core/dialogue/Dialogue"

import "core/entities/VirtualPet/VirtualPet"
import "core/entities/VirtualPet/PetState_Active"

-- Globals
pd = playdate
Sound = pd.sound

-- Generic Setup
local s, ms = pd.getSecondsSinceEpoch()
math.randomseed( ms, s )