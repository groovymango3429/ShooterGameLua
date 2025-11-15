-- BoatGuiSetup.client.lua
-- Creates and manages the BoatGui for accessing boat storage

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Modules.Signal)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create BoatGui if it doesn't exist
local boatGui = playerGui:FindFirstChild("BoatGui")
if not boatGui then
	boatGui = Instance.new("ScreenGui")
	boatGui.Name = "BoatGui"
	boatGui.ResetOnSpawn = false
	boatGui.Enabled = false -- Hidden by default
	boatGui.Parent = playerGui
	
	-- Create button to open storage
	local openStorageButton = Instance.new("TextButton")
	openStorageButton.Name = "OpenStorageButton"
	openStorageButton.Size = UDim2.new(0, 150, 0, 50)
	openStorageButton.Position = UDim2.new(0.5, -75, 0.1, 0)
	openStorageButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	openStorageButton.BorderSizePixel = 2
	openStorageButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
	openStorageButton.Text = "Open Boat Storage"
	openStorageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	openStorageButton.TextScaled = true
	openStorageButton.Font = Enum.Font.GothamBold
	openStorageButton.Parent = boatGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = openStorageButton
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 5)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = openStorageButton
	
	-- Handle button click
	openStorageButton.MouseButton1Click:Connect(function()
		local boatId = boatGui:GetAttribute("CurrentBoatId")
		if boatId then
			print("[BoatGui] Opening boat storage for boat:", boatId)
			Signal.FireServer("BoatStorage:Open", boatId)
		else
			warn("[BoatGui] No boat ID found")
		end
	end)
	
	print("[BoatGui] Created BoatGui with storage button")
end

-- Listen for boat storage open response
Signal.ListenClient("BoatStorage:Open", function(boatId, items, maxStacks)
	print("[BoatGui] Boat storage opened:", boatId, "Items:", #items, "MaxStacks:", maxStacks)
	
	-- Find or create storage GUI
	local storageGui = playerGui:FindFirstChild("StorageGui")
	if not storageGui then
		warn("[BoatGui] StorageGui not found - creating basic storage display")
		-- The storage GUI should already exist from StorageClientProximity
		-- For now, we'll just log that we opened it
		-- In a real implementation, you'd reuse the existing StorageGui system
	end
	
	-- Update storage GUI to show boat storage
	-- This would integrate with the existing storage system UI
	-- For now, just signal that it opened
	Signal.FireClient(player, "Storage:Open", boatId, items, maxStacks)
end)

-- Listen for boat storage errors
Signal.ListenClient("BoatStorage:Error", function(errorMsg)
	warn("[BoatGui] Boat storage error:", errorMsg)
	-- Show error to player
	-- You could create a notification system here
end)

-- Listen for boat storage updates
Signal.ListenClient("BoatStorage:Update", function(boatId, items, maxStacks)
	print("[BoatGui] Boat storage updated:", boatId, "Items:", #items)
	-- Update the storage GUI if it's open
	Signal.FireClient(player, "Storage:Update", boatId, items, maxStacks)
end)

print("[BoatGui] BoatGui setup complete")
