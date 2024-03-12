StateMachine = {}
class( "StateMachine" ).extends()

-- Create a new StateMachine
--
-- @param State defaultState The State to set as defualt for this StateMachine
--
-- @param Array<State> states A list of States to register for this StateMachine
function StateMachine:init( defaultState, states )

	-- Member Variables
		self.currentState = nil
		self.defaultState = nil
		self.previousState = nil
		self.states = {}

	-- Param Overrides
		if defaultState == nil then
			error( "StateMachine requires a defaultState" )
		end

	-- Set up defaultState and run enter
		self.currentState = defaultState
		self.defaultState = defaultState
		self.currentState:enter()

	-- Add defualt state to states list
		self:addState( defaultState )

	-- Add other states, if provided
		if states ~= nil then
			if type( states ) == "table" then

				for _, state in pairs( states ) do
					self:addState( state )
				end

			end
		end

end

-- Update the StateMachine - You should call this from your Game loop or Scene update function
function StateMachine:update()

	-- Run currentState tick function
	self.currentState:tick()

end

-- Add a State to the list of States
--
-- @param State state The State to add to the list - States must have an id, or they 
-- will be skipped
function StateMachine:addState( state )
	
	if state.id == nil then
		print( "WARNING: 'addState()' - State without id, skipping...")
		return
	end

	state:setStateMachine( self )
	self.states[state.id] = state

end

-- Get a State out of the StateMachine, by its ID
--
-- @return State/nil The state with the specified ID - nil if not found
function StateMachine:getState( stateId )
	return self.states[stateId]
end

-- Get the current running State from this StateMachine
--
-- @return State The current running State
function StateMachine:currentState()
	return self.currentState
end

-- Change the current State to Another
--
-- @param State state The state to change to
function StateMachine:changeState( state )

	-- Run the Exit function on the current state
	self.currentState:exit()

	-- Track current state as previous state
	self.previousState = self.currentState

	-- Set new State and run enter
	self.currentState = state
	self.currentState:enter()
	
end

function StateMachine:changeStateById( stateId )
	
	local state = self:getState( stateId )
	if state == nil then
		error( "Attempting to change to nil State" )
	end

	self:changeState( state )

end

-- Change to the cached previous State
function StateMachine:changeToPrevious()
	self:changeState( self.previousState )
end

-- Change to the default state for this StateMachine
function StateMachine:changeToDefault()
	self:changeState( self.defaultState )
end

