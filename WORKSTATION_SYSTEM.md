# Workstation Interaction System

This document explains the workstation interaction system that allows players to craft items at specific workstations.

## Overview

The workstation system allows players to interact with crafting stations (Furnace, Workbench, Saw) in the game world. When near a workstation, players can press `E` to open the crafting menu, which will show only recipes that can be crafted at that station.

## Components

### Client-Side
- **WorkstationClient.client.lua**: Detects nearby workstations and handles player interaction (E key press)
- **CraftingClient.client.lua**: Updated to filter recipes by station and display the station name

### Server-Side
- **WorkstationServer.server.lua**: Validates workstation interactions and opens the crafting GUI
- **WorkstationSetup.server.lua**: Automatically adds BillboardGui prompts to workstations
- **CraftingServer.server.lua**: Already validates recipes and station proximity (unchanged)

### Shared
- **CraftingSystem.lua**: Updated to validate station proximity during crafting
- **RecipeDatabase.lua**: Updated with Furnace and Saw recipes

## Setup Instructions

### 1. Create Workstations Folder

In Workspace, create a folder named `Workstations`:

```
Workspace
  └─ Workstations
      ├─ Furnace (Model)
      ├─ Workbench (Model)
      └─ Saw (Model)
```

### 2. Workstation Structure

Each workstation should be a Model or BasePart with the following properties:

- **Name**: The station name (e.g., "Furnace", "Workbench", "Saw")
- **PrimaryPart**: (Optional but recommended) The main part of the workstation
- **ProximityDetector**: (Optional) A part used to detect player proximity

If the workstation is a Model, it should contain at least one BasePart.

### 3. BillboardGui Setup

The `WorkstationSetup.server.lua` script will automatically create and attach BillboardGui prompts to each workstation. The prompts will:

- Display "Press [E] to Use [Station Name]"
- Only appear when the player is within 10 studs
- Only show one prompt at a time (for the nearest/looked-at station)

### 4. Recipe Configuration

Recipes in `RecipeDatabase.lua` use the `station` field to specify which workstation they require:

```lua
{
    id = "iron_ingot",
    name = "Iron Ingot",
    category = "Materials",
    requiredItems = {
        {item = "Scrap Metal", amount = 3},
        {item = "Charcoal", amount = 1},
    },
    outputItem = {item = "Iron Ingot", amount = 1},
    station = "Furnace",  -- Requires Furnace workstation
}
```

**Station values:**
- `"None"` - Can be crafted anywhere (no workstation required)
- `"Furnace"` - Requires Furnace workstation
- `"Workbench"` - Requires Workbench workstation
- `"Saw"` - Requires Saw workstation
- Other custom station names as needed

## How It Works

### Player Interaction Flow

1. Player approaches a workstation (within 10 studs)
2. BillboardGui prompt appears: "Press [E] to Use [Station Name]"
3. Player presses `E`
4. WorkstationClient fires `OpenCraftingMenu` event to server with station name
5. WorkstationServer validates:
   - Player has a character
   - Workstation exists
   - Player is within 12 studs (server-side check)
6. Server fires `OpenCraftingGUI` event back to client with station name
7. CraftingClient opens the crafting menu and filters recipes:
   - Shows recipes where `station == stationName`
   - Also shows recipes where `station == "None"`
8. UI displays "Crafting at: [Station Name]"

### Crafting Validation

When the player attempts to craft:

1. Player selects a recipe and clicks "Craft"
2. CraftingClient fires `CraftEvent` to server
3. CraftingServer validates:
   - Recipe exists
   - Player has required ingredients
   - CraftingSystem.CanCraft checks:
     - Ingredient availability
     - Station proximity (if recipe requires a station)
4. If valid, server removes ingredients and adds crafted item
5. Server sends feedback to client

## Added Recipes

### Furnace Recipes
- **Iron Ingot**: 3 Scrap Metal + 1 Charcoal → 1 Iron Ingot
- **Brick**: 3 Stone → 1 Brick
- **Charcoal**: 2 Wood → 1 Charcoal

### Saw Recipes
- **Wooden Plank**: 1 Wood Log → 2 Wooden Planks
- **Reinforced Wall**: 4 Wooden Planks + 2 Scrap Metal → 1 Reinforced Wall (requires Workbench)

## Customization

### Adding New Workstations

1. Create a new Model/Part in `Workspace/Workstations`
2. Name it appropriately (e.g., "Chemistry Lab")
3. WorkstationSetup will automatically add the BillboardGui
4. Add recipes with `station = "Chemistry Lab"` to RecipeDatabase

### Adding New Recipes

In `RecipeDatabase.lua`, add new recipe entries:

```lua
{
    id = "unique_id",
    name = "Display Name",
    category = "Category",
    requiredItems = {
        {item = "Item 1", amount = 2},
        {item = "Item 2", amount = 1},
    },
    outputItem = {item = "Output Item", amount = 1},
    station = "WorkstationName",  -- Or "None" for anywhere
}
```

## Troubleshooting

### BillboardGui Not Showing
- Ensure workstation has at least one BasePart
- Check that WorkstationSetup.server.lua is running
- Verify player is within 10 studs of the workstation

### Recipe Not Appearing
- Check that `recipe.station` matches the workstation name exactly
- Verify the recipe category is correct
- Ensure you're opening the crafting menu through the workstation (not pressing T)

### Crafting Fails
- Verify player has all required ingredients
- Check that player is within 10 studs of the required workstation
- Look for error messages in server console

### Can't Interact with Workstation
- Ensure `Workspace/Workstations` folder exists
- Verify workstation name matches exactly
- Check that OpenCraftingMenu RemoteEvent exists in ReplicatedStorage/Events

## Manual Testing

To test the workstation system:

1. Create a Workstations folder in Workspace
2. Add at least one workstation (e.g., a Part named "Furnace")
3. Start the game
4. Verify BillboardGui appears when near the workstation
5. Press E to open the crafting menu
6. Verify "Crafting at: Furnace" appears in the UI
7. Verify only Furnace and "None" recipes are shown
8. Try crafting a Furnace recipe
9. Press T to open the normal crafting menu (no station filter)
10. Verify all recipes are shown when opened with T

## API Reference

### Events (in ReplicatedStorage/Events)

- **OpenCraftingMenu**: Client → Server
  - Parameters: `stationName` (string)
  - Fired when player presses E at a workstation

- **OpenCraftingGUI**: Server → Client
  - Parameters: `stationName` (string)
  - Tells client to open crafting GUI with station filter

- **CraftEvent**: Client → Server
  - Parameters: `recipeName` (string)
  - Existing event for crafting items

### Functions

**CraftingSystem.CanCraft(player, recipe)**
- Validates if a player can craft a recipe
- Checks ingredients, skills, and station proximity
- Returns: `success` (boolean), `missing` (table)

**RecipeDatabase:GetByCategory(category)**
- Returns all recipes in a category
- Parameters: `category` (string)
- Returns: array of recipes

## Notes

- Station names are case-sensitive
- Distance checks use magnitude comparison (Euclidean distance)
- Server-side distance check (12 studs) is slightly larger than client-side (10 studs) to account for network lag
- Only one workstation prompt can be visible at a time (the nearest/looked-at one)
- The "T" key still opens the crafting menu without station filtering for general crafting
