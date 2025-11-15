-- DurabilityUI.client.lua
-- Robust custom-detection + bar-based durability display
-- Looks for a ScreenGui named "DurabilityUI" and uses the first Frame descendant as the container.
-- If your ScreenGui contains a Background->Fill (Frame) pair, the script will use them;
-- otherwise it will create Background and Fill inside the Frame. If no DurabilityUI ScreenGui
-- exists, a default ScreenGui and Frame will be created.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Signal = require(ReplicatedStorage.Modules.Signal)

local TweenInfoFast = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Utility debug (set to false to silence)
local DEBUG = false
local function dprintln(...)
	if DEBUG then
		print("[DurabilityUI]", ...)
	end
end

-- Find or create the custom ScreenGui named "DurabilityUI" and find a Frame inside it
local function locateOrCreateGui()
	local gui = playerGui:WaitForChild("DurabilityUI")
	local frame = nil
	if gui and gui:IsA("ScreenGui") then
		-- prefer a direct child named "Frame"
		frame = gui:FindFirstChild("Frame")
		if not frame then
			-- search for any Frame descendant
			for _, desc in ipairs(gui:GetDescendants()) do
				if desc:IsA("Frame") then
					frame = desc
					break
				end
			end
		end
		if frame then
			dprintln("Using existing DurabilityUI ScreenGui and Frame:", gui:GetFullName(), frame:GetFullName())
			return gui, frame, true
		else
			-- no frame found: create a Frame inside existing ScreenGui so user layout isn't altered otherwise
			dprintln("DurabilityUI ScreenGui found but no Frame descendant; creating Frame inside it.")
			local newFrame = Instance.new("Frame")
			newFrame.Name = "Frame"
			newFrame.Size = UDim2.new(0, 200, 0, 30)
			newFrame.Position = UDim2.new(0.5, -100, 0.9, -40)
			newFrame.BackgroundTransparency = 1
			newFrame.Parent = gui
			return gui, newFrame, true
		end
	else
		-- create default ScreenGui named DurabilityUI
		dprintln("No DurabilityUI ScreenGui found; creating default one.")
		local newGui = Instance.new("ScreenGui")
		newGui.Name = "DurabilityUI"
		newGui.ResetOnSpawn = false
		newGui.Parent = playerGui

		local newFrame = Instance.new("Frame")
		newFrame.Name = "DurabilityFrame"
		newFrame.Size = UDim2.new(0, 200, 0, 30)
		newFrame.Position = UDim2.new(0.5, -100, 0.9, -40)
		newFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		newFrame.BorderSizePixel = 2
		newFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		newFrame.Visible = false
		newFrame.Parent = newGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = newFrame

		return newGui, newFrame, false
	end
end

local durabilityGui, durabilityFrame, isCustomUI = locateOrCreateGui()

-- Ensure we have a top-level frame to work with
if not durabilityFrame then
	warn("DurabilityUI: failed to find or create a Frame for the UI; aborting.")
	return
end

-- We'll try to find existing UI elements inside the frame; otherwise we'll create them
local itemNameLabel = nil
-- Accept Item Name text label anywhere inside the frame
for _, d in ipairs(durabilityFrame:GetDescendants()) do
	if d:IsA("TextLabel") and (d.Name == "Item Name" or d.Name == "GunName" or d.Name == "Name") then
		itemNameLabel = d
		break
	end
end

