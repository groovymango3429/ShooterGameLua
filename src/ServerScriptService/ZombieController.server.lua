local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ZombiesFolder = ReplicatedStorage:WaitForChild("Zombies")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Signal = require(Modules:WaitForChild("Signal"))
local Animations = require(Modules:WaitForChild("Animations"))

local NoiseDebugEvent = ReplicatedStorage:FindFirstChild("NoiseDebugEvent")
if not NoiseDebugEvent then
	NoiseDebugEvent = Instance.new("RemoteEvent")
	NoiseDebugEvent.Name = "NoiseDebugEvent"
	NoiseDebugEvent.Parent = ReplicatedStorage
end

local SPAWN_INTERVAL = 1
local ALERT_TIME = 1
local ZombieSpawns = Workspace:FindFirstChild("ZombieSpawns") or Workspace

local NOISE_LEVELS = {
	["Sprinting"] = 75,
	["Walking"] = 35,
	["Crouching"] = 2.5,
}

local ZOMBIE_TYPES = {
	LightMilitaryZombie = true,
	DarkMilitaryZombie = true,
	PoliceZombie = true,
	SuitZombie = true,
	ScientistZombie = true,
	ReactorZombie = true,
	NormalZombie = true,
}

local ZOMBIE_WALK_SPEED = 3.8
local ZOMBIE_RUN_SPEED = 16

local ATTACK_RANGE = 4.5         -- how close to attack
local ATTACK_DELAY = 1           -- animation delay before hit
local ATTACK_COOLDOWN = 1.3      -- cooldown after punch
local ATTACK_DAMAGE = 25         -- damage per attack
local CHASE_LOST_DISTANCE = 75  -- distance at which zombie gives up chase

local playerStates = {}
local spawnedZombies = {}
local zombieWanderFlags = {}
local zombieWanderThreads = {}

-- Damage event for player (must be handled on client)
local TakeDamageEvent = ReplicatedStorage:FindFirstChild("TakeDamageEvent")
if not TakeDamageEvent then
	TakeDamageEvent = Instance.new("RemoteEvent")
	TakeDamageEvent.Name = "TakeDamageEvent"
	TakeDamageEvent.Parent = ReplicatedStorage
end

local function getZombieModel(zombieType)
	for _, model in ipairs(ZombiesFolder:GetChildren()) do
		if model.Name == zombieType then
			return model
		end
	end
	return nil
end

local function playZombieAnimation(zombie, animName, looped)
	if zombie:GetAttribute("Dead") and animName ~= "Dead" and animName ~= "Dying" then
		return nil
	end
	local animId = Animations.Zombie[animName]
	if not animId then 
		return nil
	end
	local humanoid = zombie:FindFirstChildOfClass("Humanoid")
	if not humanoid then 
		return nil
	end
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	for _, t in ipairs(animator:GetPlayingAnimationTracks()) do t:Stop(0) end
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim)
	track.Looped = looped ~= false -- default true
	track:Play(0)
	return track
end

local function preloadDeadPose(zombie)
	local hum = zombie:FindFirstChildOfClass("Humanoid")
	if hum then
		local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
		local animId = Animations.Zombie["Dead"]
		if animId then
			local anim = Instance.new("Animation")
			anim.AnimationId = animId
			local track = animator:LoadAnimation(anim)
			track.Looped = true
			track:Play(0)
			track:Stop(0)
		end
	end
end

local function preloadAttackPose(zombie)
	local hum = zombie:FindFirstChildOfClass("Humanoid")
	if hum then
		local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
		local animId = Animations.Zombie["Attack"]
		if animId then
			local anim = Instance.new("Animation")
			anim.AnimationId = animId
			local track = animator:LoadAnimation(anim)
			track.Looped = false
			track:Play(0)
			track:Stop(0)
		end
	end
end

local function freezeZombie(zombie)
	local hum = zombie:FindFirstChildOfClass("Humanoid")
	local hrp = zombie:FindFirstChild("HumanoidRootPart")
	if hum then
		hum.PlatformStand = true
	end
	if hrp then
		hrp.Anchored = true
	end
end

local function stopAllAnimations(zombie)
	local hum = zombie:FindFirstChildOfClass("Humanoid")
	if hum then
		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
				t:Stop(0)
			end
		end
	end
end

local function onZombieDied(zombie, spawnPoint)
	if zombie and zombie.Parent == Workspace then
		zombie:SetAttribute("Dead", true)
		zombie:SetAttribute("WasHit", false) -- clear WasHit
		freezeZombie(zombie)
		stopAllAnimations(zombie)
		local dyingTrack = playZombieAnimation(zombie, "Dying", false)
		local dyingLength = (dyingTrack and dyingTrack.Length > 0) and dyingTrack.Length or 2.5
		task.delay(dyingLength, function()
			if zombie and zombie.Parent == Workspace then
				stopAllAnimations(zombie)
				playZombieAnimation(zombie, "Dead", true)
			end
		end)
	end
	spawnedZombies[spawnPoint] = nil
	zombie:SetAttribute("Attacking", false)
	zombie:SetAttribute("Chasing", false)
