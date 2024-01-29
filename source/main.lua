import "bootstrap"

Noble.Settings.setup({
	debug_mode = true,
	text_speed = TextSpeed.Normal
})

Noble.new( SplashScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE )