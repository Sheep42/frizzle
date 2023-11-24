Cursor = {}
class( "Cursor" ).extends( NobleSprite )

-- Constants
	Cursor._CURSOR_IMAGE_PATH = "assets/images/UI/cursor"
	Cursor._MOVE_SPEED = 4

function Cursor:init()

	-- Member variables
		self.velocity = { x = 0, y = 0 }

	-- Super
		Cursor.super.init( self, Cursor._CURSOR_IMAGE_PATH )
	
	-- Set high Z Index
		self:setZIndex( 999 )

	-- Set up collisions
		self:setCollideRect( 0, 0, self:getSize() )
		self:setGroups( { Utilities.collisionGroups.cursor } )
		self:setCollidesWithGroups( {
			Utilities.collisionGroups.uiButtons,
		} )

		GameController.cursor = self 

end

function Cursor:update()
	Cursor.super.update( self )
	self:move()
end

function Cursor:move()

	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then

		-- Contain cursor to screenBounds
			local currX, currY = self:getPosition()
			
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
			self:moveBy( self.velocity.x * Cursor._MOVE_SPEED, self.velocity.y * Cursor._MOVE_SPEED )

	end

end