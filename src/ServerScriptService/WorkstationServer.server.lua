-- WorkstationServer.lua
-- Server-side script for handling workstation interactions
-- Creates OpenCraftingMenu RemoteEvent and validates station proximity

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Create or get Events folder
local Events = ReplicatedStorage:FindFirstChild("Events")
if not Events then
	Events = Instance.new("Folder")
	Events.Name = "Events"
	Events.Parent = ReplicatedStorage
end

-- Create OpenCraftingMenu RemoteEvent
local OpenCraftingMenuEvent = Events:FindFirstChild("OpenCraftingMenu")
if not OpenCraftingMenuEvent then
	OpenCraftingMenuEvent = Instance.new("RemoteEvent")
	OpenCraftingMenuEvent.Name = "OpenCraftingMenu"
	OpenCraftingMenuEvent.Parent = Events
end

local MAX_DISTANCE = 12 -- Slightly more than client to account for lag

-- Handle OpenCraftingMenu requests
OpenCraftingMenuEvent.OnServerEvent:Connect(function(player, stationName)
	-- Validate player has a character
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	local hrp = char.HumanoidRootPart
	
	-- Validate workstation exists
	local workstationsFolder = Workspace:FindFirstChild("Workstations")
	if not workstationsFolder then 
		warn("[WorkstationServer] Workstations folder not found")
		return 
	end
	
	local workstation = workstationsFolder:FindFirstChild(stationName)
	if not workstation then
		warn("[WorkstationServer] Workstation not found:", stationName)
		return
	end
	
	-- Validate distance
	local stationPos = workstation:IsA("BasePart") and workstation.Position or (workstation.PrimaryPart and workstation.PrimaryPart.Position)
	if not stationPos then
		warn("[WorkstationServer] Workstation has no position:", stationName)
		return
	end
	
	local distance = (hrp.Position - stationPos).Magnitude
	if distance > MAX_DISTANCE then
		warn("[WorkstationServer] Player too far from workstation:", player.Name, stationName, distance)
		return
	end
	
	-- All checks passed, tell client to open crafting menu for this station
	print("[WorkstationServer] Player", player.Name, "opened", stationName)
	
	-- Fire back to client to actually open the GUI with station filter
	local OpenCraftingGUIEvent = Events:FindFirstChild("OpenCraftingGUI")
	if not OpenCraftingGUIEvent then
		OpenCraftingGUIEvent = Instance.new("RemoteEvent")
		OpenCraftingGUIEvent.Name = "OpenCraftingGUI"
		OpenCraftingGUIEvent.Parent = Events
	end
	OpenCraftingGUIEvent:FireClient(player, stationName)
end)

print("[WorkstationServer] Loaded successfully")
