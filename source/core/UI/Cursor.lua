Cursor = {}
class( "Cursor" ).extends( NobleSprite )

-- Member variables
Cursor.velocity = {x = 0, y = 0}

-- private variables
local CURSOR_IMAGE_PATH = "assets/images/UI/cursor"

function Cursor:new( startX, startY )

	local cursorImage = Graphics.image.new( CURSOR_IMAGE_PATH )
	self = Cursor.super.new( cursorImage )

	self:moveTo( startX, startY )
	
	self.velocity.x = 0
	self.velocity.y = 0

	return self

end

function Cursor:update()

	Cursor.super.update()
	
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		self:moveBy( self.velocity.x, self.velocity.y )
	end
	
end