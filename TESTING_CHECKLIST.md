# Workstation System Testing Checklist

This document provides a comprehensive testing checklist for the workstation interaction system.

## Setup Verification

Before testing, ensure the following setup is complete:

### 1. Workspace Structure
- [ ] `Workspace/Workstations` folder exists
- [ ] At least one workstation model/part exists in the Workstations folder
  - [ ] Workstation named "Furnace" (for testing Furnace recipes)
  - [ ] Workstation named "Workbench" (for testing Workbench recipes)
  - [ ] Workstation named "Saw" (for testing Saw recipes)

### 2. Each Workstation Has
- [ ] Either a PrimaryPart set OR is a BasePart itself
- [ ] BillboardGui named "InteractionPrompt" (auto-created by WorkstationSetup)

### 3. Required Items in ServerStorage
For testing the new recipes, ensure these items exist in `ServerStorage/AllItems`:
- [ ] Scrap Metal
- [ ] Charcoal
- [ ] Stone
- [ ] Wood
- [ ] Wood Log
- [ ] Wooden Plank
- [ ] Iron Ingot (output)
- [ ] Brick (output)

## Functional Testing

### Test 1: Workstation Detection
1. [ ] Start the game
2. [ ] Approach a workstation (get within 10 studs)
3. [ ] **Expected**: BillboardGui prompt appears with text "Press [E] to Use [WorkstationName]"
4. [ ] Walk away from the workstation (beyond 10 studs)
5. [ ] **Expected**: BillboardGui prompt disappears

### Test 2: Multiple Workstations
1. [ ] Place 2+ workstations within 15 studs of each other
2. [ ] Approach the area
3. [ ] **Expected**: Only ONE prompt appears at a time (the nearest/looked-at one)
4. [ ] Look directly at a different workstation
5. [ ] **Expected**: Prompt switches to the one you're looking at

### Test 3: Workstation Interaction - Furnace
1. [ ] Approach a Furnace workstation
2. [ ] Press `E` key
3. [ ] **Expected**: Crafting GUI opens
4. [ ] **Expected**: UI shows "Crafting at: Furnace" (if StationTitle label exists)
5. [ ] Browse recipes
6. [ ] **Expected**: Only Furnace recipes AND recipes with station="None" are visible
7. [ ] **Expected**: Recipes requiring Workbench/Saw are NOT visible

### Test 4: Workstation Interaction - Saw
1. [ ] Approach a Saw workstation
2. [ ] Press `E` key
3. [ ] **Expected**: Crafting GUI opens with "Crafting at: Saw"
4. [ ] Browse recipes
5. [ ] **Expected**: Only Saw recipes AND recipes with station="None" are visible

### Test 5: Workstation Interaction - Workbench
1. [ ] Approach a Workbench workstation
2. [ ] Press `E` key
3. [ ] **Expected**: Crafting GUI opens with "Crafting at: Workbench"
4. [ ] Browse recipes
5. [ ] **Expected**: Only Workbench recipes AND recipes with station="None" are visible

### Test 6: Manual Crafting Menu (T Key)
1. [ ] Press `T` key (not near any workstation)
2. [ ] **Expected**: Crafting GUI opens
3. [ ] **Expected**: NO station filter - all recipes are visible
4. [ ] **Expected**: No "Crafting at: X" text shown

### Test 7: Recipe Filtering by Category
1. [ ] Open crafting at Furnace (press E)
2. [ ] Click "Materials" category
3. [ ] **Expected**: Furnace material recipes shown (Iron Ingot, Brick, Charcoal)
4. [ ] Click "All" category
5. [ ] **Expected**: All Furnace + None recipes shown

### Test 8: Crafting at Workstation - Success
1. [ ] Give yourself required items for "Iron Ingot":
   - 3x Scrap Metal
   - 1x Charcoal
2. [ ] Approach Furnace and open crafting (E key)
3. [ ] Select "Iron Ingot" recipe
4. [ ] Click "Craft"
5. [ ] **Expected**: Items are consumed
6. [ ] **Expected**: Iron Ingot is added to inventory
7. [ ] **Expected**: Success message appears

### Test 9: Crafting at Workstation - Too Far
1. [ ] Open crafting at Furnace (E key)
2. [ ] Select "Iron Ingot" recipe
3. [ ] Walk away from Furnace (> 10 studs)
4. [ ] Click "Craft"
5. [ ] **Expected**: Crafting fails with message "Too far from Furnace"

