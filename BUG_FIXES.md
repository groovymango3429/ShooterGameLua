# Equipment Teleportation Bug - Potential Fixes

## Problem
When equipping armor, the player gets teleported to the game origin (0, 0, 0).

## Root Cause Analysis
The issue is in the `EquipArmor` function in `InventoryServer.lua` (lines 408-457).

When creating a Weld to attach armor pieces to body parts, the code doesn't set the `C0` and `C1` properties of the weld. This causes the weld to use default CFrame values of (0, 0, 0), which forces the parts to position themselves at the world origin.

## The Bug Location
**File:** `/src/ServerScriptService/Server/InventoryServer.lua`  
**Function:** `InventoryServer.EquipArmor`  
**Lines:** 442-445

```lua
local weld = Instance.new("Weld")
weld.Parent = bodyPart
weld.Part0 = bodyPart
weld.Part1 = partModel.PrimaryPart
-- Missing: weld.C0 and weld.C1 are not set!
```

## Proposed Fix

### Solution 1: Set Weld CFrame Properties (RECOMMENDED)
Set the `C0` and `C1` properties to maintain the relative position of the armor piece:

```lua
local weld = Instance.new("Weld")
weld.Parent = bodyPart
weld.Part0 = bodyPart
weld.Part1 = partModel.PrimaryPart
-- Fix: Set C1 to maintain the armor piece's current offset from the body part
weld.C1 = bodyPart.CFrame:Inverse() * partModel.PrimaryPart.CFrame
weld.C0 = CFrame.new(0, 0, 0)  -- Keep Part0 at its current position
```

### Solution 2: Alternative Using Motor6D
If you want animated armor (for future features), use Motor6D instead:

```lua
local motor = Instance.new("Motor6D")
motor.Parent = bodyPart
motor.Part0 = bodyPart
motor.Part1 = partModel.PrimaryPart
motor.C1 = bodyPart.CFrame:Inverse() * partModel.PrimaryPart.CFrame
motor.C0 = CFrame.new(0, 0, 0)
```

### Solution 3: Use WeldConstraint (Simplest)
For simple attachment without needing to manipulate the weld later:

```lua
-- Position the armor part first
partModel.PrimaryPart.CFrame = bodyPart.CFrame

-- Create a WeldConstraint
local weld = Instance.new("WeldConstraint")
weld.Parent = bodyPart
weld.Part0 = bodyPart
weld.Part1 = partModel.PrimaryPart
```

## Implementation Plan
1. **Apply Solution 1** as it's the most reliable and maintains existing code structure
2. Test with all armor types (Head, Chest, Feet)
3. Verify player doesn't teleport when equipping
4. Verify armor pieces are positioned correctly on the character

## Testing Checklist
- [ ] Equip Head armor - no teleportation
- [ ] Equip Chest armor - no teleportation
- [ ] Equip Feet armor - no teleportation
- [ ] Armor pieces visually positioned correctly
- [ ] Armor pieces move with character
- [ ] Unequipping armor works correctly
- [ ] Switching between different armor pieces works
- [ ] Armor persists through save/load

## Additional Considerations
- Check if armor models in `ServerStorage.ArmorModels` have their `PrimaryPart` set correctly
- Ensure armor model parts are positioned relative to their body parts in the stored models
- Consider adding validation to warn if PrimaryPart is missing
