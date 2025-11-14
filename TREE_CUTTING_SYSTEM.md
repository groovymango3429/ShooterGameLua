# Tree Cutting System

## Overview
This system allows players to cut down trees using axes or chainsaws to collect wood planks for crafting.

## Features

### Tools
Three types of tree-cutting tools are available:

1. **Wood Axe** (WOOD_AXE)
   - Tree Damage: 15 per hit
   - Cooldown: 1.0 seconds
   - Durability: 100 uses
   - Combat Damage: 30 (60 headshot)

2. **Metal Axe** (METAL_AXE)
   - Tree Damage: 25 per hit
   - Cooldown: 0.7 seconds
   - Durability: 200 uses
   - Combat Damage: 45 (90 headshot)

3. **Chainsaw** (CHAINSAW)
   - Tree Damage: 40 per hit
   - Cooldown: 0.4 seconds
   - Durability: 300 uses
   - Combat Damage: 60 (120 headshot)

4. **AXE** (Basic Axe - Updated)
   - Tree Damage: 20 per hit
   - Cooldown: 0.8 seconds
   - Durability: 150 uses
   - Combat Damage: 40 (80 headshot)

### Tree System
- Trees must be tagged with `CollectionService` tag: `"Tree"`
- Default tree health: 100 HP
- Trees respawn 60 seconds after being cut down
- Each tree drops 5 wood planks by default

#### Tree Configuration
You can customize trees by naming them according to these presets:
- **Oak Tree**: 100 HP, drops 5 wood
- **Pine Tree**: 80 HP, drops 4 wood
- **Birch Tree**: 70 HP, drops 3 wood

### Durability System
All tools with durability will:
- Lose durability on each hit (configurable per tool)
- Display remaining durability in the UI
- Break when durability reaches 0
- Show color-coded durability bar:
  - Green: > 60%
  - Yellow: 30-60%
  - Red: < 30%

## Setup Instructions

### 1. Create Tree Models
1. In Roblox Studio, create or import tree models into `workspace`
2. Ensure each tree model has a `PrimaryPart` set
3. Use `CollectionService` to add the `"Tree"` tag to each tree model
4. Optional: Name trees "Oak Tree", "Pine Tree", or "Birch Tree" for custom configs

### 2. Add Tree Template Folder (Optional)
For tree respawning to work properly:
1. Create a folder in `ServerStorage` named `"TreeTemplates"`
2. Store template copies of your trees there (with same names)
3. The system will clone these when respawning trees

### 3. Add Wood Resources
Ensure you have wood resource items in `ServerStorage.AllItems`:
- "Wood Plank" (recommended)
- Or "Plank", "Wooden Plank", or "Wood" as alternatives

### 4. Add Tool Items
Create Tool instances for the axes in `ServerStorage.AllItems`:
- WOOD_AXE
- METAL_AXE
- CHAINSAW
- AXE (if updating existing)

Set these attributes on each tool:
- `ItemType` = "Weapon"
- `IsDroppable` = true

## Usage

### For Players
1. Equip an axe or chainsaw from your hotbar
2. Aim at a tree
3. Left-click to swing
4. Tree health decreases with each hit
5. When tree is destroyed, wood planks are added to inventory
6. Watch durability bar at bottom of screen

### For Developers

#### Accessing Tree Data
```lua
local TreeManager = require(game.ServerScriptService.TreeManager)

-- Initialize trees (called automatically by Framework-Server)
TreeManager.InitializeTrees()

-- Damage a tree manually
local success = TreeManager.DamageTree(treeModel, 20, player)

-- Get tree data
local data = TreeManager.GetTreeData(treeModel)
-- data.health, data.maxHealth, data.woodAmount
```

#### Adding Custom Tree Types
Edit `TreeManager.lua` to add new tree configurations:
```lua
local TREE_CONFIGS = {
	["Oak Tree"] = {health = 100, woodAmount = 5},
	["Your Tree"] = {health = 150, woodAmount = 8},
}
```

## Files Modified/Created

### New Modules
- `src/ReplicatedStorage/Modules/WOOD_AXE.lua`
- `src/ReplicatedStorage/Modules/METAL_AXE.lua`
- `src/ReplicatedStorage/Modules/CHAINSAW.lua`

### New Server Scripts
- `src/ServerScriptService/TreeManager.lua`

### New Client Scripts
- `src/StarterPlayer/StarterPlayerScripts/DurabilityUI.client.lua`

### Modified Files
- `src/ServerScriptService/Framework-Server.server.lua` - Added tree detection and durability
- `src/ServerScriptService/Server/InventoryServer.lua` - Added durability tracking
- `src/ReplicatedStorage/Modules/AXE.lua` - Added tree cutting and durability

## Technical Details

### Melee Attack Flow
1. Player swings tool
2. Raycast from player's head position
3. Check if hit object is part of a tree (walks up ancestry)
4. If tree found:
   - Apply tree damage
   - Play chop sound
   - Reduce tool durability
   - Show hitmarker
   - Give wood if tree destroyed
5. If no tree, check for enemies (zombies/players)

### Durability Persistence
- Durability is stored as tool attributes: `Durability` and `MaxDurability`
- Tools are saved with inventory data
- Durability is initialized when tools are added to inventory
- Durability updates are synced to client for UI

## Troubleshooting

### Trees not taking damage
- Verify trees are tagged with `"Tree"` using CollectionService
- Check that tool config has `canCutTrees = true`
- Ensure player is within range (default 7-8 studs)

### Durability not showing
- Check that DurabilityUI.client.lua is running
- Verify tool has `hasDurability = true` in its config
- Make sure tool has Durability attributes set

### Wood not being given
- Verify wood item exists in ServerStorage.AllItems
- Check player inventory is not full
- Look for warnings in server output

### Trees not respawning
- Create ServerStorage.TreeTemplates folder
- Add tree templates with matching names
- Ensure original tree had a PrimaryPart

## Future Enhancements
- Add tree health bar UI above trees
- Add different chopping animations per tool type
- Add particle effects when tree is destroyed
- Add stump object that remains after tree is cut
- Add skill progression for faster tree cutting
- Add rare trees with valuable wood types
