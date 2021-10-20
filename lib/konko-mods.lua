-- konko-mods.lua --

---------------------------
--	Mods:Insert(start, len, ease, modpairs, [offset], [plr]) - Writes mods to branch
--      start - Starting time
--      len - Length to full percentage
--      ease - Ease function
--      modpairs - {{end_p, mod, [begin_p]}, ...}
--          end_p - Ending percent
--          mod - Mod to activate (MUST be written in PascalCase)
--          begin_p - Beginning percent (optional)
--      offset - Offset between each mod in modpairs (optional)
--      plr - Player to apply mods (optional)
--	Mods:Define(name, func, return) - Defines a new mod from a function
--	Mods:FromFile(path) - Reads mods from a separate file
--	Mods:Mirin({start, len, ease, perc, mod, ...}, [offset], [plr]) - Writes mods to branch Mirin style
--	Mods:Exsch(start, len, begin_p, end_p, mod, timing, ease, [offset], [plr]) - Write mods to branch Exschwasion style
--	Mods:Default(modpairs) - Writes default mods to branch
---------------------------
local std = import 'stdlib'

local Mods = {}
setmetatable(Mods, {})

local modlist = {}
local mod_percents = {}
local note_percents = {}
local custom_mods = {}
local default_mods = {}
local active = {}

local plr_count = GAMESTATE:GetNumPlayersEnabled()

for pn = 1, plr_count do
	mod_percents[pn] = {}
	note_percents[pn] = {}
	custom_mods[pn] = {}
	default_mods[pn] = {}
	active[pn] = {}
end
local function ApplyMods()
	for pn = 1, plr_count do
		local modstring = ''
		for mod, percent in pairs(mod_percents[pn]) do
			if custom_mods[pn][mod] ~= nil then
				local new_perc = custom_mods[pn][mod].Function(percent, pn)
				local new_mod = custom_mods[pn][mod].Return
				percent = new_perc
				mod = new_mod
			end
			if mod then
				-- TODO: Fix mod ease calculations so percentage doesn't end up backwards
				if string.lower(string.sub(mod, 2)) == 'mod' then
					modstring = modstring..'*-1 '..percent..string.lower(string.sub(mod, 1, 1))..','
				else
					modstring = modstring..'*-1 '..percent..' '..string.lower(mod)..','
				end
			end
		end
		if modstring ~= '' then GAMESTATE:ApplyModifiers(modstring, pn) end
	end
end

