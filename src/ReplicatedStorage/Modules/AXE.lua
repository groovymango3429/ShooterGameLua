local Settings = {
	isMelee = true,
	damage = 40,
	headshot = 80,
	attackAnim = "rbxassetid://77775942334485", -- Replace with your swing animation ID
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
	cooldown = 0.8,
	aimSmooth = .15,
	range = 7,
	
	-- Tree cutting properties
	canCutTrees = true,
	treeDamage = 20,
	chopSound = game.ReplicatedStorage.Sounds.AXE.Attack,
	
	-- Durability properties
	hasDurability = true,
	maxDurability = 150,
	durabilityLossPerHit = 1,
	
	--99549317787451
}
return Settings