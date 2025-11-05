-- Animations.lua
-- Centralized animation asset management for all game characters

local Animations = {}

Animations.Zombie = {
	Idle     = "rbxassetid://102051927815283", -- replace with your real asset IDs
	Alert    = "rbxassetid://91934711633994",
	Walking  = "rbxassetid://85382559130656",
	Running  = "rbxassetid://134795430939658",
	Attack   = "rbxassetid://79428563370906",
	Dying    = "rbxassetid://107726435433609",
	Dead     = "rbxassetid://139050763798536",
	Stagger  = "rbxassetid://123456796",
	Spawn    = "rbxassetid://123456797",
	Taunt    = "rbxassetid://123456798",
}

-- Example for Player (expand as needed)
Animations.Player = {
	Idle     = "rbxassetid://987654321",
	Walking  = "rbxassetid://987654322",
	Running  = "rbxassetid://987654323",
	Jump     = "rbxassetid://987654324",
	Crouch   = "rbxassetid://987654325",
	Attack   = "rbxassetid://987654326",
	Dying    = "rbxassetid://987654327",
}

return Animations