local function UpdateMods()
    for i, m in ipairs(modlist) do
		for j, v in ipairs(m.Modifiers) do
			-- If the player where we're trying to access is not available, then don't even update.
			if m.Player and not std.PL[m.Player].Player then break end
			local BEAT = std.BEAT
			local pn = m.Player
			if (BEAT >= m.Start and BEAT < (m.Start + m.Length)) then
				if m.Type == 'WIP' then
					-- Ease blending is a work in progress. Try to make sure two eases don't use the same mod.
					v[3] = v[3] or mod_percents[pn][v[2]] or 0
					active[pn][v[2]] = active[pn][v[2]] or {}
					v[4] = v[4] or (#active[pn][v[2]] + 1)
					active[pn][v[2]][v[4]] = m
					local perc = 0
					for n = 1, v[4] do
						local offset = (n > v[4]) and 1 or 0
						local cur_m = active[pn][v[2]][n]
						local cur_v1 = cur_m.Modifiers[j][1]
						local cur_v3 = cur_m.Modifiers[j][3]
						local cur_ease = cur_m.Ease((BEAT - cur_m.Start) / cur_m.Length) - offset
						if m.Length == 0 then cur_ease = cur_m.Ease(1) - offset end
						local cur_perc = cur_ease * (cur_v1 - cur_v3)
						--perc = perc + (cur_v3 + cur_perc)
						if #active[pn][v[2]] == n then
							perc = perc + (cur_v3 + cur_perc)
						end
					end
					mod_percents[pn][v[2]] = perc
				elseif m.Type == 'Player' then
					v[3] = v[3] or mod_percents[pn][v[2]] or default_mods[pn][v[2]] or 0
					local ease = m.Ease((BEAT - m.Start) / m.Length)
					if m.Length == 0 then ease = m.Ease(1) end
					local perc = ease * (v[1] - v[3])
					mod_percents[pn][v[2]] = perc + v[3]
				end
			elseif BEAT >= (m.Start + m.Length) then
				if m.Type == 'Player' then
					v[3] = v[3] or mod_percents[pn][v[2]] or 0
					mod_percents[pn][v[2]] = m.Ease(1) * (v[1] - v[3]) + v[3]
					if v[4] and active[pn][v[2]] then
						active[pn][v[2]][v[4]] = nil
					end
				end
				if j >= #m.Modifiers then
					m = nil
					table.remove(modlist, i)
				end
			end
		end
    end
end


FG[#FG + 1] = Def.Actor {
	ReadyCommand = function(self)
		for pn = 1, #std.PL do
			GAMESTATE:ApplyModifiers('*-1 clearall', pn)
		end
	end,
	UpdateCommand = function(self)
		UpdateMods()
		ApplyMods()
	end
}


-- TODO: Create a GetPercent function to get the current mod percent

-- Load a mod file.
local function FromFile(self, scriptpath)
	--printerr('Mods:LoadFromFile')
	run('lua/'..scriptpath)
	return self
end
-- Write default mods.
local function Default(self, modtable)
	--printerr('Mods:Default')
	for pn = 1, plr_count do
		default_mods[pn] = modtable
	end
	local res = self:Insert(std.MOD_START, 0, function(t) return 1 end, modtable)
	return res
end
-- Define a new mod.
local function Define(self, name, func, ret)
	--printerr('Mods:Define')
	local t = {}
	t = {
		Function = func,
		Return = ret
	}
	for pn = 1, plr_count do
		custom_mods[pn][name] = t
	end
	return self
end
-- Write to a mod branch.
local function Insert(self, start, len, ease, modtable, offset, pn)
    --printerr('Mods:Insert')
    local t1, t2 = {}, {}
    if not offset or offset == 0 then
		t1 = {
			Start = start,
			Length = len,
			Ease = ease,
			Modifiers = modtable,
			Type = 'Player',
			Player = pn or 1
		}
		table.insert(modlist, t1)
		if not pn then
			t2 = {
				Start = start,
				Length = len,
				Ease = ease,
				Modifiers = modtable,
				Type = 'Player',
				Player = 2
			}
			table.insert(modlist, t2)
		end
    else
        for i, v in ipairs(modtable) do
            t1[i] = {
                Start = start + (offset * (i - 1)),
                Length = len,
                Ease = ease,
                Modifiers = {v},
				Type = 'Player',
                Player = pn or 1
            }
            table.insert(modlist, t1[i])
			if not pn then
				t2[i] = {
					Start = start + (offset * (i - 1)),
					Length = len,
					Ease = ease,
					Modifiers = {v},
					Type = 'Player',
					Player = 2
				}
				table.insert(modlist, t2[i])
			end
        end
    end
    return self
end
-- Write to a mod branch now Mirin approved!
local function Mirin(self, t, offset, pn)
    local tmods = {}
    for i = 4, #t, 2 do
        if t[i] and t[i + 1] then
            tmods[#tmods + 1] = {t[i], t[i + 1]}
        end
    end
    local res = self:Insert(t[1], t[2], t[3], tmods, offset, pn)
    return res
end
-- Write to a mod branch but you like extra wasabi~
local function Exsch(self, start, len, str1, str2, mod, timing, ease, pn)
    --printerr('Mods:Exsch')
    if timing == 'end' then
        len = len - start
    end
    local res = self:Insert(start, len, ease, {{str2, mod, str1}}, 0, pn)
    return res
end

Mods = {
	VERSION = '1.1',
	FromFile = FromFile,
	Define = Define,
	Insert = Insert,
	Mirin = Mirin,
	Exsch = Exsch,
	Default = Default,
}
Mods.__index = Mods

print('Loaded Konko Mods v'..Mods.VERSION)

return Mods
