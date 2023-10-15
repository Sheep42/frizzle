TitleScene = {}
class("TitleScene").extends(NobleScene)
local scene = TitleScene

scene.baseColor = Graphics.kColorBlack

local background
local menu
local sequence
local bgMusic = nil

function scene:init()
	scene.super.init(self)

	background = Graphics.image.new( "assets/images/background2" )
	bgMusic = Sound.fileplayer.new( "assets/sound/title2.mp3" )

	menu = Noble.Menu.new( false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4,6,0, Noble.Text.FONT_SMALL )
	menu:addItem( 
		"Play", 
		function() 
			Noble.transition(PlayScene, 1, Noble.TransitionType.DIP_TO_BLACK) 
		end
	)
	menu:addItem( 
		"set_text_speed", 
		function() 
			local oldValue = Noble.Settings.get( "text_speed" )
			local oldKey = Utilities.findKeyByValue( TextSpeed, oldValue )
			
			local newValue = math.ringInt( oldValue + 1, 1, 3 ) 
			local newKey = Utilities.findKeyByValue( TextSpeed, newValue )
			Noble.Settings.set( "text_speed", newValue )

			menu:setItemDisplayName( "set_text_speed", "Text Speed: " .. Utilities.findKeyByValue( TextSpeed, Noble.Settings.get( "text_speed" ) ) )
		end,
		nil,
		"Text Speed: " .. Utilities.findKeyByValue( TextSpeed, Noble.Settings.get( "text_speed" ) )
	)
	menu:addItem( 
		"enable_debug_mode", 
		function() 
			local oldValue = Noble.Settings.get( "debug_mode" )
			local newValue = not oldValue
			Noble.Settings.set( "debug_mode", newValue )
			menu:setItemDisplayName( "enable_debug_mode", "Enable Debug Mode: " .. tostring( Noble.Settings.get( "debug_mode" ) ) )
		end,
		nil,
		"Enable Debug Mode: " .. tostring( Noble.Settings.get( "debug_mode" ) )
	)

	local crankTick = 0

	scene.inputHandler = {
		upButtonDown = function()
			menu:selectPrevious()
		end,
		downButtonDown = function()
			menu:selectNext()
		end,
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			if (crankTick > 30) then
				crankTick = 0
				menu:selectNext()
			elseif (crankTick < -30) then
				crankTick = 0
				menu:selectPrevious()
			end
		end,
		AButtonDown = function()
			menu:click()
		end
	}

end

function scene:enter()
	scene.super.enter(self)

	sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
	sequence:start();
end

function scene:start()
	scene.super.start(self)

	menu:activate()
	Noble.Input.setCrankIndicatorStatus(true)
end

function scene:drawBackground()
	scene.super.drawBackground(self)

	background:draw(0, 0)
	bgMusic:play( 0 )
end

function scene:update()

	scene.super.update(self)

	Graphics.setColor(Graphics.kColorWhite)
	Graphics.setDitherPattern(0.2, Graphics.image.kDitherTypeScreen)
	Graphics.fillRoundRect(15, (sequence:get()*0.75)+3, 185, 145, 15)
	menu:draw(30, sequence:get()-15 or 100-15)

	Graphics.setColor(Graphics.kColorBlack)
	
	Noble.showFPS = Noble.Settings.get( "debug_mode" )

end

function scene:exit()
	scene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	bgMusic:stop()
	sequence:start();

end

function scene:finish()
	scene.super.finish(self)
end