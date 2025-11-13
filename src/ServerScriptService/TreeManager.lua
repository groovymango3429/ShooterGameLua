local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local TreeManager = {}
TreeManager.TreeData = {}

-- Tree configuration
local TREE_CONFIGS = {
	["Oak Tree"] = {health = 100, woodAmount = 5},
	["Pine Tree"] = {health = 80, woodAmount = 4},
	["Birch Tree"] = {health = 70, woodAmount = 3},
}

-- Initialize trees in the workspace
function TreeManager.InitializeTrees()
	-- Find all models tagged as "Tree" in workspace
	for _, tree in pairs(CollectionService:GetTagged("Tree")) do
		if tree:IsA("Model") and not TreeManager.TreeData[tree] then
			local config = TREE_CONFIGS[tree.Name] or {health = 100, woodAmount = 5}
			TreeManager.TreeData[tree] = {
				health = config.health,
				maxHealth = config.health,
				woodAmount = config.woodAmount,
			}
		end
	end
end

-- Handle tree damage
function TreeManager.DamageTree(tree, damage, player)
	if not tree or not tree:IsA("Model") then return false end
	
	local treeData = TreeManager.TreeData[tree]
	if not treeData then
		-- Initialize tree if not already tracked
		local config = TREE_CONFIGS[tree.Name] or {health = 100, woodAmount = 5}
		treeData = {
			health = config.health,
			maxHealth = config.health,
			woodAmount = config.woodAmount,
		}
		TreeManager.TreeData[tree] = treeData
	end
	
	treeData.health = treeData.health - damage
	
	if treeData.health <= 0 then
		-- Tree is destroyed, give wood to player
		TreeManager.GiveWoodToPlayer(player, treeData.woodAmount)
		TreeManager.RespawnTree(tree)
		return true
	end
	
	return false
end

-- Give wood to player's inventory
function TreeManager.GiveWoodToPlayer(player, amount)
	if not player or amount <= 0 then return end
	
	-- Find or create wood planks in player's backpack
	local SS = game:GetService("ServerStorage")
	local woodSample = SS.AllItems:FindFirstChild("Wood Plank")
	
	if not woodSample then
		warn("Wood Plank item not found in ServerStorage.AllItems")
		return
	end
	
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end
	
	for i = 1, amount do
		local wood = woodSample:Clone()
		wood.Parent = backpack
	end
end

-- Respawn tree after it's cut down
function TreeManager.RespawnTree(tree)
	if not tree then return end
	
	-- Store original properties
	local originalPosition = tree:GetPrimaryPartCFrame()
	local treeName = tree.Name
	
	-- Remove tree
	tree:Destroy()
	TreeManager.TreeData[tree] = nil
	
	-- Respawn after delay
	task.spawn(function()
		task.wait(60) -- 60 seconds respawn time
		
		-- Create new tree at same location (simplified)
		-- In a real implementation, you'd clone from a template
		local newTree = game:GetService("ServerStorage"):FindFirstChild("TreeTemplates")
		if newTree then
			newTree = newTree:FindFirstChild(treeName)
			if newTree then
				local clone = newTree:Clone()
				clone:SetPrimaryPartCFrame(originalPosition)
				clone.Parent = workspace
				CollectionService:AddTag(clone, "Tree")
				TreeManager.InitializeTrees()
			end
		end
	end)
end

-- Get tree data
function TreeManager.GetTreeData(tree)
	return TreeManager.TreeData[tree]
end

return TreeManager
