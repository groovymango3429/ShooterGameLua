-- Place this as a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PICKUP_KEY = Enum.KeyCode.E
local MAX_DISTANCE = 8

local lootPickupEvent = ReplicatedStorage:WaitForChild("LootPickupEvent")

local function getLookedAtLoot()
	local cam = workspace.CurrentCamera
	if not cam then return nil end

	-- Cast ray from camera center
	local rayOrigin = cam.CFrame.Position
	local rayDir = cam.CFrame.LookVector * MAX_DISTANCE

	-- Ignore character
	local ignoreList = {player.Character}
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local rayResult = workspace:Raycast(rayOrigin, rayDir, raycastParams)
	if not rayResult or not rayResult.Instance then return nil end
	local hit = rayResult.Instance

	-- Check if a loot tool
	local tool = hit:FindFirstAncestorWhichIsA("Tool")
	if tool and CollectionService:HasTag(tool, "LootItem") then
		-- Check distance from camera (to prevent picking up through walls etc)
		if (cam.CFrame.Position - hit.Position).Magnitude <= MAX_DISTANCE then
			return tool
		end
	end
	return nil
end

UIS.InputBegan:Connect(function(input, processed)
	if processed or input.KeyCode ~= PICKUP_KEY then return end
	local loot = getLookedAtLoot()
	if loot and loot:FindFirstChild("Handle") then
		lootPickupEvent:FireServer(loot)
	end
end)