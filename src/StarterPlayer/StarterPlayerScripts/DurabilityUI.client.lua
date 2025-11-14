-- DurabilityUI.client.lua
-- Handles displaying durability for equipped tools

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Module requires
local Signal = require(ReplicatedStorage.Modules.Signal)

-- Wait for or create DurabilityUI
local durabilityGui = playerGui:FindFirstChild("DurabilityUI")
if not durabilityGui then
	durabilityGui = Instance.new("ScreenGui")
	durabilityGui.Name = "DurabilityUI"
	durabilityGui.ResetOnSpawn = false
	durabilityGui.Parent = playerGui
end

-- Create durability bar frame
local durabilityFrame = durabilityGui:FindFirstChild("DurabilityFrame")
if not durabilityFrame then
	durabilityFrame = Instance.new("Frame")
	durabilityFrame.Name = "DurabilityFrame"
	durabilityFrame.Size = UDim2.new(0, 200, 0, 30)
	durabilityFrame.Position = UDim2.new(0.5, -100, 0.9, -40)
	durabilityFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	durabilityFrame.BorderSizePixel = 2
	durabilityFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	durabilityFrame.Visible = false
	durabilityFrame.Parent = durabilityGui
	
	-- UICorner for rounded edges
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = durabilityFrame
	
	-- Durability bar
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Size = UDim2.new(1, -4, 1, -4)
	bar.Position = UDim2.new(0, 2, 0, 2)
	bar.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	bar.BorderSizePixel = 0
	bar.Parent = durabilityFrame
	
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 4)
	barCorner.Parent = bar
	
	-- Text label
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "100/100"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = durabilityFrame
	
	-- Text size constraint
	local textSize = Instance.new("UITextSizeConstraint")
	textSize.MaxTextSize = 16
	textSize.Parent = label
end

local bar = durabilityFrame:FindFirstChild("Bar")
local label = durabilityFrame:FindFirstChild("Label")

-- Function to update durability display
local function updateDurability(toolName, currentDurability, maxDurability)
	if not currentDurability or not maxDurability or maxDurability == 0 then
		durabilityFrame.Visible = false
		return
	end
	
	durabilityFrame.Visible = true
	
	local percentage = currentDurability / maxDurability
	bar.Size = UDim2.new(percentage, -4, 1, -4)
	
	-- Change color based on durability
	if percentage > 0.6 then
		bar.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Green
	elseif percentage > 0.3 then
		bar.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- Yellow
	else
		bar.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Red
	end
	
	label.Text = string.format("%d/%d", math.floor(currentDurability), math.floor(maxDurability))
end

-- Check for equipped tool durability
local function checkEquippedTool()
	local char = player.Character
	if not char then return end
	
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		local durability = tool:GetAttribute("Durability")
		local maxDurability = tool:GetAttribute("MaxDurability")
		
		if durability and maxDurability then
			updateDurability(tool.Name, durability, maxDurability)
		else
			durabilityFrame.Visible = false
		end
	else
		durabilityFrame.Visible = false
	end
end

-- Listen for durability updates from server
Signal.ListenRemote("InventoryClient:UpdateDurability", function(toolName, durability, maxDurability)
	updateDurability(toolName, durability, maxDurability)
end)

-- Monitor tool changes
local function onCharacterAdded(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.wait(0.1) -- Small delay to ensure attributes are set
			checkEquippedTool()
		end
	end)
	
	char.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			durabilityFrame.Visible = false
		end
	end)
	
	checkEquippedTool()
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Update durability display periodically
RunService.Heartbeat:Connect(function()
	checkEquippedTool()
end)
