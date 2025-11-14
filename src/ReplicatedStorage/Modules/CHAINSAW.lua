local Settings = {
	isMelee = true,
	damage = 60,
	headshot = 120,
	attackAnim = "rbxassetid://77775942334485",
	attackSound = game.ReplicatedStorage.Sounds.AXE.Attack,
	equipAnim = "rbxassetid://99549317787451",
	equipSound = game.ReplicatedStorage.Sounds.AXE.Equip,
	deequipAnim = "rbxassetid://121701872354820",
	deequipSound = game.ReplicatedStorage.Sounds.AXE.Deequip,
	idleAnim = "rbxassetid://80349943231734",
	hitSound = game.ReplicatedStorage.Sounds.AXE.Hit,
	canSemi = true,
	canFullAuto = false,
	fireMode = "Semi",
	cooldown = 0.4,
	aimSmooth = .15,
	range = 8,
	
	-- Tree cutting properties
	canCutTrees = true,
	treeDamage = 40,
	chopSound = game.ReplicatedStorage.Sounds.AXE.Attack,
	
	-- Durability properties
	hasDurability = true,
	maxDurability = 300,
	durabilityLossPerHit = 2,
}
return Settings
