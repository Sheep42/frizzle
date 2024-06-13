import "bootstrap"

Noble.Settings.setup({
	debug_mode = false,
	text_speed = TextSpeed.Normal
})

imageUnflipped = 0
imageFlippedX = 1
imageFlippedY = 2

local menu = playdate.getSystemMenu()

local menuItem, error = menu:addMenuItem( "back to title", function()
    GameController.saveData()
    Noble.transition( TitleScene )
end)

Noble.new( SplashScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE )