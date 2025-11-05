-- CraftingServer.lua
-- Handles crafting requests. Prints detailed debug info including AllItems listing, sample finding, and cloning.
-- Place in ServerScriptService.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

local CraftEvent = Events:WaitForChild("CraftEvent") -- RemoteEvent
local InventoryServer = require(script.Parent.Server.InventoryServer)
local RecipeDatabase = require(ReplicatedStorage.Modules.RecipeDatabase)

local function getRecipeByName(name)
	if RecipeDatabase.GetRecipeByName then
		return RecipeDatabase:GetRecipeByName(name)
	elseif RecipeDatabase.GetByCategory then
		for _, recipe in ipairs(RecipeDatabase:GetByCategory("All")) do
			if recipe.name == name then
				return recipe
			end
		end
	end
	return nil
end

local function getMissingIngredients(player, recipe)
	local inv = InventoryServer.AllInventories[player]
	local missing = {}
	if not inv then
		print("[DEBUG] Inventory for player", player.Name, "not found.")
		return missing
	end
	for _, req in ipairs(recipe.requiredItems or {}) do
		local foundStack
		local itemCount = 0
		for _, stack in ipairs(inv.Inventory) do
			if stack.Name == req.item then
				itemCount = #stack.Items
				if itemCount >= req.amount then
					foundStack = stack
				end
				break
			end
		end
		if (not foundStack) or (itemCount < req.amount) then
			table.insert(missing, {item = req.item, required = req.amount, owned = itemCount})
		end
	end
	if #missing > 0 then
		print("[DEBUG] Missing ingredients for", player.Name, ":")
		for _, info in ipairs(missing) do
			print(string.format("  - %s (owned: %d, required: %d)", info.item, info.owned, info.required))
		end
	end
	return missing
end

local function removeIngredients(player, recipe)
	local inv = InventoryServer.AllInventories[player]
	print("[DEBUG] Removing ingredients for", player.Name)
	for _, req in ipairs(recipe.requiredItems or {}) do
		for _, stack in ipairs(inv.Inventory) do
			if stack.Name == req.item then
				print("[DEBUG] Found stack for", req.item, "with", #stack.Items, "items. Removing", req.amount)
				for i = 1, req.amount do
					local tool = table.remove(stack.Items, 1)
					if tool then
						tool:Destroy()
						print("[DEBUG] Destroyed 1", req.item)
					else
						print("[DEBUG] Tried to remove", req.item, "but stack was empty.")
					end
				end
				if #stack.Items == 0 then
					print("[DEBUG] Stack for", req.item, "is now empty. Removing from inventory.")
					table.remove(inv.Inventory, table.find(inv.Inventory, stack))
					InventoryServer.UnequipFromHotbar(player, stack.StackId)
					InventoryServer.UnequipArmor(player, stack.StackId)
				end
				break
			end
		end
	end
end

local function addCraftedItems(player, recipe)
	local inv = InventoryServer.AllInventories[player]
	local backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
	print("[DEBUG] addCraftedItems called for player:", player.Name)
	print("[DEBUG] Recipe outputItem:", recipe.outputItem)
	print("[DEBUG] Type of outputItem:", typeof(recipe.outputItem))

	local outputs
	if type(recipe.outputItem) == "table" and recipe.outputItem[1] then
		outputs = recipe.outputItem
	else
		outputs = {recipe.outputItem}
	end

	print("[DEBUG] Outputs table length:", #outputs)
	for i, output in ipairs(outputs) do
		print(string.format("[DEBUG] Output %d: %s", i, output and output.item or tostring(output)))
		local outputName = output and output.item or "<nil>"
		print("[DEBUG] Trying to craft output:", outputName)
		local allItemsChildren = ServerStorage.AllItems:GetChildren()
		if #allItemsChildren == 0 then
			print("[DEBUG] ServerStorage.AllItems has NO children!")
		else
			print("[DEBUG] Listing AllItems children:")
			for _, obj in ipairs(allItemsChildren) do
				print("    [DEBUG] AllItems child:", obj.Name)
			end
		end
		local sample = ServerStorage.AllItems:FindFirstChild(output.item)
		print("[DEBUG] Sample found for", output.item, ":", sample ~= nil)
		if sample then
			for j = 1, (output.amount or 1) do
				local clone = sample:Clone()
				clone.Parent = backpack
				print("[DEBUG] Clone of", output.item, "parented to backpack. Name:", clone.Name)
				InventoryServer.RegisterItem(player, clone)
			end
		else
			print("[DEBUG] No sample item found for", output.item)
		end
	end
end

local function sendDebugMessage(player, message)
	local debugEvent = Events:FindFirstChild("DebugMessage")
	if debugEvent then
		debugEvent:FireClient(player, message)
	end
end

local function getCraftedString(recipe)
	if recipe.outputItem == nil then
		return "Unknown Item"
	end
	if type(recipe.outputItem) == "table" then
		if recipe.outputItem[1] and recipe.outputItem[1].item then
			return tostring(recipe.outputItem[1].item)
		else
			return "Unknown Item"
		end
	elseif recipe.outputItem and recipe.outputItem.item then
		return tostring(recipe.outputItem.item)
	else
		return "Unknown Item"
	end
end

CraftEvent.OnServerEvent:Connect(function(player, recipeName)
	print("[SERVER] CraftEvent received from", player.Name, "for recipe:", recipeName)
	local recipe = getRecipeByName(recipeName)
	if not recipe then
		sendDebugMessage(player, "Recipe not found!")
		print("[SERVER] Could not find recipe:", recipeName)
		return
	end

	local missing = getMissingIngredients(player, recipe)
	if #missing > 0 then
		local parts = {}
		for _, info in ipairs(missing) do
			table.insert(parts, string.format("%s (%d/%d)", info.item, info.owned, info.required))
		end
		local message = "Not enough ingredients! Missing: " .. table.concat(parts, ", ")
		sendDebugMessage(player, message)
		print("[SERVER]", message)
		return
	end

	print("[SERVER] Crafting successful for recipe:", recipeName)
	removeIngredients(player, recipe)
	addCraftedItems(player, recipe)
	sendDebugMessage(player, "Crafting successful! Crafted: " .. getCraftedString(recipe))
end)