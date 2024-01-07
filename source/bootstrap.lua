-- Imports
import 'libraries/noble/Noble'
import 'utilities/Utilities'

import 'core/scenes/TitleScene'
import 'core/scenes/PlayScene'
import 'core/scenes/microgames/Microgame'
import 'core/scenes/microgames/Petting/Petting_CrankGame'
import 'core/scenes/microgames/Petting/Petting_ShakeGame'
import 'core/scenes/microgames/Feeding/Feeding_ShakeGame'

import "core/states/State"
import "core/states/StateMachine"

import "core/UI/Cursor"
import "core/UI/Button"
import "core/UI/StatBar/StatBarState_Active"
import "core/UI/StatBar/StatBarState_Paused"
import "core/UI/StatBar"
import "core/dialogue/Dialogue"

import "core/entities/VirtualPet/PetState_Active"
import "core/entities/VirtualPet/PetState_Paused"
import "core/entities/VirtualPet/VirtualPet"

import 'core/controllers/GameController'

-- Globals
pd = playdate
Sound = pd.sound

-- Generic Setup
local s, ms = pd.getSecondsSinceEpoch()
math.randomseed( ms, s )