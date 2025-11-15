-- Updated Axe swing: fires from player's head position for melee detection
-- Now also listens for PlayHitSound and plays the hit sound when a zombie is hit
-- Now includes CameraKick feedback when you land a hit

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = game.Workspace.CurrentCamera
local dof = game.Lighting.DepthOfField
local aimCF = CFrame.new()
local mouse = player:GetMouse()
local playerGui = player.PlayerGui
local gui = playerGui:WaitForChild("Inventory")
local invF = gui:WaitForChild("Inventory")
local isAiming = false
local isShooting = false
local isReloading = false
local isSprinting = false
local canShoot = true
local canInspect = true
local bobOffset = CFrame.new()
local debounce = false
local currentSwayAMT = -.3
local swayAMT = -.3
local aimSwayAMT = .2
local swayCF = CFrame.new()
local lastCameraCF = CFrame.new()
local fireAnim, equipAnim, deequipAnim, emptyfireAnim, reloadAnim, emptyReloadAnim, InspectAnim, idleAnim = nil, nil, nil, nil, nil, nil, nil, nil

local framework = {
	inventory = {
		"TROY DEFENSE AR";
		"G19 ROLAND SPECIAL";
		"AXE";
	},
	module = nil,
	viewmodel = nil,
	currentSlot = 1,
}

local equippedTool = nil

function PlayLocalFireSound()
	if not framework.module then return end
	local soundObj
	if framework.module.isMelee then
		soundObj = framework.module.attackSound
	else
		soundObj = framework.module.fireSound
	end
	if not soundObj then return end
	local fireSound = Instance.new("Sound")
	fireSound.SoundId = soundObj.SoundId
	fireSound.Volume = soundObj.Volume
	fireSound.Parent = camera
	fireSound:Play()
	game:GetService("Debris"):AddItem(fireSound, 2)
end

-- CameraKick function for feedback when you hit a zombie
local cameraKickMagnitude = 0.25 -- You can tweak this value
local function CameraKick()
	local cam = workspace.CurrentCamera
	local originalCF = cam.CFrame
	local kickCF = originalCF * CFrame.Angles(math.rad(-cameraKickMagnitude), 0, 0)
	cam.CFrame = kickCF
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(cam, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {CFrame = originalCF})
	tween:Play()
end

-- Listen for PlayHitSound event from server!
game.ReplicatedStorage.Events.PlayHitSound.OnClientEvent:Connect(function(weaponName)
	local moduleFolder = game.ReplicatedStorage.Modules
	local weaponModule = moduleFolder:FindFirstChild(weaponName)
	if not weaponModule then return end
	local m = require(weaponModule)
	local hitSound = m.hitSound
	if not hitSound then return end
	local sound = hitSound:Clone()
	local char = player.Character
	if char and char:FindFirstChild("Head") then
		sound.Parent = char.Head
	else
		sound.Parent = workspace.CurrentCamera
	end
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 2)
	CameraKick() -- Camera feedback when hit lands!
end)

-- Listen for PlayTreeHitSound event for wood impact sounds
game.ReplicatedStorage.Events.PlayTreeHitSound.OnClientEvent:Connect(function(weaponName)
	-- Play wood impact sound from ReplicatedStorage.Sounds.WoodImpact
	local woodImpactSound = game.ReplicatedStorage:FindFirstChild("Sounds")
	if woodImpactSound then
		woodImpactSound = woodImpactSound:FindFirstChild("WoodImpact")
	end
	
	if woodImpactSound and woodImpactSound:IsA("Sound") then
		local sound = woodImpactSound:Clone()
		local char = player.Character
		if char and char:FindFirstChild("Head") then
			sound.Parent = char.Head
		else
			sound.Parent = workspace.CurrentCamera
		end
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 2)
	end
end)

local hud = player.PlayerGui:WaitForChild("HUD")
local ammoLabel = hud:WaitForChild("Ammo")
local maxAmmoLabel = ammoLabel:WaitForChild("MaxAmmo")
local fireModeLabel = hud:FindFirstChild("Firemode")

function UpdateAmmoHUD()
	if not framework.module then return end
	if framework.module.isMelee then
		ammoLabel.Text = "-"
		maxAmmoLabel.Text = "-"
		if fireModeLabel then fireModeLabel.Text = "Melee" end
		return
	end
	local ammo, maxAmmo = game.ReplicatedStorage.Events.QueryAmmo:InvokeServer()
	ammoLabel.Text = tostring(ammo)
	maxAmmoLabel.Text = tostring(maxAmmo)
	if fireModeLabel then
		fireModeLabel.Text = framework.module.fireMode
	end
