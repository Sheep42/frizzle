Cursor = {}
class( "Cursor" ).extends( NobleSprite )

-- Member variables
Cursor.velocity = {x = 0, y = 0}

-- private variables
local CURSOR_IMAGE_PATH = "assets/images/UI/cursor"
local MOVE_SPEED = 4

function Cursor:init()

	Cursor.super.init( self, CURSOR_IMAGE_PATH )
	
	self.velocity = {x = 0, y = 0}
	self:setZIndex( 999 )

	-- Set up collisions
	self:setCollideRect( 0, 0, self:getSize() )
	self:setGroups( { Utilities.collisionGroups.cursor } )
	self:setCollidesWithGroups( {
		Utilities.collisionGroups.uiButtons,
	} )

end

function Cursor:update()
	Cursor.super.update( self )
	self:move()
end

function Cursor:move()

	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then

		-- Contain cursor to screenBounds
			currX, currY = self:getPosition()
			
			if self.velocity.x < 0 and currX <= Utilities.screenBounds().left then
				self.velocity.x = 0
				self:moveTo( Utilities.screenBounds().left, currY )	
			end 

			if self.velocity.x > 0 and currX >= Utilities.screenBounds().right then
				self.velocity.x = 0
				self:moveTo( Utilities.screenBounds().right, currY )
			end

			if self.velocity.y < 0 and currY <= Utilities.screenBounds().top then
				self.velocity.y = 0
				self:moveTo( currX, Utilities.screenBounds().top )	
			end 

			if self.velocity.y > 0 and currY >= Utilities.screenBounds().bottom then
				self.velocity.y = 0
				self:moveTo( currX, Utilities.screenBounds().bottom )
			end

		-- Move cursor
			self:moveBy( self.velocity.x * MOVE_SPEED, self.velocity.y * MOVE_SPEED )

	end

end