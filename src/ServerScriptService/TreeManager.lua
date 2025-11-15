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
		TreeManager.FellTree(tree)
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
		-- Try alternative names
		woodSample = SS.AllItems:FindFirstChild("Plank") 
			or SS.AllItems:FindFirstChild("Wooden Plank")
			or SS.AllItems:FindFirstChild("Wood")
	end

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

-- Make tree fall with physics
function TreeManager.FellTree(tree)
	if not tree then return end

	-- Ensure tree has PrimaryPart set
	if not tree.PrimaryPart then
		warn("TreeManager: Tree", tree.Name, "has no PrimaryPart set. Cannot fell tree properly.")
		-- Still try to clean up the tree
		task.delay(3, function()
			if tree and tree.Parent then
				tree:Destroy()
			end
		end)
		return
	end

	-- Store original properties for respawning
	local originalPosition = tree:GetPrimaryPartCFrame()
	local treeName = tree.Name

	-- Find trunk and foliage parts
	local trunk = tree:FindFirstChild("Trunk") or tree.PrimaryPart
	local foliage = tree:FindFirstChild("Foliage") or tree:FindFirstChild("Leaves")

	-- Play tree fall sound
	local fallSound = ReplicatedStorage:FindFirstChild("Sounds")
	if fallSound then
		fallSound = fallSound:WaitForChild("TreeFall")
		if fallSound and fallSound:IsA("Sound") then
			local soundClone = fallSound:Clone()
			soundClone.Parent = trunk or tree.PrimaryPart
			soundClone:Play()
			game:GetService("Debris"):AddItem(soundClone, soundClone.TimeLength)
		end
	end

	-- Make foliage disappear
	if foliage then
		-- Fade out foliage
		task.spawn(function()
			local descendants = foliage:GetDescendants()
			local transparentParts = {}
			for _, obj in ipairs(descendants) do
				if obj:IsA("BasePart") then
					table.insert(transparentParts, obj)
				end
			end

			for i = 0, 1, 0.1 do
				for _, part in ipairs(transparentParts) do
					part.Transparency = i
				end
				task.wait(0.05)
			end
			foliage:Destroy()
		end)
	end

	-- Make trunk fall with physics
	if trunk and trunk:IsA("BasePart") then
		trunk.Anchored = false
		trunk.CanCollide = true

		-- Apply force to make it fall
		local direction = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
		local force = Instance.new("BodyForce")
		force.Force = direction * trunk:GetMass() * 50 + Vector3.new(0, -trunk:GetMass() * 100, 0)
		force.Parent = trunk

		-- Apply angular velocity for rotation as it falls
		local angularVelocity = Instance.new("BodyAngularVelocity")
		angularVelocity.AngularVelocity = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
		angularVelocity.MaxTorque = Vector3.new(4000, 0, 4000)
		angularVelocity.Parent = trunk

		-- Clean up physics forces after trunk falls
		task.delay(2, function()
			if force and force.Parent then force:Destroy() end
			if angularVelocity and angularVelocity.Parent then angularVelocity:Destroy() end
		end)
	end

	-- Remove tree data
	TreeManager.TreeData[tree] = nil

	-- Respawn tree after delay
	task.spawn(function()
		task.wait(3) -- Wait for falling animation
		if tree and tree.Parent then
			tree:Destroy()
		end

		task.wait(57) -- Total 60 seconds respawn time

		-- Create new tree at same location
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
