---------------------------
-- Use this file for your nodes

--	Node.new({Actor}/'Actor') - Creates a new node
--      {Actor} - OutFox actor table
--      'Actor' - Alternatively, use a type name
--	Node:AttachScript(scriptpath) - Attaches a script to a node
--      scriptpath - Path to Lua script
--      (MUST return a ready function and an update function, update requires 'dt' parameter!)
--	Node:SetReady(func) - Attaches a function to the ready command
--      func - Function to attach
--	Node:SetUpdate(func) - Attaches a function to the update command
--      func - Function to attach (requires 'dt' parameter!)
--	Node:AddToNodeTree() - Adds a node to the node tree
--	Node.GetNodeTree() - Gets the node tree

-- Nodes can be manipulated like normal actors, but most work
-- should be done in a dedicated script to keep space clean.

-- Update functions require a 'dt' parameter, even if you don't plan to use it.

-- Set SRT_STYLE to true to hide overlays and underlays like in common SRT files.

-- Use the ready and update functions in this script for already established actors
-- (like players and other screen elements)
---------------------------

---------------------------
-- Uncomment for example --
---------------------------
--[[
local QuadPad = {}
local PadDirs = {"Left", "Down", "Up", "Right"}
for i = 1, 4 do
	local idx = i
	QuadPad[idx] = Node.new('Quad')
	QuadPad[idx]:SetReady(function(self)
		self:xy(SCX, SCY)
		self:SetWidth(64)
		self:SetHeight(64)
		if idx == 1 then
			self:addx(-64) -- Left
		elseif idx == 2 then
			self:addy(64) -- Down
		elseif idx == 3 then
			self:addy(-64) -- Up
		else
			self:addx(64) -- Right
		end
	end)
	QuadPad[idx]:SetInput(function(self, event)
		if event.button == PadDirs[idx] then
			local col = event.DeviceInput.level
			if event.PlayerNumber == 0 then
				if event.type == 'InputEventType_Release' then
					self:diffuse(1, 1, 1, 1)
				else
					self:diffuse(col, 0, 1 - col, 1)
				end
			end
		end
	end)
	QuadPad[idx]:AddToNodeTree()
end
--]]
---------------------------

-- This centers the player if there's only one
if #PL == 1 then
    CENTER_PLAYERS = true
end
-- This hides the song overlay and underlay like common SRT modfiles do
SRT_STYLE = true

-- Set up nodes here --

-- Modify pre-existing actors here --
function ready()
end

function update(dt)
end

function input(event)
end

return Node.GetNodeTree()
