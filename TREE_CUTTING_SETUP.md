# Tree Cutting System - Setup Guide

## Quick Start for Developers

This guide helps you quickly set up the tree cutting system in your game.

### Prerequisites
The system is already implemented in code. You just need to set up the game assets.

### Step 1: Create Wood Resource Item
1. Open Roblox Studio
2. Go to `ServerStorage.AllItems`
3. Create a new Tool object named "Wood Plank" (or use existing)
4. Set these properties:
   - ToolTip: "Wooden planks for crafting"
   - TextureId: (your wood texture)
5. Set these attributes:
   - ItemType: "Resource"
   - IsDroppable: true

### Step 2: Create Tree Models
1. Create or import tree models into `workspace`
2. For each tree:
   - Set a PrimaryPart (usually the trunk)
   - Use CollectionService to add tag "Tree"
   - Optionally name it "Oak Tree", "Pine Tree", or "Birch Tree"

#### Using CollectionService in Studio:
```lua
-- Run this in Command Bar to tag existing trees:
local CS = game:GetService("CollectionService")
for _, tree in pairs(workspace:GetChildren()) do
    if tree.Name:find("Tree") then
        CS:AddTag(tree, "Tree")
        print("Tagged:", tree.Name)
    end
end
```

### Step 3: Create Tool Items
Create Tool objects in `ServerStorage.AllItems` for each axe:

#### WOOD_AXE
- ToolTip: "Basic wood axe for cutting trees"
- TextureId: (your wood axe texture)
- Attributes:
  - ItemType: "Weapon"
  - IsDroppable: true

#### METAL_AXE
- ToolTip: "Metal axe for efficient tree cutting"
- TextureId: (your metal axe texture)
- Attributes:
  - ItemType: "Weapon"
  - IsDroppable: true

#### CHAINSAW
- ToolTip: "Powerful chainsaw for rapid tree cutting"
- TextureId: (your chainsaw texture)
- Attributes:
  - ItemType: "Weapon"
  - IsDroppable: true

### Step 4: (Optional) Set Up Tree Templates
For tree respawning:
1. Create folder `ServerStorage.TreeTemplates`
2. Copy your tree models into this folder
3. Trees will clone from here when respawning

### Step 5: Test
1. Play test your game
2. Give yourself an axe using your inventory system
3. Equip the axe
4. Swing at a tree
5. Watch durability bar appear
6. Collect wood planks when tree is destroyed

## Verification Checklist
- [ ] Trees are tagged with "Tree"
- [ ] Wood Plank item exists in ServerStorage.AllItems
- [ ] Tool items exist in ServerStorage.AllItems
- [ ] Tools have correct attributes set
- [ ] Can equip axe from inventory
- [ ] Durability bar appears when axe equipped
- [ ] Tree takes damage when hit
- [ ] Wood planks appear in inventory
- [ ] Durability decreases with each hit
- [ ] Tool breaks at 0 durability

## Common Issues

### "Wood Plank item not found" Warning
**Solution**: Create "Wood Plank" item in ServerStorage.AllItems

### Trees Not Tagged
**Solution**: Use CollectionService to add "Tree" tag to tree models

### Durability Bar Not Showing
**Solution**: Make sure DurabilityUI.client.lua is in StarterPlayerScripts

### Tool Not Cutting Trees
**Solution**: 
1. Verify tool module exists in ReplicatedStorage.Modules
2. Check tool config has `canCutTrees = true`
3. Ensure tree is within range (7-8 studs)

## Testing Commands

Give yourself items via command bar (if you have admin tools):
```lua
-- Give wood axe to player
local player = game.Players:FindFirstChild("YourUsername")
local axe = game.ServerStorage.AllItems.WOOD_AXE:Clone()
axe.Parent = player.Backpack

-- Give wood planks
local wood = game.ServerStorage.AllItems["Wood Plank"]:Clone()
wood.Parent = player.Backpack
```

## Configuration

### Adjust Tree Health
Edit `TreeManager.lua`:
```lua
local TREE_CONFIGS = {
    ["Oak Tree"] = {health = 100, woodAmount = 5},
    ["Your Tree"] = {health = 200, woodAmount = 10}, -- Add your tree
}
```

### Adjust Tool Stats
Edit tool module (e.g., `WOOD_AXE.lua`):
```lua
treeDamage = 15,  -- Damage per hit
cooldown = 1.0,   -- Seconds between swings
maxDurability = 100,  -- Total uses
durabilityLossPerHit = 1,  -- Durability lost per swing
```

### Adjust Respawn Time
Edit `TreeManager.lua` line 101:
```lua
task.wait(60) -- Change to your desired seconds
```

## Support
See TREE_CUTTING_SYSTEM.md for detailed technical documentation.
