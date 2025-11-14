-- BackpackDropSystem.lua
-- Handles dropping a backpack with player inventory on death

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BackpackDropSystem = {}
BackpackDropSystem.ActiveBackpacks = {}

-- Get player's inventory from InventoryServer
local function getPlayerInventory(player)
	local InventoryServer = require(script.Parent.Server.InventoryServer)
	return InventoryServer.AllInventories[player]
end

-- Create backpack model on the ground
function BackpackDropSystem.CreateBackpack(position, inventoryItems, ownerName)
	-- Try to find backpack model in ReplicatedStorage
	local backpackModel = ReplicatedStorage:FindFirstChild("BackpackModel")
	
	if not backpackModel then
		-- Create a simple backpack model if one doesn't exist
		backpackModel = Instance.new("Model")
		backpackModel.Name = "BackpackModel"
		
		local backpackPart = Instance.new("Part")
		backpackPart.Name = "BackpackPart"
		backpackPart.Size = Vector3.new(2, 2, 1)
		backpackPart.BrickColor = BrickColor.new("Dark stone grey")
		backpackPart.Anchored = true
		backpackPart.CanCollide = true
		backpackPart.Parent = backpackModel
		
		-- Add a decal or mesh here if desired
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://430198390" -- Backpack mesh
		mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
		mesh.Parent = backpackPart
		
		backpackModel.PrimaryPart = backpackPart
	end
	
	local backpack = backpackModel:Clone()
	backpack.Name = ownerName .. "'s Backpack"
	
	-- Set position
	if backpack.PrimaryPart then
		backpack:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.new(0, 1, 0))
	end
	
	-- Store inventory items in the backpack
	local itemStorage = Instance.new("Folder")
	itemStorage.Name = "ItemStorage"
	itemStorage.Parent = backpack
	
	-- Move items into storage
	for _, item in ipairs(inventoryItems) do
		if item and item:IsA("Tool") then
			item.Parent = itemStorage
		end
	end
	
	-- Add attributes for identification
	backpack:SetAttribute("IsLootBackpack", true)
	backpack:SetAttribute("OwnerName", ownerName)
	
	-- Add proximity prompt for looting
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "LootPrompt"
	proximityPrompt.ActionText = "Loot Backpack"
	proximityPrompt.ObjectText = backpack.Name
	proximityPrompt.MaxActivationDistance = 8
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = backpack.PrimaryPart or backpack:FindFirstChildWhichIsA("BasePart")
	
	backpack.Parent = workspace
	
	-- Track active backpack
	table.insert(BackpackDropSystem.ActiveBackpacks, backpack)
	
	return backpack
end

-- Handle looting backpack
function BackpackDropSystem.LootBackpack(player, backpack)
	if not backpack or not backpack:GetAttribute("IsLootBackpack") then
		return false
	end
	
	local itemStorage = backpack:FindFirstChild("ItemStorage")
	if not itemStorage then
		return false
	end
	
	local InventoryServer = require(script.Parent.Server.InventoryServer)
	local playerInv = InventoryServer.AllInventories[player]
	if not playerInv then
		return false
	end
	
	local items = itemStorage:GetChildren()
	local transferredItems = {}
	local remainingItems = {}
	
	-- Try to transfer items to player
	for _, item in ipairs(items) do
		if item:IsA("Tool") then
			-- Check if player's inventory has space
			if not InventoryServer.CheckInventoryFull(player, item) then
				-- Transfer to player's backpack
				item.Parent = player.Backpack
				table.insert(transferredItems, item)
			else
				-- Inventory full, keep in backpack
				table.insert(remainingItems, item)
			end
		end
	end
	
	-- If all items transferred, remove backpack
	if #remainingItems == 0 then
		-- Remove from active list
		for i, bp in ipairs(BackpackDropSystem.ActiveBackpacks) do
			if bp == backpack then
				table.remove(BackpackDropSystem.ActiveBackpacks, i)
				break
			end
		end
		backpack:Destroy()
		return true, "All items looted!"
	else
		return true, string.format("Looted %d items. %d items remain (inventory full).", #transferredItems, #remainingItems)
	end
end

-- Setup proximity prompt listeners
function BackpackDropSystem.SetupProximityListeners()
	-- Listen for proximity prompt triggers
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ProximityPrompt") and descendant.Name == "LootPrompt" then
			descendant.Triggered:Connect(function(player)
				local backpack = descendant.Parent and descendant.Parent.Parent
				if backpack and backpack:GetAttribute("IsLootBackpack") then
					local success, message = BackpackDropSystem.LootBackpack(player, backpack)
					if success and message then
						-- Send feedback to player
						local Signal = require(ReplicatedStorage.Modules.Signal)
						Signal.FireClient(player, "InventoryClient:ErrorMessage", message)
					end
				end
			end)
		end
	end)
end

-- Handle player death
function BackpackDropSystem.OnPlayerDeath(player)
	local char = player.Character
	if not char then return end
	
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	humanoid.Died:Connect(function()
		-- Get player's position
		local rootPart = char:FindFirstChild("HumanoidRootPart")
		local position = rootPart and rootPart.Position or Vector3.new(0, 5, 0)
		
		-- Collect all inventory items
		local inventoryItems = {}
		
		-- Get items from backpack
		for _, item in ipairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(inventoryItems, item)
			end
		end
		
		-- Get equipped tools
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Tool") then
				table.insert(inventoryItems, item)
			end
		end
		
		-- Only create backpack if player has items
		if #inventoryItems > 0 then
			BackpackDropSystem.CreateBackpack(position, inventoryItems, player.Name)
		end
	end)
end

-- Initialize system
function BackpackDropSystem.Start()
	-- Setup for existing players
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			BackpackDropSystem.OnPlayerDeath(player)
		end
		player.CharacterAdded:Connect(function()
			BackpackDropSystem.OnPlayerDeath(player)
		end)
	end
	
	-- Setup for new players
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			BackpackDropSystem.OnPlayerDeath(player)
		end)
	end)
	
	-- Setup proximity listeners
	BackpackDropSystem.SetupProximityListeners()
end

return BackpackDropSystem
