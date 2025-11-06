-- WorkstationClient.lua
-- Client-side script for detecting and interacting with workstations
-- Shows BillboardGui prompts similar to loot pickup and fires OpenCraftingMenu event

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local INTERACTION_KEY = Enum.KeyCode.E
local MAX_DISTANCE = 10

-- Wait for Events folder
local Events = ReplicatedStorage:WaitForChild("Events")
local OpenCraftingMenuEvent = Events:WaitForChild("OpenCraftingMenu")

-- Get workstations folder
local workstationsFolder = Workspace:FindFirstChild("Workstations")

-- Track which workstation is currently being looked at
local currentWorkstation = nil

-- Function to get the workstation the player is looking at or nearest to
local function getTargetWorkstation()
	if not workstationsFolder then return nil end
	
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	
	local hrp = char.HumanoidRootPart
	local cam = Workspace.CurrentCamera
	if not cam then return nil end
	
	-- First, try raycast to see what player is looking at
	local rayOrigin = cam.CFrame.Position
	local rayDir = cam.CFrame.LookVector * MAX_DISTANCE
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local rayResult = Workspace:Raycast(rayOrigin, rayDir, raycastParams)
	
	-- Check if raycast hit a workstation
	if rayResult and rayResult.Instance then
		local hit = rayResult.Instance
		-- Check if this part is a child of a workstation
		for _, workstation in ipairs(workstationsFolder:GetChildren()) do
			if hit:IsDescendantOf(workstation) then
				local stationPos = workstation:IsA("BasePart") and workstation.Position or (workstation.PrimaryPart and workstation.PrimaryPart.Position)
				if stationPos and (hrp.Position - stationPos).Magnitude <= MAX_DISTANCE then
					return workstation
				end
			end
		end
	end
	
	-- If not looking at a workstation, find nearest one within range
	local nearestStation = nil
	local nearestDist = MAX_DISTANCE
	
	for _, workstation in ipairs(workstationsFolder:GetChildren()) do
		local stationPos = workstation:IsA("BasePart") and workstation.Position or (workstation.PrimaryPart and workstation.PrimaryPart.Position)
		if stationPos then
			local dist = (hrp.Position - stationPos).Magnitude
			if dist < nearestDist then
				nearestDist = dist
				nearestStation = workstation
			end
		end
	end
	
	return nearestStation
end

-- Update BillboardGui visibility for workstations
local function updateWorkstationPrompts()
	if not workstationsFolder then return end
	
	local targetStation = getTargetWorkstation()
	
	-- Update current workstation
	currentWorkstation = targetStation
	
	-- Show/hide prompts for all workstations
	for _, workstation in ipairs(workstationsFolder:GetChildren()) do
		-- Find BillboardGui in the workstation
		local billboard = nil
		for _, descendant in ipairs(workstation:GetDescendants()) do
			if descendant:IsA("BillboardGui") and descendant.Name == "InteractionPrompt" then
				billboard = descendant
				break
			end
		end
		
		if billboard then
			billboard.Enabled = (workstation == targetStation)
		end
	end
end

-- Handle interaction key press
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or input.KeyCode ~= INTERACTION_KEY then return end
	
	if currentWorkstation then
		-- Fire event to open crafting menu for this workstation
		OpenCraftingMenuEvent:FireServer(currentWorkstation.Name)
	end
end)

-- Update prompts continuously
game:GetService("RunService").Heartbeat:Connect(function()
	updateWorkstationPrompts()
end)
