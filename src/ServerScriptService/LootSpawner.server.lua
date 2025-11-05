-- Place this script in ServerScriptService

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local ALL_ITEMS = ServerStorage:WaitForChild("AllItems")
local LOOT_SPAWNS = Workspace:WaitForChild("LootSpawns")
local RESPAWN_TIME = 60 -- seconds between respawns

-- RemoteEvent for secure pickup
local lootPickupEvent = Instance.new("RemoteEvent")
lootPickupEvent.Name = "LootPickupEvent"
lootPickupEvent.Parent = ReplicatedStorage

-- Give unique names to loot spawn parts if duplicates exist
local function assignUniqueNamesToSpawns()
	local nameCount = {}
	for _, part in ipairs(LOOT_SPAWNS:GetChildren()) do
		if part:IsA("BasePart") then
			local baseName = part.Name
			nameCount[baseName] = (nameCount[baseName] or 0) + 1
			if nameCount[baseName] > 1 then
				part.Name = baseName .. "_" .. tostring(nameCount[baseName])
			end
		end
	end
end

-- Utility: get eligible items for a spawn category and that are "naturally spawnable"
local function getItemsForCategory(category)
	local candidates = {}
	for _, tool in ipairs(ALL_ITEMS:GetChildren()) do
		local rarity = tool:GetAttribute("Rarity")
		local naturallySpawnable = tool:GetAttribute("NaturallySpawnable")
		if naturallySpawnable and rarity and rarity <= category then
			table.insert(candidates, tool)
		end
	end
	return candidates
end

local ActiveLoot = {} -- [tool] = {Part = part}

-- Utility: spawn a loot tool at a part
local function spawnLootItem(part, toolTemplate)
	local toolClone = toolTemplate:Clone()
	toolClone.Parent = Workspace

	-- Set all parts Anchored & non-collidable
	for _, descendant in ipairs(toolClone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		end
	end

	-- Place at part position
	if toolClone:FindFirstChild("Handle") then
		toolClone.Handle.CFrame = part.CFrame + Vector3.new(0, toolClone.Handle.Size.Y/2 + 1, 0)
	end

	-- Tag for collection
	CollectionService:AddTag(toolClone, "LootItem")

	-- Attach BillboardGui for hover
	local guiTemplate = ReplicatedStorage:FindFirstChild("LootItemBillboardGui")
	if guiTemplate and toolClone:FindFirstChild("Handle") then
		local guiClone = guiTemplate:Clone()
		local nameLabel = guiClone:FindFirstChild("Frame") and guiClone.Frame:FindFirstChild("Name")
		if nameLabel and nameLabel:IsA("TextLabel") then
			nameLabel.Text = toolTemplate.Name
		end
		guiClone.Parent = toolClone.Handle
	end

	-- Store reference to which part spawned this item
	toolClone:SetAttribute("LootSpawnPart", part.Name)
	ActiveLoot[toolClone] = {
		Part = part,
		SpawnTime = tick()
	}
end

-- Remove loot for a part
local function removeLootForPart(part)
	for loot, info in pairs(ActiveLoot) do
		if loot and loot.Parent and loot:GetAttribute("LootSpawnPart") == part.Name then
			loot:Destroy()
			ActiveLoot[loot] = nil
		end
	end
	for _, tool in ipairs(CollectionService:GetTagged("LootItem")) do
		if tool:GetAttribute("LootSpawnPart") == part.Name then
			tool:Destroy()
			ActiveLoot[tool] = nil
		end
	end
end

-- Spawn one item at a part based on its attributes
function spawnItemsAtPart(part)
	removeLootForPart(part)
	local category = part:GetAttribute("LootCategory") or 1
	local candidates = getItemsForCategory(category)
	if #candidates == 0 then return end

	local toolTemplate = candidates[math.random(1, #candidates)]
	spawnLootItem(part, toolTemplate)
end

-- Assign unique names before spawning
assignUniqueNamesToSpawns()

-- Initial spawn for EACH part in LootSpawns
for _, part in ipairs(LOOT_SPAWNS:GetChildren()) do
	if part:IsA("BasePart") then
		spawnItemsAtPart(part)
	end
end

-- Listen for new spawn points added at runtime
LOOT_SPAWNS.ChildAdded:Connect(function(child)
	if child:IsA("BasePart") then
		assignUniqueNamesToSpawns()
		spawnItemsAtPart(child)
	end
end)

-- ANTI-CHEAT + SECURE PICKUP
lootPickupEvent.OnServerEvent:Connect(function(player, tool)
	-- Validate tool is loot, still exists, etc
	if not tool or not ActiveLoot[tool] then return end
	if not tool:IsDescendantOf(Workspace) then return end
	if not tool:FindFirstChild("Handle") then return end

	-- Validate distance (anti-cheat)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local lootPos = tool.Handle.Position
	local playerPos = hrp.Position
	local dist = (lootPos - playerPos).Magnitude
	if dist > 10 then return end -- anti-cheat: max pickup distance

	-- All checks passed, give item
	tool.Parent = player.Backpack
	if tool.Handle:FindFirstChild("LootItemBillboardGui") then
		tool.Handle.LootItemBillboardGui:Destroy()
	end
	ActiveLoot[tool] = nil

	-- Respawn at this part after delay
	local part = Workspace.LootSpawns:FindFirstChild(tool:GetAttribute("LootSpawnPart"))
	if part then
		task.spawn(function()
			task.wait(RESPAWN_TIME)
			spawnItemsAtPart(part)
		end)
	end

	-- Remove from world after a short delay
	task.wait(0.1)
	if tool and tool.Parent == player.Backpack then
		-- Let inventory handle stack
	else
		tool:Destroy()
	end
end)