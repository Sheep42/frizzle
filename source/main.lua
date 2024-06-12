import "bootstrap"

Noble.Settings.setup({
	debug_mode = false,
	text_speed = TextSpeed.Normal
})

local menu = playdate.getSystemMenu()

local menuItem, error = menu:addMenuItem( "back to title", function()
    GameController.saveData()
    Noble.transition( TitleScene )
end)

Noble.new( SplashScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE )