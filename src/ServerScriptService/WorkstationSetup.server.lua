-- WorkstationSetup.lua
-- Helper script to add BillboardGui prompts to workstations
-- This should be run once to set up the workstations, or can be used as a reference
-- for manually creating workstation models

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Get the LootItemBillboardGui template from ReplicatedStorage
local function getBillboardGuiTemplate()
	local guiTemplate = ReplicatedStorage:FindFirstChild("LootItemBillboardGui")
	if not guiTemplate then
		warn("[WorkstationSetup] LootItemBillboardGui template not found in ReplicatedStorage!")
		warn("[WorkstationSetup] Creating a fallback template...")
		-- Create a fallback template with the required structure
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "LootItemBillboardGui"
		billboard.Size = UDim2.new(0, 200, 0, 80)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Enabled = false -- Will be enabled by WorkstationClient when player is near
		
		local frame = Instance.new("Frame")
		frame.Name = "Frame"
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.BorderSizePixel = 0
		frame.Parent = billboard
		
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "Desc"
		descLabel.Size = UDim2.new(1, 0, 0.4, 0)
		descLabel.Position = UDim2.new(0, 0, 0, 0)
		descLabel.BackgroundTransparency = 1
		descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		descLabel.TextScaled = true
		descLabel.Font = Enum.Font.SourceSans
		descLabel.Text = "Press [E] to Use"
		descLabel.Parent = frame
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "StringName"
		nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
		nameLabel.Position = UDim2.new(0, 0, 0.4, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.Text = "Workstation"
		nameLabel.Parent = frame
		
		return billboard
	end
	return guiTemplate
end

-- Set up a single workstation with BillboardGui
local function setupWorkstation(workstation)
	print("[WorkstationSetup] Setting up workstation:", workstation.Name)
	
	-- Find or create a primary part to attach the billboard to
	local attachPart = workstation.PrimaryPart
	if not attachPart then
		-- If no PrimaryPart, look for a part named "ProximityDetector" or just use the first BasePart
		attachPart = workstation:FindFirstChild("ProximityDetector")
		if not attachPart then
			for _, child in ipairs(workstation:GetChildren()) do
				if child:IsA("BasePart") then
					attachPart = child
					break
				end
			end
		end
	end
	
	if not attachPart then
		warn("[WorkstationSetup] No suitable part found in workstation:", workstation.Name)
		return
	end
	
	-- Remove existing prompts if they exist
	local existingPrompt = attachPart:FindFirstChild("InteractionPrompt")
	if existingPrompt then
		existingPrompt:Destroy()
	end
	local existingLootGui = attachPart:FindFirstChild("LootItemBillboardGui")
	if existingLootGui then
		existingLootGui:Destroy()
	end
	
	-- Get and clone the LootItemBillboardGui template
	local guiTemplate = getBillboardGuiTemplate()
	local billboard = guiTemplate:Clone()
	
	-- Update the text fields to show workstation information
	local frame = billboard:FindFirstChild("Frame")
	if frame then
		-- Set the Desc label (instruction text) if it exists
		local descLabel = frame:FindFirstChild("Desc")
		if descLabel and descLabel:IsA("TextLabel") then
			descLabel.Text = "Press [E] to Use"
		end
		
		-- Set the StringName label (workstation name) - this is the primary field
		local nameLabel = frame:FindFirstChild("StringName")
		if nameLabel and nameLabel:IsA("TextLabel") then
			nameLabel.Text = workstation.Name
		end
		
		-- Also check for "Name" label for compatibility with LootItemBillboardGui template from ReplicatedStorage
		-- (The fallback template uses StringName, but the actual template may use Name)
		local altNameLabel = frame:FindFirstChild("Name")
		if altNameLabel and altNameLabel:IsA("TextLabel") then
			altNameLabel.Text = workstation.Name
		end
	end
	
	billboard.Parent = attachPart
	
	print("[WorkstationSetup] Successfully set up:", workstation.Name)
end

-- Main setup function
local function setupAllWorkstations()
	local workstationsFolder = Workspace:FindFirstChild("Workstations")
	if not workstationsFolder then
		warn("[WorkstationSetup] Workstations folder not found in Workspace!")
		warn("[WorkstationSetup] Please create a folder named 'Workstations' in Workspace")
		return
	end
	
	print("[WorkstationSetup] Setting up all workstations...")
	
	for _, workstation in ipairs(workstationsFolder:GetChildren()) do
		setupWorkstation(workstation)
	end
	
	print("[WorkstationSetup] Setup complete!")
end

-- Run setup
setupAllWorkstations()

-- Also set up any new workstations added at runtime
local workstationsFolder = Workspace:FindFirstChild("Workstations")
if workstationsFolder then
	workstationsFolder.ChildAdded:Connect(function(child)
		task.wait(0.1) -- Wait for workstation to fully load
		setupWorkstation(child)
	end)
end

print("[WorkstationSetup] Loaded successfully")
