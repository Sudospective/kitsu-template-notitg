-- Libraries
local std = import 'stdlib'
local Node = import 'konko-node'
local Mods = import 'konko-mods'
local ease = import 'ease'


-- Variables
local SW, SH = std.SW, std.SH
local SCX, SCY = std.SCX, std.SCY

-- Proxies
local P, PL = {}, {}
local PP, PJ, PC = {}, {}, {}
for pn = 1, GAMESTATE:GetNumPlayersEnabled() do
	PP[pn] = Node.new('ActorProxy'):AddToTree('PP'..pn)
	PJ[pn] = Node.new('ActorProxy'):AddToTree('PJ'..pn)
	PC[pn] = Node.new('ActorProxy'):AddToTree('PC'..pn)
end


-- Called on InitCommand
function init()

end

-- Called on ReadyCommand
function ready()
	
	-- Hide overlay elements
	Node.HideOverlay(true)

	-- Player shorthand variables
	PL = std.PL
	PP = {PP1, PP2}
	PJ = {PJ1, PJ2}
	PC = {PC1, PC2}
	for pn = 1, #PL do
		P[pn] = PL[pn].Player
		std.ProxyPlayer(PP[pn], pn)
		std.ProxyJudgment(PJ[pn], pn)
		std.ProxyCombo(PC[pn], pn)
	end

	-- Default mods
	Mods:Default {
		{1.5, 'xmod'},
		{100, 'modtimer'},
	}
	-- Mode code here

end

-- Called on InputMessageCommand
function input(event)
end

-- Called on UpdateCommand
function update(dt)

end

-- Called on FG.Draw
function draw()

end


table.insert(FG, Def.ActorFrame {

		-- Actors here
		Node.GetTree(),

})
