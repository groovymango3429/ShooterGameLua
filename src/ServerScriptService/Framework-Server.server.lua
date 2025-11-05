local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponModules = {
	["TROY DEFENSE AR"] = require(ReplicatedStorage.Modules["TROY DEFENSE AR"]),
	["G19 ROLAND SPECIAL"] = require(ReplicatedStorage.Modules["G19 ROLAND SPECIAL"]),
	["AXE"] = require(ReplicatedStorage.Modules["AXE"]),
}

local PlayerWeaponState = {}

local function getEquippedWeaponName(player)
	local char = player.Character
	if not char then return nil end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") and WeaponModules[tool.Name] then
			return tool.Name
		end
	end
	return nil
end

local function getWeaponState(player, weaponName)
	if not PlayerWeaponState[player] then PlayerWeaponState[player] = {} end
	local state = PlayerWeaponState[player][weaponName]
	if not state then
		local config = WeaponModules[weaponName]
		state = {
			ammo = config and config.ammo or 0,
			lastFire = 0,
			reloading = false,
		}
		PlayerWeaponState[player][weaponName] = state
	end
	return state
end

Players.PlayerAdded:Connect(function(player)
	PlayerWeaponState[player] = {}
	player.CharacterAdded:Connect(function()
		PlayerWeaponState[player] = {}
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerWeaponState[player] = nil
end)

ReplicatedStorage.Events.Shoot.OnServerEvent:Connect(function(player, muzzlePos, aimPos)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local weaponName = getEquippedWeaponName(player)
	if not weaponName then return end
	local config = WeaponModules[weaponName]
	if not config or config.isMelee then return end -- skip melee

	local state = getWeaponState(player, weaponName)
	if state.reloading then return end

	local now = tick()
	if now - state.lastFire < config.fireRate then return end
	if state.ammo <= 0 then return end

	if typeof(muzzlePos) ~= "Vector3" then return end
	if (muzzlePos - root.Position).Magnitude > 10 then return end
	if typeof(aimPos) ~= "Vector3" then return end
	if (aimPos - muzzlePos).Magnitude > 1000 then return end

	local direction = (aimPos - muzzlePos).Unit * 500
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {char}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(muzzlePos, direction, rayParams)

	local hitZombie = false

	if result and result.Instance and result.Instance.Parent then
		local humanoid = result.Instance.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid ~= char:FindFirstChildOfClass("Humanoid") then
			local isHeadshot = (result.Instance.Name == "Head")
			humanoid:TakeDamage(isHeadshot and config.headshot or config.damage)

			if result.Instance.Parent:FindFirstChild("ZombieTag") or result.Instance.Parent.Name:find("Zombie") then
				hitZombie = true
			end
		end
	end

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			ReplicatedStorage.Events.PlayGunSound:FireClient(
				otherPlayer,
				weaponName,
				root.Position
			)
		end
	end

	if hitZombie then
		ReplicatedStorage.Events.ShowHitmarker:FireClient(player)
	end

	state.ammo = state.ammo - 1
	state.lastFire = now
end)

-- Axe/melee: fire from player's head
ReplicatedStorage.Events.MeleeAttack.OnServerEvent:Connect(function(player, originPos, aimPos)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local weaponName = getEquippedWeaponName(player)
	if not weaponName then return end
	local config = WeaponModules[weaponName]
	if not config or not config.isMelee then return end

	local now = tick()
	local state = getWeaponState(player, weaponName)
	if now - state.lastFire < (config.cooldown or 0.8) then return end
	state.lastFire = now

	local direction = (aimPos - originPos).Unit
	local range = config.range or 7
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {char}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	print("Axe raycast from", originPos, "to", aimPos, "with range", range)
	local result = workspace:Raycast(originPos, direction * range, params)

	if result and result.Instance then
		print("Axe hit part", result.Instance:GetFullName())
		-- Walk up ancestry to find Humanoid and zombie tag
		local hitInstance = result.Instance
		local hum = nil
		local isZombie = false
		local searchLimit = 8
		for i = 1, searchLimit do
			if not hitInstance then break end
			hum = hitInstance:FindFirstChildOfClass("Humanoid")
			if hum then
				if hitInstance:FindFirstChild("ZombieTag") or (hitInstance.Name and hitInstance.Name:find("Zombie")) then
					isZombie = true
				end
				break
			end
			hitInstance = hitInstance.Parent
		end

		if hum and hum ~= char:FindFirstChildOfClass("Humanoid") then
			local isHeadshot = (result.Instance.Name == "Head")
			print("Axe hit humanoid:", hum.Parent.Name, "isHeadshot?", isHeadshot)
			print("Humanoid health before:", hum.Health)
			local dmg = isHeadshot and config.headshot or config.damage
			hum:TakeDamage(dmg)
			if hum.Health > 0 then
				hum.Health = math.max(0, hum.Health - dmg)
			end
			print("Humanoid health after:", hum.Health)
			ReplicatedStorage.Events.ShowHitmarker:FireClient(player)
			if isZombie then
				-- Play hit sound for player who hit a zombie
				ReplicatedStorage.Events.PlayHitSound:FireClient(player, weaponName)
			end
		else
			print("No humanoid found in hit target.")
		end
	else
		print("Axe swing hit nothing.")
	end

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			ReplicatedStorage.Events.PlayGunSound:FireClient(
				otherPlayer,
				weaponName,
				root.Position
			)
		end
	end
end)

ReplicatedStorage.Events.Reload.OnServerEvent:Connect(function(player)
	local weaponName = getEquippedWeaponName(player)
	if not weaponName then return end
	local config = WeaponModules[weaponName]
	if not config or config.isMelee then return end -- skip melee

	local state = getWeaponState(player, weaponName)
	if state.reloading then return end
	state.reloading = true

	task.spawn(function()
		task.wait(config.reloadTime)
		state.ammo = config.maxAmmo
		state.reloading = false
	end)
end)

ReplicatedStorage.Events.QueryAmmo.OnServerInvoke = function(player)
	local weaponName = getEquippedWeaponName(player)
	if not weaponName then return 0, 0 end
	local config = WeaponModules[weaponName]
	if not config or config.isMelee then return 0, 0 end
	local state = getWeaponState(player, weaponName)
	return state.ammo, config.maxAmmo
end

ReplicatedStorage.Events.CanShoot.OnServerInvoke = function(player)
	local weaponName = getEquippedWeaponName(player)
	if not weaponName then return false end
	local config = WeaponModules[weaponName]
	if not config or config.isMelee then return true end
	local state = getWeaponState(player, weaponName)
	if state.reloading then return false end
	local now = tick()
	if now - state.lastFire < config.fireRate then return false end
	if state.ammo <= 0 then return false end
	return true
end