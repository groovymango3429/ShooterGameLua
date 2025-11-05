-- Made by VroIok, last updated on 9/1/24 | Version 2.7 (adds MovementState attribute for sound system support)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Signal = require(Modules:WaitForChild("Signal"))

local player = Players.LocalPlayer

local sprintSpeed = 26
local walkSpeed = 16
local crouchSpeed = 8

local sprintFOV = 76
local normalFOV = 70
local targetFOV = normalFOV
local currentFOV = normalFOV
local fovLerpSpeed = 10 -- Adjust for faster/slower FOV transition

local movementState = "Walking"
local crouchToggled = false

-- Camera crouch offset variables
local crouchCameraOffset = -1.5 -- How much the camera moves down when crouching
local crouchCameraTargetOffset = 0
local crouchCameraCurrentOffset = 0
local cameraOffsetLerpSpeed = 10

-- Helper function to check if player is moving
local function isMoving()
	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local vel = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
			return vel.Magnitude > 0.1 -- threshold to avoid jitter
		end
	end
	return false
end

local function setMovement(state)
	if movementState ~= state then
		movementState = state
		Signal.FireServer("MovementStateChanged", movementState)
	end

	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		-- Set MovementState as a Humanoid attribute for other scripts (like sound) to use
		humanoid:SetAttribute("MovementState", state)

		if state == "Sprinting" then
			humanoid.WalkSpeed = sprintSpeed
			targetFOV = sprintFOV
			crouchCameraTargetOffset = 0 -- Reset camera offset if sprinting
		elseif state == "Crouching" then
			humanoid.WalkSpeed = crouchSpeed
			targetFOV = normalFOV
			crouchCameraTargetOffset = crouchCameraOffset
		else
			humanoid.WalkSpeed = walkSpeed
			targetFOV = normalFOV
			crouchCameraTargetOffset = 0
		end
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		crouchToggled = false
		setMovement("Sprinting")
	elseif input.KeyCode == Enum.KeyCode.C then
		crouchToggled = not crouchToggled
		if crouchToggled then
			setMovement("Crouching")
		else
			setMovement("Walking")
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		if crouchToggled then
			setMovement("Crouching")
		else
			setMovement("Walking")
		end
	end
end)

-- Camera bobbing when sprinting + camera crouch offset
local bobbingTime = 0
RunService.RenderStepped:Connect(function(dt)
	-- Smoothly interpolate FOV
	local camera = workspace.CurrentCamera
	currentFOV = currentFOV + (targetFOV - currentFOV) * math.clamp(dt * fovLerpSpeed, 0, 1)
	camera.FieldOfView = currentFOV

	-- Smoothly interpolate towards the target offset
	crouchCameraCurrentOffset = crouchCameraCurrentOffset + (crouchCameraTargetOffset - crouchCameraCurrentOffset) * math.clamp(dt * cameraOffsetLerpSpeed, 0, 1)

	local baseCFrame = camera.CFrame
	baseCFrame = baseCFrame * CFrame.new(0, crouchCameraCurrentOffset, 0)

	-- Only apply FOV and bobbing if sprinting AND moving
	if movementState == "Sprinting" and isMoving() then
		bobbingTime = bobbingTime + dt * 8
		local bobAmount = math.sin(bobbingTime) * 0.3
		camera.CFrame = baseCFrame * CFrame.new(0, bobAmount, 0)
	else
		camera.CFrame = baseCFrame
	end
end)

setMovement("Walking")