end

local function stopZombieWander(zombie)
	zombieWanderFlags[zombie] = true
	zombieWanderThreads[zombie] = nil
end

local function wanderZombie(zombie, wanderOrigin)
	stopZombieWander(zombie)

	local hum = zombie:FindFirstChildOfClass("Humanoid")
	local hrp = zombie:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then 
		return 
	end
	hum.WalkSpeed = ZOMBIE_WALK_SPEED
	local wanderRadius = 20
	local minPause = 2
	local maxPause = 5

	zombieWanderFlags[zombie] = false

	local function doWander()
		while zombie.Parent == Workspace and hum.Health > 0 and not zombieWanderFlags[zombie] and not zombie:GetAttribute("Dead") do
			if not zombie:GetAttribute("Chasing") then
				hum.WalkSpeed = ZOMBIE_WALK_SPEED
				local originPos = wanderOrigin and wanderOrigin.Position or hrp.Position
				local angle = math.random() * math.pi * 2
				local radius = math.random() * wanderRadius
				local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
				local destination = Vector3.new(originPos.X + offset.X, originPos.Y, originPos.Z + offset.Z)
				playZombieAnimation(zombie, "Walking")
				hum:MoveTo(destination)
				local arrived = false
				local conn
				conn = hum.MoveToFinished:Connect(function(reached)
					arrived = true
					if conn then conn:Disconnect() end
				end)
				local timeout = 8
				local elapsed = 0
				while not arrived and elapsed < timeout and zombie.Parent == Workspace and hum.Health > 0 and not zombie:GetAttribute("Chasing") and not zombieWanderFlags[zombie] and not zombie:GetAttribute("Dead") do
					task.wait(0.2)
					elapsed = elapsed + 0.2
				end
				if conn then conn:Disconnect() end
				playZombieAnimation(zombie, "Idle")
				local pauseTime = math.random(minPause, maxPause)
				local pauseElapsed = 0
				while pauseElapsed < pauseTime and zombie.Parent == Workspace and hum.Health > 0 and not zombie:GetAttribute("Chasing") and not zombieWanderFlags[zombie] and not zombie:GetAttribute("Dead") do
					task.wait(0.2)
					pauseElapsed = pauseElapsed + 0.2
				end
			else
				while zombie:GetAttribute("Chasing") and zombie.Parent == Workspace and hum.Health > 0 and not zombieWanderFlags[zombie] and not zombie:GetAttribute("Dead") do
					task.wait(0.3)
				end
			end
		end
	end

	task.spawn(doWander)
	zombieWanderThreads[zombie] = true
end

local function spawnZombieAtPoint(spawnPoint)
	if not spawnPoint then return end

	local zombieType = spawnPoint:GetAttribute("ZombieType")
	if not zombieType then 
		return 
	end
	if not ZOMBIE_TYPES[zombieType] then 
		return 
	end

	local alreadySpawned = spawnedZombies[spawnPoint]
	if alreadySpawned and alreadySpawned.Parent == Workspace and alreadySpawned:FindFirstChild("Humanoid")
		and alreadySpawned.Humanoid.Health > 0 then
		return
	end

	local template = getZombieModel(zombieType)
	if not template then 
		return 
	end

	local zombie = template:Clone()
	zombie.Parent = Workspace

	preloadDeadPose(zombie)
	preloadAttackPose(zombie)

	local hrp = zombie:FindFirstChild("HumanoidRootPart")
	if hrp then
		zombie.PrimaryPart = hrp
		zombie:SetPrimaryPartCFrame(spawnPoint.CFrame + Vector3.new(0, 3, 0))
		hrp.Anchored = false
	else
		return
	end

	zombie:SetAttribute("SpawnPoint", spawnPoint.Name)
	zombie:SetAttribute("Chasing", false)
	zombie:SetAttribute("Attacking", false)
	zombie:SetAttribute("Dead", false)
	zombie:SetAttribute("WasHit", false)
	spawnedZombies[spawnPoint] = zombie

	local hum = zombie:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.BreakJointsOnDeath = false
		hum.Died:Connect(function()
			onZombieDied(zombie, spawnPoint)
		end)
		hum.WalkSpeed = ZOMBIE_WALK_SPEED
	end

	wanderZombie(zombie, spawnPoint)
end

task.spawn(function()
	while true do
		local spawnPoints = ZombieSpawns:GetChildren()
		for _, spawnPoint in ipairs(spawnPoints) do
			if spawnPoint:IsA("BasePart") and spawnPoint:GetAttribute("ZombieType") then
				spawnZombieAtPoint(spawnPoint)
			end
		end
		task.wait(SPAWN_INTERVAL)
	end
end)

-- ATTACK SYSTEM WITH AUTO-RETURN TO WANDER

