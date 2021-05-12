Node = import 'nodebuilder' -- Nodebuilder
Mods = import 'modsbuilder' -- Modsbuilder
Tweens = import 'ease' -- Eases

-- corope.lua needs to be ported for Lua 5.0 before being enabled for NotITG. ~Sudo
--[[
local Corope = require 'corope' -- Corope
Async = Corope({errhand = printerr})
--]]