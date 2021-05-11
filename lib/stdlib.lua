-- environment builder stolen this from xero thanks xero
local sudo = setmetatable(sudo, sudo)
sudo.__index = _G
local function nop() end
function sudo:__call(f, name)
	if type(f) == 'string' then
		-- if we call sudo with a string, we need to load it as code
		local err
		-- try compiling the code
		f, err = loadstring( 'return function(self)' .. f .. '\nend', name)
		if err then SCREENMAN:SystemMessage(err) return nop end
		-- grab the function
		f, err = pcall(f)
		if err then SCREENMAN:SystemMessage(err) return nop end
	end
	-- set environment
	setfenv(f or 2, self)
	return f
end

sudo()

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- First set of global variables
printerr = Trace

SW, SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
SCX, SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

TICKRATE = 60 -- tickrate
TICK = 1 / TICKRATE -- seconds since last tick
CONST_TICK = false -- set this to true for automagic frame limiting!!!! o A o

DT = 0 -- seconds since last frame
BEAT = GAMESTATE:GetSongBeat() -- current beat
BPS = GAMESTATE:GetCurBPS() -- current beats per second
BPM = BPS * 60 -- beats per minute
BPT = TICK * BPS -- beats per tick
SPB = 1 / BPS -- seconds per beat
TPB = SPB * TICKRATE -- ticks per beat
CENTER_PLAYERS = false
SRT_STYLE = false

Node = assert(loadfile('lib/nodebuilder.lua'))() -- Nodebuilder
Mods = assert(loadfile('lib/modsbuilder.lua'))() -- Modsbuilder
Tweens = assert(loadfile('lib/ease.lua'))() -- Eases

Settings = assert(loadfile('lua/settings.lua'))() -- Settings

-- corope.lua needs to be ported for Lua 5.0 before being enabled for NotITG. ~Sudo
--[[
local Corope = assert(loadfile('lib/corope.lua'))() -- Corope
Async = Corope({errhand = printerr})
--]]

PL = {}

event = {
	button = nil,
	type = nil,
	PlayerNumber = nil,
	controller = nil,
	DeviceInput = {
		level = 0,
	}
}
notes = {
	Left = nil,
	Down = nil,
	Up = nil,
	Right = nil
}

return Def.ActorFrame {
	BeginFrameCommand = function(self)
		TICK = 1 / TICKRATE
		if CONST_TICK then
			DT = TICK
		else
			DT = self:GetEffectDelta()
		end
		BEAT = GAMESTATE:GetSongBeat()
		BPS = GAMESTATE:GetCurBPS()
		BPM = BPS * 60
		BPT = TICK * BPS
		SPB = 1 / BPS
		TPB = SPB * TICKRATE
		MESSAGEMAN:Broadcast('Update')
	end,
	UpdateMessageCommand = function(self)
		--Async:update(DT)
		if sudo.update then
			sudo.update(DT)
		end
		self:queuecommand('EndFrame')
	end,
	EndFrameCommand = function(self)
		self:sleep(DT)
		self:queuecommand('BeginFrame')
	end,
	ReadyCommand = function(self)
		-- Second set of global variables
		SCREEN = SCREENMAN:GetTopScreen() -- top screen
		for i = 1, GAMESTATE:GetNumPlayersEnabled() do
			local info = {}

			local pl = SCREEN:GetChild('PlayerP'..i)
			if pl then
				info.Player = pl
				info.Combo = pl:GetChild('Combo')
				info.Judgment = pl:GetChild('Judgment')
				info.NoteField = pl:GetChild('NoteField')
				PL[i] = info
			end
		end
		--P1, P2 = SCREEN:GetChild('PlayerP1') or nil, SCREEN:GetChild('PlayerP2') or nil -- player 1 and 2
		--L1, L2 = SCREEN:GetChild('LifeP1') or nil, SCREEN:GetChild('LifeP2') or nil -- life 1 and 2
		--S1, S2 = SCREEN:GetChild('ScoreP1') or nil, SCREEN:GetChild('ScoreP2') or nil -- life 1 and 2
		--C1, C2 = PL[1]:GetChild('Combo') or nil, PL[2]:GetChild('Combo') or nil -- combo 1 and 2
		--J1, J2 = PL[1]:GetChild('Judgment') or nil, PL[2]:GetChild('Judgment') or nil -- judgment 1 and 2
		--N1, N2 = PL[1]:GetChild('NoteField') or nil, PL[2]:GetChild('NoteField') or nil -- notefield 1 and 2
		PL = setmetatable(PL, {
			__index = function(this, number)
				if number < 1 or number > #this then
					printerr( string.format('[PL] No player was found on index %i, using first item instead.', number) )
					return this[1]
				end
				return this
			end
		})
		if sudo.ready then
			sudo.ready()
		end
		if CENTER_PLAYERS then
			for pn = 1, #PL do
				PL[pn].Player:x(SCX)
			end
		end
		if SRT_STYLE then
			for i = 1, #PL do
				SCREEN:GetChild('LifeP'..i):hidden(1)
				SCREEN:GetChild('ScoreP'..i):hidden(1)
			end
			SCREEN:GetChild('Overlay'):hidden(1)
		end
		self:queuecommand('BeginFrame')
	end,
	StepP1LeftPressMessageCommand = function(self)
		event.button = 'Left'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1DownPressMessageCommand = function(self)
		event.button = 'Down'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1UpPressMessageCommand = function(self)
		event.button = 'Up'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1RightPressMessageCommand = function(self)
		event.button = 'Right'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1LeftLiftMessageCommand = function(self)
		event.button = 'Left'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1DownLiftMessageCommand = function(self)
		event.button = 'Down'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1UpLiftMessageCommand = function(self)
		event.button = 'Up'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1RightLiftMessageCommand = function(self)
		event.button = 'Right'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2LeftPressMessageCommand = function(self)
		event.button = 'Left'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2DownPressMessageCommand = function(self)
		event.button = 'Down'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2UpPressMessageCommand = function(self)
		event.button = 'Up'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2RightPressMessageCommand = function(self)
		event.button = 'Right'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2LeftLiftMessageCommand = function(self)
		event.button = 'Left'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2DownLiftMessageCommand = function(self)
		event.button = 'Down'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2UpLiftMessageCommand = function(self)
		event.button = 'Up'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2RightLiftMessageCommand = function(self)
		event.button = 'Right'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1StartPressMessageCommand = function(self)
		event.button = 'Start'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1BackPressMessageCommand = function(self)
		event.button = 'Back'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1StartLiftMessageCommand = function(self)
		event.button = 'Start'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP1BackLiftMessageCommand = function(self)
		event.button = 'Back'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 0
		event.controller = 'GameController_1'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2StartPressMessageCommand = function(self)
		event.button = 'Start'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2BackPressMessageCommand = function(self)
		event.button = 'Back'
		event.type = 'InputEventType_FirstPress'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2StartLiftMessageCommand = function(self)
		event.button = 'Start'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	StepP2BackLiftMessageCommand = function(self)
		event.button = 'Back'
		event.type = 'InputEventType_Release'
		event.PlayerNumber = 1
		event.controller = 'GameController_2'
		event.DeviceInput.level = 1
		MESSAGEMAN:Broadcast('Input')
	end,
	MidiInMessageCommand = function(self)
		local player
		local column = midi_controlnum
		for k, v in pairs(Settings.MidiInput) do
			if column == v.Left then
				player = tonumber(string.sub(k, 2))
				event.button = 'Left'
			elseif column == v.Down then
				player = tonumber(string.sub(k, 2))
				event.button = 'Down'
			elseif column == v.Up then
				player = tonumber(string.sub(k, 2))
				event.button = 'Up'
			elseif column == v.Right then
				player = tonumber(string.sub(k, 2))
				event.button = 'Right'
			end
			if player then
				event.PlayerNumber = player - 1
				event.controller = 'GameController_'..player
				if midi_type == v.Press then
					--[[
					notes[event.button] = PL[player].Player:GetNoteData(BEAT - 0.1, BEAT + 0.1)
					PL[player].Player:RealStep(column)
					--]]
					event.type = 'InputEventType_FirstPress'
				elseif midi_type == v.Hold then
					event.type = 'InputEventType_Repeat'
					--[[
					if notes[event.button] and notes[event.button][1][2] == column and notes[event.button][1][3] == 2 then
						PL[player].Player:RealStep(column)
						PL[player].Player:DidHoldNote(column)
					end
					--]]
				elseif midi_type == v.Release then
					event.type = 'InputEventType_Release'
				end
				event.DeviceInput.level = math.max(math.min((midi_value / v.MaxLevel), 1), 0)
			end
		end
		local str = midi_type..' | '..midi_controlnum..' | '..midi_value
		--Trace(str)
		MESSAGEMAN:Broadcast('Input')
	end,
	InputMessageCommand = function(self)
		if sudo.input then sudo.input(event) end
	end
}
