-- WorkstationSetup.lua
-- Helper script to add BillboardGui prompts to workstations
-- This should be run once to set up the workstations, or can be used as a reference
-- for manually creating workstation models

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Create a BillboardGui template for workstations
local function createBillboardGuiTemplate()
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "InteractionPrompt"
	billboard.Size = UDim2.new(0, 200, 0, 50)
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
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "PromptText"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Text = "Press [E] to Use"
	textLabel.Parent = frame
	
	return billboard
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
	
	-- Remove existing InteractionPrompt if it exists
	local existingPrompt = attachPart:FindFirstChild("InteractionPrompt")
	if existingPrompt then
		existingPrompt:Destroy()
	end
	
	-- Create and attach new BillboardGui
	local billboard = createBillboardGuiTemplate()
	local textLabel = billboard.Frame:FindFirstChild("PromptText")
	if textLabel then
		textLabel.Text = "Press [E] to Use " .. workstation.Name
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