end

function loadSlot(Item)
	local viewmodelFolder = game.ReplicatedStorage.Viewmodels
	local moduleFolder = game.ReplicatedStorage.Modules

	canShoot = false
	canInspect = false

	for i, v in pairs(camera:GetChildren()) do
		if v:IsA("Model") then
			if deequipAnim then deequipAnim:Play() end
			repeat task.wait() until deequipAnim == nil or deequipAnim.IsPlaying == false
			v:Destroy()
		end
	end

	if moduleFolder:FindFirstChild(Item) then
		framework.module = require(moduleFolder:FindFirstChild(Item))

		if viewmodelFolder:FindFirstChild(Item) then
			framework.viewmodel = viewmodelFolder:FindFirstChild(Item):Clone()
			framework.viewmodel.Parent = camera

			if framework.viewmodel and framework.module and character then
				local animController = framework.viewmodel:FindFirstChildOfClass("AnimationController")
				local animator = animController and animController:FindFirstChildOfClass("Animator")
				if not animController or not animator then
					animController = Instance.new("AnimationController")
					animController.Name = "AnimationController"
					animController.Parent = framework.viewmodel
					animator = Instance.new("Animator")
					animator.Parent = animController
				end

				local function loadAnim(animId)
					local anim = Instance.new("Animation")
					anim.AnimationId = animId
					return animator:LoadAnimation(anim)
				end

				if framework.module.isMelee then
					fireAnim = loadAnim(framework.module.attackAnim)
					emptyfireAnim = nil
					reloadAnim = nil
					emptyReloadAnim = nil
				else
					fireAnim = loadAnim(framework.module.fireAnim)
					emptyfireAnim = loadAnim(framework.module.emptyfireAnim)
					reloadAnim = loadAnim(framework.module.reloadAnim)
					emptyReloadAnim = loadAnim(framework.module.emptyReloadAnim)
				end
				equipAnim = loadAnim(framework.module.equipAnim)
				deequipAnim = loadAnim(framework.module.deequipAnim)
				InspectAnim = loadAnim(framework.module.InspectAnim or framework.module.idleAnim)
				idleAnim = loadAnim(framework.module.idleAnim)

				game.ReplicatedStorage.Events.LoadSlot:FireServer(
					(framework.module.isMelee and framework.module.attackSound.SoundId) or framework.module.fireSound.SoundId,
					(framework.module.isMelee and framework.module.attackSound.Volume) or framework.module.fireSound.Volume
				)

				for i, v in pairs(framework.viewmodel:GetDescendants()) do
					if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("BasePart") then
						v.Transparency = 1
					end
				end

				equipAnim:Play()
				task.wait(.1)

				for i, v in pairs(framework.viewmodel:GetDescendants()) do
					if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("BasePart") then
						if v.Name ~= "Main" and v.Name ~= "Muzzle" and v.Name ~= "FakeCamera" and v.Name ~= "AimPart" and v.Name ~= "HumanoidRootPart" then
							v.Transparency = 0
						end
					end
				end

				canShoot = true
				canInspect = true
				UpdateAmmoHUD()
			end
		end
	end
end

local hitmarker = hud:WaitForChild("Hitmarker")
local function showHitmarker()
	hitmarker.Visible = true
	hitmarker.ImageTransparency = 0
	for i = 1, 10 do
		hitmarker.ImageTransparency = i/10
		task.wait(0.02)
	end
	hitmarker.Visible = false
end
game.ReplicatedStorage.Events.ShowHitmarker.OnClientEvent:Connect(function()
	showHitmarker()
end)

local function updateViewmodel()
	if equippedTool and equippedTool:IsA("Tool") and equippedTool:GetAttribute("ItemType") == "Weapon" then
		loadSlot(equippedTool.Name)
		hud.Enabled = not (framework.module and framework.module.isMelee)
		UpdateAmmoHUD()
	else
		for _, v in pairs(camera:GetChildren()) do
			if v:IsA("Model") then
				v:Destroy()
			end
		end
		framework.viewmodel = nil
		framework.module = nil
		hud.Enabled = false
	end
end

local function onCharacterAdded(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:GetAttribute("ItemType") == "Weapon" then
			equippedTool = child
			updateViewmodel()
		end
	end)
	char.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") and child:GetAttribute("ItemType") == "Weapon" then
			equippedTool = nil
			updateViewmodel()
		end
	end)
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Tool") and child:GetAttribute("ItemType") == "Weapon" then
			equippedTool = child
			updateViewmodel()
			break
		end
	end