local function zombieAttack(zombie, targetPlayer)
	if not zombie or not targetPlayer or not targetPlayer.Character then return end
	if zombie:GetAttribute("Dead") or zombie:GetAttribute("WasHit") then return end -- Do not attack if dead or was hit
	local hum = zombie:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local zhrp = zombie:FindFirstChild("HumanoidRootPart")
	local phrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not zhrp or not phrp then return end
	zombie:SetAttribute("Attacking", true)
	zombie:SetAttribute("Chasing", false)
	hum.WalkSpeed = 0
	playZombieAnimation(zombie, "Attack", false)
	task.wait(ATTACK_DELAY)

	-- Recheck before damaging, zombie may have been killed/hit
	if zombie:GetAttribute("Dead") or zombie:GetAttribute("WasHit") then
		zombie:SetAttribute("Attacking", false)
		zombie:SetAttribute("Chasing", false)
		hum.WalkSpeed = ZOMBIE_WALK_SPEED
		playZombieAnimation(zombie, "Walking")
		wanderZombie(zombie, zombie.PrimaryPart)
		return
	end

	if (zhrp.Position - phrp.Position).Magnitude <= ATTACK_RANGE + 1 then
		TakeDamageEvent:FireClient(targetPlayer, ATTACK_DAMAGE)
	end

	task.wait(ATTACK_COOLDOWN)
	zombie:SetAttribute("Attacking", false)
	zombie:SetAttribute("Chasing", true)
	hum.WalkSpeed = ZOMBIE_RUN_SPEED
	playZombieAnimation(zombie, "Running")
end

local function chaseAndAttackSequence(zombie, player)
	local hum = zombie.Humanoid
	local zhrp = zombie:FindFirstChild("HumanoidRootPart")
	while zombie:GetAttribute("Chasing") and hum.Health > 0 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
		if zombie:GetAttribute("Dead") or zombie:GetAttribute("WasHit") then
			zombie:SetAttribute("Chasing", false)
			zombie:SetAttribute("Attacking", false)
			hum.WalkSpeed = ZOMBIE_WALK_SPEED
			playZombieAnimation(zombie, "Walking")
			wanderZombie(zombie, zombie.PrimaryPart)
			break
		end
		local phrp = player.Character.HumanoidRootPart
		local dist = (zhrp.Position - phrp.Position).Magnitude
		if dist > CHASE_LOST_DISTANCE then
			zombie:SetAttribute("Chasing", false)
			zombie:SetAttribute("Attacking", false)
			break
		end
		if dist <= ATTACK_RANGE and not zombie:GetAttribute("Attacking") then
			zombieAttack(zombie, player)
		elseif not zombie:GetAttribute("Attacking") then
			hum:MoveTo(phrp.Position)
		end
		task.wait(0.25)
	end
	zombie:SetAttribute("Chasing", false)
	zombie:SetAttribute("Attacking", false)
	hum.WalkSpeed = ZOMBIE_WALK_SPEED
	playZombieAnimation(zombie, "Walking")
	wanderZombie(zombie, zombie.PrimaryPart)
end

local function activateZombies(player, movementState)
	local char = player.Character
	if not char then return end
	if not char:FindFirstChild("HumanoidRootPart") then return end
	local pos = char.HumanoidRootPart.Position
	local noiseLevel = NOISE_LEVELS[movementState] or 40
	local radius = math.clamp(noiseLevel / 2, 20, 100)

	if NoiseDebugEvent then
		NoiseDebugEvent:FireClient(player, radius)
	end

	for _, zombie in ipairs(Workspace:GetChildren()) do
		if ZOMBIE_TYPES[zombie.Name] and zombie:FindFirstChild("HumanoidRootPart") and zombie:FindFirstChild("Humanoid") then
			local zPos = zombie.HumanoidRootPart.Position
			local dist = (zPos - pos).Magnitude
			if dist <= radius then
				if not zombie:GetAttribute("Chasing") and not zombie:GetAttribute("Attacking") and not zombie:GetAttribute("Dead") then
					zombie:SetAttribute("Chasing", true)
					stopZombieWander(zombie)
					task.spawn(function()
						local hum = zombie.Humanoid
						hum.WalkSpeed = 0
						playZombieAnimation(zombie, "Alert")
						task.wait(ALERT_TIME)
						hum.WalkSpeed = ZOMBIE_RUN_SPEED
						playZombieAnimation(zombie, "Running")
						chaseAndAttackSequence(zombie, player)
					end)
				end
			end
		end
	end
end

Signal.ListenRemote("MovementStateChanged", function(player, movementState)
	if typeof(movementState) ~= "string" then return end
	if not NOISE_LEVELS[movementState] then return end
	playerStates[player] = movementState
	activateZombies(player, movementState)
end)

Players.PlayerRemoving:Connect(function(player)
	playerStates[player] = nil
end)

task.spawn(function()
	while true do
		for player, movementState in pairs(playerStates) do
			if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				if NOISE_LEVELS[movementState] then
					activateZombies(player, movementState)
				end
			end
		end
		task.wait(0.3)
	end
end)