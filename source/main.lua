import "bootstrap"

Noble.Settings.setup({
	debug_mode = true,
	text_speed = TextSpeed.Normal
})

Global.pet = nil
Noble.new( TitleScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE )