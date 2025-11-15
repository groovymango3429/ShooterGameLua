-- BoatSpawnClient.lua
-- Client-side script for spawning boats near water

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local SPAWN_KEY = Enum.KeyCode.F
local CHECK_DISTANCE = 15 -- Distance to check for water
local CHECK_INTERVAL = 0.5 -- Check every 0.5 seconds

local isNearWater = false
local lastCheckTime = 0

-- Helper: Check if a position has water nearby
local function isNearWaterTerrain(position)
	-- Check in a radius around the position
	local searchRadius = CHECK_DISTANCE
	local searchSize = Vector3.new(searchRadius * 2, searchRadius * 2, searchRadius * 2)
	local region = Region3.new(position - searchSize/2, position + searchSize/2)
	region = region:ExpandToGrid(4)
	
	local success, materials = pcall(function()
		return workspace.Terrain:ReadVoxels(region, 4)
	end)
	
	if not success then
		return false
	end
	
	local size = materials.Size
	-- Check if any voxel contains water
	for x = 1, size.X do
		for y = 1, size.Y do
			for z = 1, size.Z do
				if materials[x][y][z] == Enum.Material.Water then
					return true
				end
			end
		end
	end
	
	return false
end

-- Update boat spawn GUI visibility based on proximity to water
local function updateBoatSpawnGui()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then 
		isNearWater = false
		return 
	end
	
	local hrp = char.HumanoidRootPart
	local position = hrp.Position
	
	-- Check if near water
	local nearWater = isNearWaterTerrain(position)
	
	-- Update state
	if nearWater ~= isNearWater then
		isNearWater = nearWater
		
		-- Show/hide the boat spawn GUI
		local playerGui = player:WaitForChild("PlayerGui")
		local boatSpawnGui = playerGui:FindFirstChild("BoatSpawnGui")
		
		if boatSpawnGui then
			boatSpawnGui.Enabled = isNearWater
			print("[BoatSpawn] Boat spawn GUI visibility:", isNearWater)
		else
			-- GUI doesn't exist, create a simple one
			if isNearWater then
				boatSpawnGui = Instance.new("ScreenGui")
				boatSpawnGui.Name = "BoatSpawnGui"
				boatSpawnGui.ResetOnSpawn = false
				boatSpawnGui.Parent = playerGui
				
				-- Create hint frame
				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(0, 200, 0, 50)
				frame.Position = UDim2.new(0.5, -100, 0.85, 0)
				frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				frame.BackgroundTransparency = 0.5
				frame.BorderSizePixel = 0
				frame.Parent = boatSpawnGui
				
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 8)
				corner.Parent = frame
				
				-- Create text label
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = "Press [F] to spawn boat"
				label.TextColor3 = Color3.fromRGB(255, 255, 255)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.Parent = frame
				
				local padding = Instance.new("UIPadding")
				padding.PaddingTop = UDim.new(0, 5)
				padding.PaddingBottom = UDim.new(0, 5)
				padding.PaddingLeft = UDim.new(0, 10)
				padding.PaddingRight = UDim.new(0, 10)
				padding.Parent = label
				
				print("[BoatSpawn] Created boat spawn GUI")
			end
		end
	end
end

-- Handle F key press to spawn boat
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == SPAWN_KEY and isNearWater then
		-- Request boat spawn from server
		local spawnBoatEvent = ReplicatedStorage:FindFirstChild("SpawnBoat")
		if spawnBoatEvent then
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local position = char.HumanoidRootPart.Position
				spawnBoatEvent:FireServer(position)
				print("[BoatSpawn] Requested boat spawn")
			end
		else
			warn("[BoatSpawn] SpawnBoat RemoteEvent not found")
		end
	end
end)

-- Update loop
RunService.Heartbeat:Connect(function()
	local currentTime = tick()
	if currentTime - lastCheckTime >= CHECK_INTERVAL then
		updateBoatSpawnGui()
		lastCheckTime = currentTime
	end
end)

print("[BoatSpawn] Boat spawn client script loaded")
