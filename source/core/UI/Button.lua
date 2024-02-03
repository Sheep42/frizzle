Button = {}
class( "Button" ).extends( NobleSprite )

-- Create a Button 
-- 
-- @param string __spritesheet The path to the button's spritesheet
--
-- @param int __frameDuration Optional override for Noble.Animation frameDuration value
--
-- @return A new Button animation
--
-- All UI Buttons must have a 32x32 spritesheet with a single animation. 
-- Spritesheets must follow the naming convention: sheetname-32-32.png. 
-- When passing in __spritesheet pass in only path/to/sheetname
function Button:init( __spritesheet, __frameDuration )

	-- Member Variables
		self._isActive = true
		self._isHovered = false

	-- Create dispatch callbacks
		self.pressedCallback = function()
			return
		end
		
		self.hoverCallback = function()
			return
		end
		
		self.hoverOutCallback = function()
			return
		end
		
		self.onActivateeCallback = function ()
			return
		end
		
		self.onDeactivateCallback = function ()
			return
		end

	-- Param Overrides
		local frameDuration = 15
		local anim = Noble.Animation.new( __spritesheet )
		local frames, _ = anim.imageTable:getSize()

		if __frameDuration then
			frameDuration = __frameDuration
		end

	-- Set up animation
		anim:addState( "default", 1, 1 )
		anim:addState( "hover", 1, frames, nil, nil, nil, frameDuration )

		anim:setState( "default" )

	-- Create Base NobleSprite
		Button.super.init( self, anim )
		self:setSize( 32, 32 )

	-- Register collision groups
		self:setGroups( { Utilities.collisionGroups.uiButtons } )
		self:setCollidesWithGroups( { Utilities.collisionGroups.cursor } )

end

function Button:add( x, y )
	
	Button.super.add( self, x, y )

	-- Set up collision
	self:setCollideRect( 0, 0, self:getSize() )

end

function Button:setPressedCallback( callback )
	self.pressedCallback = callback
end

function Button:setHoverCallback( callback )
	self.hoverCallback = callback
end

function Button:press( ... )

	if self._isHovered then
		self.pressedCallback( ... )
	end

end

function Button:hover( ... )
	self._isHovered = true
	self.animation:setState( "hover" )
	self.hoverCallback( ... )
end

function Button:hoverOut( ... )
	self._isHovered = false
	self.animation:setState( "default" )
	self.hoverOutCallback( ... )
end

function Button:update() 

	Button.super.update( self )

	if not self._isActive or not GameController.getFlag( 'buttons.active' ) then
		self._isHovered = false
		self.animation:setState( 'default' )
		return
	end

	-- Handle hovering & pressing
	local collisions = self:overlappingSprites()
	if #collisions > 0 then
		self:hover()
	elseif self._isHovered then
		self:hoverOut()
	end

end

function Button:activate()
	self._isActive = true
	self:onActivateeCallback()
end

function Button:deactivate()
	self._isActive = false
	self:hoverOut()
	self:onDeactivateCallback()
end

function Button.getDimensions()
	return { width = 32, height = 32 }
end

function Button.getPadding()
	return 20
end