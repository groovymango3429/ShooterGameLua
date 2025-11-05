local CraftingSystem = {}
local RecipeDatabase = require(game.ReplicatedStorage.Modules.RecipeDatabase)
local InventoryServer = require(game.ServerScriptService.Server.InventoryServer) -- Reference your inventory module

-- Check if player can craft a recipe
function CraftingSystem.CanCraft(player, recipe)
	local inv = InventoryServer.AllInventories[player]
	if not inv then return false, "No inventory" end

	local missing = {}
	for _, req in ipairs(recipe.requiredItems) do
		local found = 0
		for _, stack in ipairs(inv.Inventory) do
			if stack.Name == req.item then
				found = found + #stack.Items
			end
		end
		if found < req.amount then
			table.insert(missing, req.item)
		end
	end

	-- Skill check (optional)
	if recipe.skillRequired then
		-- Example: player:GetAttribute("Carpentry") or from your skills module
		for skill, level in pairs(recipe.skillRequired) do
			if (player:GetAttribute(skill) or 0) < level then
				table.insert(missing, "Skill: " .. skill)
			end
		end
	end

	-- Station check (optional)
	if recipe.station and recipe.station ~= "None" then
		-- Example: check CollectionService tag near player
		-- Add logic here
	end

	return #missing == 0, missing
end

-- Actually craft the recipe
function CraftingSystem.Craft(player, recipe, times)
	local success, missing = CraftingSystem.CanCraft(player, recipe)
	if not success then return false, missing end

	-- Remove required items
	for _, req in ipairs(recipe.requiredItems) do
		for i = 1, req.amount * times do
			InventoryServer.RemovePlacedItem(player, req.item)
		end
	end

	-- Add output item
	-- Example: find item sample and clone
	local sample = game.ServerStorage.AllItems:FindFirstChild(recipe.outputItem)
	if sample then
		local clone = sample:Clone()
		clone.Parent = player.Backpack
		InventoryServer.RegisterItem(player, clone)
	end

	return true
end

return CraftingSystem