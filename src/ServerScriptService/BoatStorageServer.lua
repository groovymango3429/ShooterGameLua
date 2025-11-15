-- BoatStorageServer.lua
-- Server-side boat storage system
-- Integrates with existing StorageServer pattern

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage.Modules.Types)
local Signal = require(ReplicatedStorage.Modules.Signal)
local InventoryServer = require(ServerScriptService.Server.InventoryServer)

-- Boat storage data, keyed by BoatId (string)
local BoatStorageData = {} -- [boatId] = { Items, MaxStacks, Owner, BoatInstance }

-- Find boat instance by BoatId in workspace
local function getBoatById(boatId)
	local boatsFolder = Workspace:FindFirstChild("Boats")
	if not boatsFolder then
		return nil
	end
	
	for _, boat in ipairs(boatsFolder:GetChildren()) do
		local storedBoatId = boat:GetAttribute("BoatId")
		if storedBoatId == boatId then
			return boat
		end
	end
	return nil
end

-- Open boat storage request from client
Signal.ListenRemote("BoatStorage:Open", function(player, boatId)
	local boat = getBoatById(boatId)
	if not boat then
		return
	end

	-- Create storage data if missing
	if not BoatStorageData[boatId] then
		BoatStorageData[boatId] = {
			Items = {},
			MaxStacks = 8,
			Owner = player,
			BoatInstance = boat,
		}
	end

	-- Use the regular Storage:Open signal so existing StorageClient can handle it
	Signal.FireClient(player, "Storage:Open", boatId, BoatStorageData[boatId].Items, BoatStorageData[boatId].MaxStacks)
end)

-- Hook into Storage:Deposit to handle boat storage
Signal.ListenRemote("Storage:Deposit", function(player, storageId, stackId)
	-- Check if this is a boat storage
	if not BoatStorageData[storageId] then
		return -- Not a boat storage, regular storage server will handle it
	end
	
	local boat = getBoatById(storageId)
	if not boat then
		return
	end

	local inv = InventoryServer.AllInventories[player]
	if not inv then return end

	-- Find stack in inventory
	local stackIdx, stackData
	for i, stack in ipairs(inv.Inventory) do
		if stack.StackId == stackId then
			stackIdx = i
			stackData = stack
			break
		end
	end
	if not stackIdx then return end

	-- Check boat storage capacity
	if #BoatStorageData[storageId].Items >= BoatStorageData[storageId].MaxStacks then
		Signal.FireClient(player, "Storage:Error", "Boat storage is full!")
		return
	end

	table.insert(BoatStorageData[storageId].Items, stackData)
	table.remove(inv.Inventory, stackIdx)

	Signal.FireClient(player, "Storage:Update", storageId, BoatStorageData[storageId].Items, BoatStorageData[storageId].MaxStacks)
	Signal.FireClient(player, "InventoryClient:Update", inv)
end)

-- Hook into Storage:Withdraw to handle boat storage
Signal.ListenRemote("Storage:Withdraw", function(player, storageId, stackId)
	-- Check if this is a boat storage
	if not BoatStorageData[storageId] then
		return -- Not a boat storage, regular storage server will handle it
	end
	
	local boat = getBoatById(storageId)
	if not boat then
		return
	end

	local inv = InventoryServer.AllInventories[player]
	if not inv then return end

	if #inv.Inventory >= InventoryServer.MaxStacks then
		Signal.FireClient(player, "Storage:Error", "Inventory is full!")
		return
	end

	-- Find stack in boat storage
	local stackIdx, stackData
	for i, stack in ipairs(BoatStorageData[storageId].Items) do
		if stack.StackId == stackId then
			stackIdx = i
			stackData = stack
			break
		end
	end
	if not stackIdx then return end

	table.insert(inv.Inventory, stackData)
	table.remove(BoatStorageData[storageId].Items, stackIdx)

	Signal.FireClient(player, "Storage:Update", storageId, BoatStorageData[storageId].Items, BoatStorageData[storageId].MaxStacks)
	Signal.FireClient(player, "InventoryClient:Update", inv)
end)

-- Get boat storage for a boat (used when spawning boats)
function getBoatStorage(boatId)
	return BoatStorageData[boatId]
end

-- Set boat storage for a boat (used when spawning boats)
function setBoatStorage(boatId, storageData)
	BoatStorageData[boatId] = storageData
end

return {
	BoatStorageData = BoatStorageData,
	getBoatStorage = getBoatStorage,
	setBoatStorage = setBoatStorage,
}
