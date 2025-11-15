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
			-- Send BoatStorage:Open request to server
			-- Server will respond with regular Storage:Open that existing StorageClient will handle
			Signal.FireServer("BoatStorage:Open", boatId)
		else
			warn("[BoatGui] No boat ID found")
		end
	end)
	
	print("[BoatGui] Created BoatGui with storage button")
end

print("[BoatGui] BoatGui setup complete")
