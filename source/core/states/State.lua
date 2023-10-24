-- General State class to be extended by custom States
State = {}
class( "State" ).extends()

-- State identifier
State.id = ""
State.stateMachine = nil
State.owner = nil -- The owner object

-- Constructor
--
-- @param String id The state ID - Should be unique
function State:init( id )

	if id == nil then
		error( "State must have an ID" )
	end

	self.id = id

	return self

end

function State:setStateMachine( stateMachine )
	self.stateMachine = stateMachine
end

-- Fires when a State is entered
function State:enter() end

-- Fires when a State is exited
function State:exit() end

-- Fires when the State Machine updates
function State:tick() end