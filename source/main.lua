import 'libraries/noble/Noble'
import 'utilities/Utilities'

import 'scenes/TitleScene'
import 'scenes/PlayScene'

import "states/State"
import "states/StateMachine"
import "states/TestState"
import "states/TestState2"

Noble.Settings.setup({
	debug_mode = true,
})

Noble.new( TitleScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE )