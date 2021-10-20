-- stdlib.lua --

local std = {}
setmetatable(std, {})

std.VERSION = '1.2'

-- Standard library variables, mostly shortcuts
--[[
	i personally dont like calling gamestate every frame even if it doesnt have
	*any* impact in performance, not calling gamestate is just engraved in my
	head now because of outfox

	NOTE: calling std.POS is not a fast alternative to calling GAMESTATE, it is
	pretty much the exact same thing in this case
--]]
std.POS = GAMESTATE
std.DIR = GAMESTATE:GetCurrentSong():GetSongDir()

std.SW, std.SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
std.SCX, std.SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

std.DT = 0 -- time since last frame in seconds

std.BEAT = std.POS:GetSongBeat() -- current beat
std.BPS = std.POS:GetCurBPS() -- current beats per second
std.BPM = std.BPS * 60 -- beats per minute
std.SPB = 1 / std.BPS -- seconds per beat
std.PL = {}

-- Change this to match FG changes.
std.MOD_START = -10

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


-- yunky.
local InputCMD = {}
for pn = 1, 2 do
	for _, btn in {'Left', 'Down', 'Up', 'Right', 'Start', 'Back'} do
		for _, state in {'Press', 'Lift'} do
			local pn = pn
			local btn = btn
			local state = state
			InputCMD['StepP'..pn..btn..state..'MessageCommand'] = function(self)
				event.button = btn
				event.type = (state == 'Press' and 'InputEventType_FirstPress') or 'InputEventType_Release'
				event.PlayerNumber = pn
				event.controller = 'GameController_'..pn
				event.DeviceInput.level = 1
				if sudo.input then
					sudo.input(event)
				end
				MESSAGEMAN:Broadcast('Input')
			end
		end
	end
end

-- Our foreground to put everything in. If FG is not set, this will take its place.
if FG.stdlib then
	--print('We have stdlib already, loading mini-actor instead')
	FG[#FG + 1] = Def.ActorFrame {
		ReadyCommand = function(self)
			std.SCREEN = SCREENMAN:GetTopScreen()
			for i = 1, GAMESTATE:GetNumPlayersEnabled() do
				local info = {}
				local pl = std.SCREEN:GetChild('PlayerP'..i)
				info.Player = pl
				info.Life = std.SCREEN:GetChild('LifeP'..i)
				info.Score = std.SCREEN:GetChild('ScoreP'..i)
				info.Combo = pl:GetChild('Combo')
				info.Judgment = pl:GetChild('Judgment')
				info.NoteField = pl:GetChild('NoteField')
				info.Proxy = nil
				info.NoteData = pl:GetNoteData()
				std.PL[i] = info
			end
			std.PL = setmetatable(std.PL, {
				__index = function(this, number)
					if number < 1 or number > #this then
						print( string.format("[PL] No player was found on index %i, using first item instead.", number) )
						return this[1]
					end
					return this
				end
			})
		end,
		UpdateCommand = function(self)
			std.BEAT = std.POS:GetSongBeat() -- current beat
			std.BPS = std.POS:GetCurBPS() -- current beats per second
			std.BPM = std.BPS * 60 -- beats per minute
			std.SPB = 1 / std.BPS -- seconds per beat
			std.DT = self:GetEffectDelta() -- time since last frame in seconds
		end,
	}
else
	FG.stdlib = true
	FG[#FG + 1] = Def.ActorFrame {
		Name = 'stdlib',
		InitCommand = function(self)
			if sudo.init then
				sudo.init()
			end
		end,
		ReadyCommand = function(self)
			std.SCREEN = SCREENMAN:GetTopScreen()
			for i = 1, GAMESTATE:GetNumPlayersEnabled() do
				local info = {}
				local pl = std.SCREEN:GetChild('PlayerP'..i)
				info.Player = pl
				info.Life = std.SCREEN:GetChild('LifeP'..i)
				info.Score = std.SCREEN:GetChild('ScoreP'..i)
				info.Combo = pl:GetChild('Combo')
				info.Judgment = pl:GetChild('Judgment')
				info.NoteField = pl:GetChild('NoteField')
				info.Proxy = nil
				info.NoteData = pl:GetNoteData()
				std.PL[i] = info
			end
			std.PL = setmetatable(std.PL, {
				__index = function(this, number)
					if number < 1 or number > #this then
						print( string.format("[PL] No player was found on index %i, using first item instead.", number) )
						return this[1]
					end
					return this
				end
			})
		end,
		StartCommand = function(self)
			-- We need new values for these, since before init give bad values.
			std.BEAT = std.POS:GetSongBeat()
			std.BPS = std.POS:GetCurBPS()
			std.BPM = std.BPS * 60
			std.SPB = 1 / std.BPS
			std.DT = self:GetEffectDelta()
			if sudo.ready then
				sudo.ready()
			end
			if sudo.draw then
				self:SetDrawFunction(sudo.draw)
			end
		end,
		Def.Actor(InputCMD),
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
					-- For now, it's up to the player to map their MIDI controller. ~Sudo
					if midi_type == v.Press then
						event.type = 'InputEventType_FirstPress'
						--[[
						-- This has a chance to crash the game. Don't use this until it's fixed. ~Sudo
						if BEAT > 0 then
							std.PL[player].Player:RealStep(column) 
						end
						--]]
					elseif midi_type == v.Hold then
						event.type = 'InputEventType_Repeat'
					elseif midi_type == v.Release then
						event.type = 'InputEventType_Release'
					end
					event.DeviceInput.level = math.max(math.min((midi_value / v.MaxLevel), 1), 0)
				end
			end
			local str = midi_type..' | '..midi_controlnum..' | '..midi_value
			--print(str)
			if sudo.input then
				sudo.input(event)
			end
			MESSAGEMAN:Broadcast('Input')
		end,
		UpdateCommand = function(self)
			std.BEAT = std.POS:GetSongBeat() -- current beat
			std.BPS = std.POS:GetCurBPS() -- current beats per second
			std.BPM = std.BPS * 60 -- beats per minute
			std.SPB = 1 / std.BPS -- seconds per beat
			std.DT = self:GetEffectDelta() -- time since last frame in seconds
			if sudo.update then
				sudo.update(std.DT)
			end
		end,
	}
	print('Loaded Kitsu Standard Library v'..std.VERSION)
end


function std.aftmult(a)
	return a * 0.9
end

function std.InitAFT(aft, recursive)
	if not recursive then
		aft:SetSize(std.SW, std.SH)
		aft:EnableFloat(false)
		aft:EnableDepthBuffer(false)
		aft:EnableAlphaBuffer(false)
		aft:EnablePreserveTexture(false)
		aft:Create()
	else
		aft:SetSize(std.SW, std.SH)
		aft:EnableFloat(false)
		aft:EnableDepthBuffer(false)
		aft:EnableAlphaBuffer(true)
		aft:EnablePreserveTexture(true)
		aft:Create()
	end
end

function std.MapAFT(aft, sprite)
	sprite:xy(std.SCX, std.SCY)
	sprite:SetTexture(aft:GetTexture())
end

function std.ProxyPlayer(proxy, pn)
	local pn_str = 'P'..pn
	local plr = SCREENMAN:GetTopScreen():GetChild('Player'..pn_str)
	if not plr then
		printerr('Unable to find Player'..pn_str..'.')
		return
	end
	proxy:SetTarget(plr)
	plr:visible(0)
	std.PL[pn].ProxyP = proxy
end

function std.ProxyJudgment(proxy, pn)
	local pn_str = 'P'..pn
	local plr = SCREENMAN:GetTopScreen():GetChild('Player'..pn_str)
	if not plr then
		printerr('Unable to find Player'..pn_str..'.')
		return
	end
	proxy:SetTarget(plr:GetChild('Judgment'))
	proxy:xy(plr:GetX(), std.SCY)
	proxy:zoom(THEME:GetMetric('Common', 'ScreenHeight') / 720)
	plr:GetChild('Judgment'):visible(0)
	plr:GetChild('Judgment'):sleep(9e9)
	std.PL[pn].ProxyJ = proxy
end

function std.ProxyCombo(proxy, pn)
	local pn_str = 'P'..pn
	local plr = SCREENMAN:GetTopScreen():GetChild('Player'..pn_str)
	if not plr then
		printerr('Unable to find Player'..pn_str..'.')
		return
	end
	proxy:SetTarget(plr:GetChild('Combo'))
	proxy:xy(plr:GetX(), std.SCY)
	proxy:zoom(THEME:GetMetric('Common', 'ScreenHeight') / 720)
	plr:GetChild('Combo'):visible(0)
	plr:GetChild('Combo'):sleep(9e9)
	std.PL[pn].ProxyC = proxy
end


std.__index = std

return std