-- Find or create a durability container (Background -> Fill)
local durabilityContainer = nil
-- Look for an explicit container candidate
durabilityContainer = durabilityFrame:FindFirstChild("Item Durability") or durabilityFrame:FindFirstChild("Item Durability Bar") or durabilityFrame:FindFirstChild("DurabilityContainer")
-- fallback: use the frame itself as the container
if not durabilityContainer then
	-- Prefer a direct child named Background as part of a custom layout
	local bgCandidate = durabilityFrame:FindFirstChild("Background")
	if bgCandidate and bgCandidate:IsA("Frame") then
		durabilityContainer = durabilityFrame
	else
		-- use the frame as the container (we'll create Background inside it)
		durabilityContainer = durabilityFrame
	end
end

-- Background and Fill frames (may already exist in custom UI)
local background = nil
local fill = nil

-- Try to find Background and Fill under container
if durabilityContainer then
	background = durabilityContainer:FindFirstChild("Background")
	if not background then
		-- look among descendants in case custom named deeper layout
		for _, d in ipairs(durabilityContainer:GetDescendants()) do
			if d:IsA("Frame") and d.Name == "Background" then
				background = d
				break
			end
		end
	end
end

-- If no Background found, create one
if not background then
	background = Instance.new("Frame")
	background.Name = "Background"
	-- Size/position: if using custom Frame as container, fill it; if default Frame, use inset
	if durabilityContainer == durabilityFrame and not isCustomUI then
		background.Size = UDim2.new(1, -8, 1, -8)
		background.Position = UDim2.new(0, 4, 0, 4)
	else
		background.Size = UDim2.new(1, 0, 0, 18)
		background.Position = UDim2.new(0, 0, 0, 0)
	end
	background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	background.BorderSizePixel = 0
	background.Parent = durabilityContainer

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = background
end

-- Fill (colored) bar
fill = background:FindFirstChild("Fill")
if not fill then
	fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	fill.BorderSizePixel = 0
	fill.Parent = background

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = fill
end

-- Optional numeric label overlay named "Number"
local numberLabel = background:FindFirstChild("Number")
if not numberLabel then
	numberLabel = Instance.new("TextLabel")
	numberLabel.Name = "Number"
	numberLabel.Size = UDim2.new(1, 0, 1, 0)
	numberLabel.Position = UDim2.new(0, 0, 0, 0)
	numberLabel.BackgroundTransparency = 1
	numberLabel.Text = ""
	numberLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	numberLabel.TextScaled = true
	numberLabel.Font = Enum.Font.GothamBold
	numberLabel.Visible = false -- hidden by default; enable if you prefer numeric
	numberLabel.Parent = background

	local textSize = Instance.new("UITextSizeConstraint")
	textSize.MaxTextSize = 16
	textSize.Parent = numberLabel
end

-- Ensure the top frame is hidden until a tool with durability is present
if durabilityFrame:IsA("Frame") and durabilityFrame.Name == "DurabilityFrame" then
	durabilityFrame.Visible = false
end

-- Helper color function
local function colorForPercent(p)
	if p > 0.6 then
		return Color3.fromRGB(0, 200, 0)
	elseif p > 0.3 then
		return Color3.fromRGB(255, 200, 0)
	else
		return Color3.fromRGB(200, 0, 0)
	end
end

-- Update function (animates fill + color + numeric)
local function updateDurability(toolName, currentDurability, maxDurability)
	if not currentDurability or not maxDurability or maxDurability == 0 then
		durabilityFrame.Visible = false
		return
	end

	local pct = math.clamp(currentDurability / maxDurability, 0, 1)

	-- show frame
	if durabilityFrame then durabilityFrame.Visible = true end

	-- optional item name
	if itemNameLabel and itemNameLabel:IsA("TextLabel") then
		itemNameLabel.Text = toolName or "Unknown"
	end

	-- animate size
	if fill and fill:IsA("Frame") then
		local target = UDim2.new(pct, 0, 1, 0)
		local tween = TweenService:Create(fill, TweenInfoFast, {Size = target})
		tween:Play()
		-- color tween
		local targetColor = colorForPercent(pct)
		local colorTween = TweenService:Create(fill, TweenInfoFast, {BackgroundColor3 = targetColor})
		colorTween:Play()
	end

	-- update numeric overlay if visible
	if numberLabel and numberLabel:IsA("TextLabel") and numberLabel.Visible then
		numberLabel.Text = string.format("%d/%d", math.floor(currentDurability), math.floor(maxDurability))
	end
end

-- Observing equipped tool attributes and changes
local observedTool = nil
local observedConns = {}

local function clearObservedTool()
	for _, c in ipairs(observedConns) do
		if c and c.Disconnect then
			c:Disconnect()
		elseif c and typeof(c) == "RBXScriptConnection" then
			c:Disconnect()
		end
	end
	observedConns = {}
	observedTool = nil
end

local function observeTool(tool)
	if not tool then return end
	clearObservedTool()
	observedTool = tool
	dprintln("Observing tool:", tool.Name)

	-- immediate update if attributes present
	local d = tool:GetAttribute("Durability")
	local m = tool:GetAttribute("MaxDurability")
	dprintln("Initial attributes:", d, m)
	if d and m then
		updateDurability(tool.Name, d, m)
	end

	-- Listen for attribute changes
	local c1 = tool:GetAttributeChangedSignal("Durability"):Connect(function()
		local nd = tool:GetAttribute("Durability")
		local nm = tool:GetAttribute("MaxDurability")
		dprintln("Durability changed:", nd, nm)
		if nd and nm then
			updateDurability(tool.Name, nd, nm)
		end
	end)
	table.insert(observedConns, c1)

	local c2 = tool:GetAttributeChangedSignal("MaxDurability"):Connect(function()
		local nd = tool:GetAttribute("Durability")
		local nm = tool:GetAttribute("MaxDurability")
		dprintln("MaxDurability changed:", nd, nm)
		if nd and nm then
			updateDurability(tool.Name, nd, nm)
		end
	end)
	table.insert(observedConns, c2)

	-- Hide UI if tool is removed from character
	local c3 = tool:GetPropertyChangedSignal("Parent"):Connect(function()
		if not tool.Parent or not tool:IsDescendantOf(player.Character or workspace) then
			dprintln("Observed tool removed; clearing UI")
			clearObservedTool()
			if durabilityFrame then durabilityFrame.Visible = false end
		end
	end)
	table.insert(observedConns, c3)
end

-- Find equipped tool (prefer tools that have durability attributes)
local function findEquippedTool()
	local char = player.Character
	if not char then return nil end

	-- prefer tools with attributes
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Tool") then
			if child:GetAttribute("Durability") ~= nil and child:GetAttribute("MaxDurability") ~= nil then
				return child
			end
		end
	end

	-- fallback to first tool
	return char:FindFirstChildOfClass("Tool")
end

local function checkEquippedTool()
	local tool = findEquippedTool()
	if tool then
		dprintln("checkEquippedTool ->", tool.Name)
		observeTool(tool)
		local d = tool:GetAttribute("Durability")
		local m = tool:GetAttribute("MaxDurability")
		if d and m then
			updateDurability(tool.Name, d, m)
		else
			-- waiting for attributes to be set (server may set after equip)
			dprintln("Attributes missing; waiting for attribute changes on tool.")
			if durabilityFrame then durabilityFrame.Visible = false end
		end
	else
		dprintln("No equipped tool found.")
		clearObservedTool()
		if durabilityFrame then durabilityFrame.Visible = false end
	end
end

-- Remote listener (server can push durability updates)
Signal.ListenRemote("InventoryClient:UpdateDurability", function(toolName, durability, maxDurability)
	dprintln("Remote update:", toolName, durability, maxDurability)
	updateDurability(toolName, durability, maxDurability)
end)

-- Monitor character tool changes
local function onCharacterAdded(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.wait(0.08)
			dprintln("ChildAdded tool:", child.Name)
			checkEquippedTool()
		end
	end)

	char.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			dprintln("ChildRemoved tool:", child.Name)
			clearObservedTool()
			if durabilityFrame then durabilityFrame.Visible = false end
		end
	end)

	-- initial scan
	checkEquippedTool()
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Lightweight periodic check in case attributes are set before signals fire
RunService.Heartbeat:Connect(function(dt)
	-- only run occasional checks; keep cheap
	checkEquippedTool()
end)
