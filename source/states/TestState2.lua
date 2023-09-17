-- General State class to be extended by custom States
TestState2 = {}
class( "TestState2" ).extends( State )

local state = TestState2

function state:new( id )
	
	State.new( self, id )
	return self

end

-- Fires when a State is entered
function state:enter() 
	print( "Enter TestState 2")
end

-- Fires when a State is exited
function state:exit() 
	print( "Exit TestState 2" )
end

-- Fires when the State Machine updates
function state:tick() 
	print( "Tick TestState 2" )
end