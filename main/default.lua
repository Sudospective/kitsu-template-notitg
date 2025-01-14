-- default.lua --

--[[

    Woah! You're not supposed to be here! This is the backend!
    I suppose that since you're here, you wanna learn the
    * @ ~ . # - A D V A N C E D   S H I T - # . ~ @ *
    
    This is a very customizable but very experimental template,
	and bugs are to be expected, but the idea of this template
	is having extreme plug-and-play libraries and modability,
	while still having a base to work on or just use directly for
	quick and dirty modfile prototyping. If it looks hard to
	master the backend, that's because it IS hard to master the
	backend. There's a lot of things going on to ensure that
	everything I need is included, but everything YOU need can
	be included alongside or even instead of it. Using the template
	shouldn't be any more difficult than the standard stuff you'd
	expect in OutFox Lua, but if you need help with anything, feel
	more than free to send me a message on Discord. I'll be waiting
	in the OutFox server.

    Have your Lua manual handy, this is some hardcore C-style shit.

]]--

-- Let's get our song directory real quick.
local dir = GAMESTATE:GetCurrentSong():GetSongDir()
-- This loads the absolutely necessary stuff for the template's environment to work properly.
assert(loadfile(dir .. 'main/env.lua'))()
-- This loads our environment.
sudo()
-- This loads our mods.lua, where the user puts their code.
run 'lua/mods'
return Def.ActorFrame {
	OnCommand = function(self)
		self:queuecommand('Ready')
	end,
	ReadyCommand = function(self)
		self:queuecommand('Start')
	end,
	FG
}

--[[

	The rest is a deep dive through the files of the template. I really encourage you to explore them.
	I've left a lot of helpful comments. Have fun.
	
	~Sudo

    ---------------------------------------
    | Kitsu (n.): A clever canid creature |
    |   known for its cunning and speed.  |
    ---------------------------------------

--]]
