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

end

function Cursor:update()

	print( "cursor" )
	print( self.velocity )
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		self:moveBy( self.velocity.x * MOVE_SPEED, self.velocity.y * MOVE_SPEED )
	end
	
end