end

onCharacterAdded(character)
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	onCharacterAdded(char)
end)

function CanShootServer()
	if framework.module and framework.module.isMelee then
		return true
	end
	return game.ReplicatedStorage.Events.CanShoot:InvokeServer()
end

function Shoot()
	if not framework.module then return end
	if framework.module.isMelee then
		if debounce then return end
		debounce = true
		fireAnim:Play()
		PlayLocalFireSound()
		-- UPDATED: FireServer from player's head position for melee hit detection
		local head = character and character:FindFirstChild("Head")
		local originPos = head and head.Position or (character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position or camera.CFrame.Position)
		game.ReplicatedStorage.Events.MeleeAttack:FireServer(
			originPos,
			mouse.Hit.p
		)
		task.wait(framework.module.cooldown or 0.8)
		debounce = false
	elseif framework.module.fireMode == "Semi" then
		equipAnim:Stop()
		reloadAnim:Stop()
		emptyReloadAnim:Stop()
		InspectAnim:Stop()
		idleAnim:Stop()
		fireAnim:Play()
		PlayLocalFireSound()
		game.ReplicatedStorage.Events.Shoot:FireServer(
			framework.viewmodel and framework.viewmodel:FindFirstChild("Muzzle") and framework.viewmodel.Muzzle.Position or camera.CFrame.Position,
			mouse.Hit.p
		)
		UpdateAmmoHUD()
		debounce = true
		task.wait(framework.module.fireRate)
		debounce = false
	end
end

function Inspect()
	if canInspect then
		idleAnim:Stop()
		dof.FarIntensity = 1
		dof.FocusDistance = 10.44
		dof.InFocusRadius = 25.215
		dof.NearIntensity = 0.183
		InspectAnim:Play()
		repeat task.wait() until not InspectAnim.IsPlaying
		dof.FarIntensity = 0.1
		dof.FocusDistance = 0.05
		dof.InFocusRadius = 30
		dof.NearIntensity = 0
	end
end

function Reload()
	if framework.module and framework.module.isMelee then
		return
	end
	if isReloading == false and framework.module then
		canShoot = false
		canInspect = false
		isReloading = true
		fireAnim:Stop()
		emptyfireAnim:Stop()
		equipAnim:Stop()
		InspectAnim:Stop()
		idleAnim:Stop()
		reloadAnim:Play()
		game.ReplicatedStorage.Events.Reload:FireServer()
		task.wait(framework.module.reloadTime)
		canShoot = true
		canInspect = true
		isReloading = false
		UpdateAmmoHUD()
	end
end

local oldCamCF = CFrame.new()
function updateCameraShake()
	if not framework.viewmodel then return end
	local fakeCamera = framework.viewmodel:FindFirstChild("FakeCamera")
	if not fakeCamera then return end
	local newCamCF = fakeCamera.CFrame:ToObjectSpace(framework.viewmodel.PrimaryPart.CFrame)
	camera.CFrame = camera.CFrame * newCamCF:ToObjectSpace(oldCamCF)
	oldCamCF = newCamCF
end

RunService.RenderStepped:Connect(function()
	if framework.viewmodel then
		mouse.TargetFilter = framework.viewmodel
	end

	if humanoid then
		local rot = camera.CFrame:ToObjectSpace(lastCameraCF)
		local X, Y, Z = rot:ToOrientation()
		swayCF = swayCF:Lerp(CFrame.Angles(math.sin(X) * currentSwayAMT, math.sin(Y) * currentSwayAMT, 0), .1)
		lastCameraCF = camera.CFrame

		if hud and humanoid then
			if framework.viewmodel and framework.module then
				hud.GunName.Text = equippedTool and equippedTool.Name or ""
				if fireModeLabel then
					fireModeLabel.Text = framework.module.fireMode
				end
			end
		end

		if framework.viewmodel ~= nil and framework.module ~= nil then
			local finalCF = camera.CFrame * swayCF * aimCF
			if framework.viewmodel.PrimaryPart then
				framework.viewmodel:SetPrimaryPartCFrame(finalCF)
			end
			updateCameraShake()

			if idleAnim and not (fireAnim and fireAnim.IsPlaying) and not (emptyfireAnim and emptyfireAnim.IsPlaying) and not (emptyReloadAnim and emptyReloadAnim.IsPlaying) and not (reloadAnim and reloadAnim.IsPlaying) and not (InspectAnim and InspectAnim.IsPlaying) and not (equipAnim and equipAnim.IsPlaying) and not (deequipAnim and deequipAnim.IsPlaying) then
				if not idleAnim.IsPlaying then
					idleAnim:Play()
				end
			else
				if idleAnim then idleAnim:Stop() end
			end
		end

		if framework.viewmodel ~= nil then
			if isAiming and framework.module and framework.module.canAim and isSprinting == false then
				local aimPart = framework.viewmodel:FindFirstChild("AimPart")
				local offset = aimPart and aimPart.CFrame:ToObjectSpace(framework.viewmodel.PrimaryPart.CFrame) or CFrame.new()
				aimCF = aimCF:Lerp(offset, framework.module.aimSmooth)
				currentSwayAMT = aimSwayAMT
			else
				local offset = CFrame.new()
				aimCF = aimCF:Lerp(offset, framework.module.aimSmooth)
				currentSwayAMT = swayAMT
			end
		end
	end
end)

local mouseDown = false
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isAiming = true
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseDown = true
		if framework.module and framework.module.fireMode == "Full Auto" and not framework.module.isMelee then
			isShooting = true
		end
		if character and framework.viewmodel and framework.module and debounce == false and isReloading ~= true and canShoot == true and invF.Visible == false then
			Shoot()
		end
	end

	if input.KeyCode == Enum.KeyCode.V then
		if framework.module and framework.module.canSemi and framework.module.canFullAuto and not framework.module.isMelee then
			if framework.module.fireMode == "Full Auto" then
				framework.module.fireMode = "Semi"
			else
				framework.module.fireMode = "Full Auto"
			end
			UpdateAmmoHUD()
		end
	end

	if input.KeyCode == Enum.KeyCode.R then
		Reload()
	end

	if input.KeyCode == Enum.KeyCode.F then
		Inspect()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isAiming = false
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseDown = false
		isShooting = false
	end
end)

task.spawn(function()
	while true do
		if isShooting and framework.module and framework.module.fireMode == "Full Auto" and isReloading ~= true and canShoot == true and not framework.module.isMelee then
			if not CanShootServer() then
				isShooting = false
			else
				equipAnim:Stop()
				reloadAnim:Stop()
				emptyReloadAnim:Stop()
				InspectAnim:Stop()
				idleAnim:Stop()
				fireAnim:Play()
				PlayLocalFireSound()
				game.ReplicatedStorage.Events.Shoot:FireServer(
					framework.viewmodel and framework.viewmodel:FindFirstChild("Muzzle") and framework.viewmodel.Muzzle.Position or camera.CFrame.Position,
					mouse.Hit.p
				)
				UpdateAmmoHUD()
				task.wait(framework.module.fireRate)
			end
		else
			task.wait(0.05)
		end
	end
end)

-- FINAL DEBUG HANDLER FOR PlayGunSound
game.ReplicatedStorage.Events.PlayGunSound.OnClientEvent:Connect(function(...)
	local args = {...}
	print("==== PlayGunSound DEBUG ====")
	print("Args received (table):", args)
	for i, v in ipairs(args) do
		print(" Arg["..i.."] =", v)
	end
	print("Num args:", #args)
	local weaponName = args[1]
	local pos = args[2]
	-- No thirdArg! (Remove all usage of thirdArg, since you only ever get 2 arguments)
	if weaponName == nil then warn("PlayGunSound: weaponName is MISSING or NIL!") end
	if pos == nil then warn("PlayGunSound: pos is MISSING or NIL!") end

	local moduleFolder = game.ReplicatedStorage.Modules
	local weaponModule = moduleFolder:FindFirstChild(weaponName)
	if not weaponModule then
		warn("PlayGunSound: weaponModule not found for", weaponName)
		return
	end
	local m = require(weaponModule)
	local soundObj = m.isMelee and m.attackSound or m.fireSound
	if not soundObj then
		warn("PlayGunSound: soundObj not found for", weaponName)
		return
	end
	local fireSound = Instance.new("Sound")
	fireSound.SoundId = soundObj.SoundId
	fireSound.Volume = soundObj.Volume
	fireSound.Position = pos
	fireSound.Parent = workspace
	fireSound.EmitterSize = 10
	fireSound.RollOffMode = Enum.RollOffMode.Inverse
	fireSound:Play()
	game:GetService("Debris"):AddItem(fireSound, 2)
	print("==== PlayGunSound DEBUG END ====")
end)