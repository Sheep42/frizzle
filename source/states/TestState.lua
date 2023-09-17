-- General State class to be extended by custom States
TestState = {}
class( "TestState" ).extends( State )

local state = TestState

function state:new( id )
	
	State.new( self, id )
	return self

end

-- Fires when a State is entered
function state:enter() 
	print( "Enter TestState")
end

-- Fires when a State is exited
function state:exit() 
	print( "Exit TestState" )
end

-- Fires when the State Machine updates
function state:tick() 
	print( "Tick TestState" )
end