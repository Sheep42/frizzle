VirtualPet = {}
class( "VirtualPet" ).extends( NobleSprite )

local pet = VirtualPet

function pet:init( __spritesheet )

	-- TODO: Handle animations
	pet.super.init( self, __spritesheet )

end

function pet:update()

	pet.super.update( self )

end