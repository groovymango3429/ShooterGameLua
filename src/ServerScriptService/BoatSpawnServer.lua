-- BoatSpawnServer.lua
-- Server-side boat spawning system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- Player boat data (stores boat IDs and storage for each player)
local PlayerBoats = {} -- [player] = { BoatId = string, StorageData = table }

-- Create or get RemoteEvent for spawning boats
local spawnBoatEvent = ReplicatedStorage:FindFirstChild("SpawnBoat")
if not spawnBoatEvent then
	spawnBoatEvent = Instance.new("RemoteEvent")
	spawnBoatEvent.Name = "SpawnBoat"
	spawnBoatEvent.Parent = ReplicatedStorage
end

-- Get or create boats folder in workspace
local function getBoatsFolder()
	local boatsFolder = Workspace:FindFirstChild("Boats")
	if not boatsFolder then
		boatsFolder = Instance.new("Folder")
		boatsFolder.Name = "Boats"
		boatsFolder.Parent = Workspace
	end
	return boatsFolder
end

-- Find boat template in ServerStorage or ReplicatedStorage
local function getBoatTemplate()
	-- Try ServerStorage first
	local template = ServerStorage:FindFirstChild("BoatModel")
	if template then
		return template
	end
	
	-- Try ReplicatedStorage
	template = ReplicatedStorage:FindFirstChild("BoatModel")
	if template then
		return template
	end
	
	-- Create a simple boat if none exists
	warn("[BoatSpawn] No boat template found, creating basic boat")
	local boat = Instance.new("Model")
	boat.Name = "BoatModel"
	
	local hull = Instance.new("Part")
	hull.Name = "Hull"
	hull.Size = Vector3.new(6, 2, 12)
	hull.BrickColor = BrickColor.new("Brown")
	hull.Anchored = false
	hull.Parent = boat
	
	boat.PrimaryPart = hull
	
	-- Add seat
	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = Vector3.new(2, 1, 2)
	seat.Position = hull.Position + Vector3.new(0, 1.5, 0)
	seat.Anchored = false
	seat.Parent = boat
	
	-- Weld seat to hull
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hull
	weld.Part1 = seat
	weld.Parent = seat
	
	-- Save template
	boat.Parent = ServerStorage
	
	return boat
end

-- Remove player's existing boat
local function removePlayerBoat(player)
	local boatData = PlayerBoats[player]
	if not boatData then return end
	
	local boatsFolder = getBoatsFolder()
	for _, boat in ipairs(boatsFolder:GetChildren()) do
		if boat:GetAttribute("BoatId") == boatData.BoatId then
			-- Store the storage data before removing
			local BoatStorageServer = require(script.Parent.BoatStorageServer)
			local storageData = BoatStorageServer.getBoatStorage(boatData.BoatId)
			if storageData then
				boatData.StorageData = storageData
			end
			
			boat:Destroy()
			print("[BoatSpawn] Removed existing boat for player:", player.Name)
			return
		end
	end
end

-- Spawn boat for player
local function spawnBoat(player, position)
	-- Remove existing boat first
	removePlayerBoat(player)
	
	-- Get boat template
	local template = getBoatTemplate()
	if not template then
		warn("[BoatSpawn] Failed to get boat template")
		return
	end
	
	-- Clone boat
	local boat = template:Clone()
	boat.Name = player.Name .. "'s Boat"
	
	-- Generate or reuse boat ID
	local boatId
	if PlayerBoats[player] and PlayerBoats[player].BoatId then
		-- Reuse existing boat ID to preserve storage
		boatId = PlayerBoats[player].BoatId
	else
		-- Generate new boat ID
		boatId = HttpService:GenerateGUID(false)
	end
	
	boat:SetAttribute("BoatId", boatId)
	boat:SetAttribute("Owner", player.Name)
	
	-- Position boat in water
	if boat.PrimaryPart then
		-- Offset position to be in water
		local spawnPosition = position + Vector3.new(0, 2, 5) -- Slightly forward and up
		boat:SetPrimaryPartCFrame(CFrame.new(spawnPosition))
	end
	
	-- Parent to workspace
	local boatsFolder = getBoatsFolder()
	boat.Parent = boatsFolder
	
	-- Add boat server script
	local boatScript = script.Parent.Parent:FindFirstChild("BoatScript")
	if boatScript then
		local scriptClone = boatScript:Clone()
		scriptClone.Parent = boat
		scriptClone.Disabled = false
	end
	
	-- Initialize boat data for player
	if not PlayerBoats[player] then
		PlayerBoats[player] = {}
	end
	PlayerBoats[player].BoatId = boatId
	
	-- Restore storage data if it exists
	if PlayerBoats[player].StorageData then
		local BoatStorageServer = require(script.Parent.BoatStorageServer)
		BoatStorageServer.setBoatStorage(boatId, PlayerBoats[player].StorageData)
	end
	
	print("[BoatSpawn] Spawned boat for player:", player.Name, "with ID:", boatId)
	return boat
end

-- Handle boat spawn requests
spawnBoatEvent.OnServerEvent:Connect(function(player, position)
	print("[BoatSpawn] Spawn request from:", player.Name, "at position:", position)
	spawnBoat(player, position)
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
	-- Remove player's boat
	removePlayerBoat(player)
	
	-- Clear player data
	PlayerBoats[player] = nil
end)

print("[BoatSpawn] Boat spawn server loaded")