### Test 10: Crafting Wrong Station
1. [ ] Open crafting at Workbench (E key)
2. [ ] Note: Should not see Furnace-only recipes
3. [ ] Open console and try to craft a Furnace recipe via manual command
4. [ ] **Expected**: Server rejects the craft due to station requirement

### Test 11: Charcoal Recipe (Furnace)
1. [ ] Give yourself 2x Wood
2. [ ] Approach Furnace and open crafting
3. [ ] Select "Charcoal" recipe
4. [ ] Click "Craft"
5. [ ] **Expected**: 2 Wood consumed, 1 Charcoal produced

### Test 12: Brick Recipe (Furnace)
1. [ ] Give yourself 3x Stone
2. [ ] Approach Furnace and open crafting
3. [ ] Select "Brick" recipe
4. [ ] Click "Craft"
5. [ ] **Expected**: 3 Stone consumed, 1 Brick produced

### Test 13: Wooden Plank Recipe (Saw)
1. [ ] Give yourself 1x Wood Log
2. [ ] Approach Saw and open crafting
3. [ ] Select "Wooden Plank" recipe
4. [ ] Click "Craft"
5. [ ] **Expected**: 1 Wood Log consumed, 2 Wooden Planks produced

### Test 14: Reinforced Wall Recipe (Workbench)
1. [ ] Give yourself:
   - 4x Wooden Plank
   - 2x Scrap Metal
2. [ ] Approach Workbench and open crafting
3. [ ] Select "Reinforced Wall" recipe
4. [ ] Click "Craft"
5. [ ] **Expected**: Materials consumed, 1 Reinforced Wall produced

### Test 15: Closing and Reopening
1. [ ] Open crafting at Furnace (E key)
2. [ ] Close GUI (ESC or click X)
3. [ ] Press `T` to reopen
4. [ ] **Expected**: Station filter is cleared, all recipes visible
5. [ ] Press E at Furnace again
6. [ ] **Expected**: Station filter re-applied

### Test 16: Station Not Found
1. [ ] Delete or rename the Furnace workstation
2. [ ] Have required items for Iron Ingot
3. [ ] Try to craft Iron Ingot from T menu
4. [ ] **Expected**: Error message "Station: Furnace not found"

## Edge Cases

### Test 17: No Workstations Folder
1. [ ] Delete or rename `Workspace/Workstations`
2. [ ] Start game
3. [ ] **Expected**: WorkstationClient loads without errors
4. [ ] **Expected**: Console shows warning from WorkstationSetup

### Test 18: Invalid Workstation (No Parts)
1. [ ] Create a Folder named "TestStation" in Workstations (not a Model/Part)
2. [ ] Approach it
3. [ ] **Expected**: No prompt appears
4. [ ] **Expected**: Console may show warning from WorkstationSetup

### Test 19: Rapid Station Switching
1. [ ] Place 2 workstations close together
2. [ ] Walk between them rapidly
3. [ ] **Expected**: Prompt switches smoothly
4. [ ] **Expected**: No errors in console

### Test 20: Crafting While Moving
1. [ ] Open crafting at Furnace
2. [ ] Start crafting Iron Ingot
3. [ ] While crafting, walk away
4. [ ] **Expected**: Craft should fail if you move > 10 studs before server processes

## Console Checks

After each major test, check the console for:
- [ ] No error messages
- [ ] Appropriate info messages (e.g., "[WorkstationServer] Player X opened Furnace")
- [ ] "[WorkstationSetup] Loaded successfully"
- [ ] "[WorkstationServer] Loaded successfully"

## Performance Checks

### Test 21: Performance
1. [ ] Place 10+ workstations in the world
2. [ ] Walk around near them
3. [ ] **Expected**: No noticeable lag
4. [ ] **Expected**: Smooth prompt switching

## Cleanup

After testing, verify:
- [ ] All scripts load without errors
- [ ] No memory leaks (test by playing for extended period)
- [ ] Station prompts clean up when player dies/respawns

## Known Limitations

Document any issues found during testing:
- Issue 1: _______________________________
- Issue 2: _______________________________
- Issue 3: _______________________________

## Sign-off

- [ ] All critical tests passed
- [ ] No blocking issues found
- [ ] System ready for production

**Tester Name**: _______________
**Date**: _______________
**Notes**: 
```
_____________________________________________________
_____________________________________________________
_____________________________________________________
```
