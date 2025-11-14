# Setup Guide for Tree Chopping & Backpack System

## Overview
This guide explains how to set up the required assets for the enhanced tree chopping system and backpack drop system.

## Tree Chopping System Setup

### 1. Sound Assets Required

You need to add the following sounds to your game:

#### Wood Impact Sound
- **Location**: `ReplicatedStorage/Sounds/WoodImpact`
- **Type**: Sound instance
- **Purpose**: Plays when an axe hits a tree (distinct from zombie hit sounds)
- **Recommended**: A wooden thud or chop sound effect

#### Tree Fall Sound
- **Location**: `ReplicatedStorage/Sounds/TreeFall`
- **Type**: Sound instance
- **Purpose**: Plays when a tree falls over after being cut down
- **Recommended**: A tree falling/cracking sound effect

**Setup Instructions:**
1. In Roblox Studio, navigate to ReplicatedStorage
2. Create a Folder named "Sounds" (if it doesn't exist)
3. Inside the Sounds folder, add your sound assets:
   - Upload a wood impact sound and name it "WoodImpact"
   - Upload a tree fall sound and name it "TreeFall"

### 2. Tree Model Structure

For the falling physics to work properly, your tree models should have:

- **Trunk**: A part or model named "Trunk" (this is what will fall with physics)
- **Foliage**: A part or model named "Foliage" or "Leaves" (this will fade out when tree is cut)
- **PrimaryPart**: Set on the tree model (required for positioning)
- **CollectionService Tag**: Tagged as "Tree"

**Example Tree Structure:**
```
TreeModel
├── Trunk (Part/Model) - Will fall with physics
├── Foliage (Part/Model) - Will fade out
└── (Set PrimaryPart to Trunk)
```

### 3. How It Works

When a tree is cut down:
1. Wood impact sound plays on each hit
2. Tree fall sound plays when tree health reaches 0
3. Foliage fades out over 0.5 seconds
4. Trunk becomes unanchored and falls with physics (force + angular velocity)
5. After 3 seconds, tree model is destroyed
6. After 60 seconds total, tree respawns from ServerStorage/TreeTemplates

## Durability UI System Setup

The durability system now supports custom UI!

### Option 1: Use Default UI (No Setup Required)
The system will automatically create a durability bar at the bottom of the screen.

### Option 2: Use Custom UI

Create your own durability display:

1. In StarterGui or PlayerGui, create a ScreenGui named **"DurabilityScreen"**
2. Add a Frame inside it
3. Inside the Frame, add two TextLabels:
   - **"Item Name"** - Will display the tool name
   - **"Item Durability"** - Will display durability as "50/100"

**Example Structure:**
```
DurabilityScreen (ScreenGui)
└── Frame
    ├── Item Name (TextLabel)
    └── Item Durability (TextLabel)
```

The system will automatically detect your custom UI and use it instead of creating the default bar.

## Backpack Drop System Setup

### 1. Backpack Model (Optional)

You can customize the backpack model that spawns when players die:

- **Location**: `ReplicatedStorage/BackpackModel`
- **Type**: Model
- **Purpose**: The model that appears on the ground with player's items

**Setup Instructions:**
1. Create or import a backpack model
2. Set a PrimaryPart (this is where the ProximityPrompt will be attached)
3. Name it "BackpackModel"
4. Place it in ReplicatedStorage

**If you don't create a custom model**, the system will automatically create a simple backpack with a default mesh.

### 2. How It Works

When a player dies:
1. A backpack spawns at their death location
2. All inventory items (from Backpack and equipped) are stored in the backpack
3. The backpack has a ProximityPrompt (Press E to loot)
4. Other players (or the same player after respawning) can loot it
5. If the looter's inventory has space, all items transfer
6. If inventory is full, only items that fit are transferred
7. Backpack remains with leftover items if inventory was full
8. Backpack is destroyed when all items are looted

### 3. Looting System

- **Activation**: Press E near the backpack (within 8 studs)
- **Feedback**: Player receives a message indicating how many items were looted
- **Inventory Full**: System checks inventory space and only transfers what fits
- **Remaining Items**: Backpack stays if items couldn't be transferred

## Testing Checklist

### Tree Chopping
- [ ] Verify wood impact sound plays when hitting trees
- [ ] Verify tree fall sound plays when tree is destroyed
- [ ] Verify foliage fades out
- [ ] Verify trunk falls with physics
- [ ] Verify tree respawns after 60 seconds

### Durability UI
- [ ] Test with default UI (no custom ScreenGui)
- [ ] Test with custom DurabilityScreen ScreenGui
- [ ] Verify item name updates when switching tools
- [ ] Verify durability updates correctly

### Backpack Drop
- [ ] Verify backpack spawns on death with all items
- [ ] Verify ProximityPrompt appears when near backpack
- [ ] Verify looting works (E key)
- [ ] Verify partial transfer when inventory is full
- [ ] Verify backpack disappears when all items looted
- [ ] Verify backpack remains with leftover items

## Troubleshooting

### Trees Not Falling
- Ensure tree model has a part/model named "Trunk"
- Verify PrimaryPart is set on the tree model
- Check that tree is tagged with "Tree" using CollectionService

### Sounds Not Playing
- Verify sounds are in ReplicatedStorage/Sounds/
- Check sound names are exactly "WoodImpact" and "TreeFall"
- Ensure sounds are Sound instances, not folders

### Durability UI Not Showing
- For custom UI: Verify ScreenGui is named "DurabilityScreen"
- For custom UI: Verify TextLabels are named "Item Name" and "Item Durability"
- Check that tool has durability attributes set

### Backpack Not Spawning
- Verify BackpackDropSystem is started in init.server.lua
- Check player had items in inventory when they died
- Look for error messages in server output

### Can't Loot Backpack
- Ensure ProximityPrompt is enabled and visible
- Check player is within 8 studs of backpack
- Verify inventory has space (or expect partial transfer message)
- Look for error messages in output

## Additional Notes

- The system is fully integrated with the existing inventory system
- Durability tracking works automatically for tools with hasDurability = true
- Backpack drop system respects the existing inventory space limits
- All changes are minimal and backward compatible
