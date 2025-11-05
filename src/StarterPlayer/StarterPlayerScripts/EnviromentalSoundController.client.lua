-- Place this LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ZonesFolder = workspace:WaitForChild("Zones")

-- Configuration: zone name to sound and reverb mapping
local zoneConfigs = {
	Island = {
		Sound = SoundService:WaitForChild("IslandAmbient"),
		Volume = .6,
		Reverb = Enum.ReverbType.NoReverb
	},
	Forest = {
		Sound = SoundService:WaitForChild("ForestAmbient"),
		Volume = .6,
		Reverb = Enum.ReverbType.NoReverb,
	},
	House = {
		Sound = SoundService:WaitForChild("HouseAmbient"),
		Volume = 0.6, -- Quieter inside
		Reverb = Enum.ReverbType.Room,
	},
	-- Add more zones here as needed
}

-- Start all sounds at zero volume
for _, config in pairs(zoneConfigs) do
	config.Sound.Volume = 0
	config.Sound.Looped = true
	config.Sound:Play()
end

-- Helper: fade a sound to a target volume
local function fadeSound(sound, targetVolume, duration)
	local tween = TweenService:Create(sound, TweenInfo.new(duration or 1), {Volume = targetVolume})
	tween:Play()
end

-- Helper: set global reverb
local function setReverb(reverb)
	SoundService.AmbientReverb = reverb
end

-- Helper: check if position is inside a part
local function isPointInPart(part, point)
	local size = part.Size / 2
	local cf = part.CFrame:ToObjectSpace(CFrame.new(point)).Position
	return math.abs(cf.x) <= size.x and math.abs(cf.y) <= size.y and math.abs(cf.z) <= size.z
end

-- Get character's position safely
local function getCharPos()
	if not LocalPlayer.Character then return end
	local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	return root.Position
end

-- Helper: get all zone parts by type using attribute
local function getPartsByZoneType(zoneType)
	local parts = {}
	for _, part in ipairs(ZonesFolder:GetChildren()) do
		if part:IsA("BasePart") and part:GetAttribute("zoneType") == zoneType then
			table.insert(parts, part)
		end
	end
	return parts
end

-- Main loop: detect zone changes
local currentZone = nil

RunService.RenderStepped:Connect(function()
	local pos = getCharPos()
	if not pos then return end

	local foundZone = nil
	for zoneName, config in pairs(zoneConfigs) do
		local parts = getPartsByZoneType(zoneName)
		for _, part in ipairs(parts) do
			if isPointInPart(part, pos) then
				foundZone = zoneName
				break
			end
		end
		if foundZone then break end
	end

	-- Default to Forest if not in any zone
	if not foundZone then
		foundZone = "Forest"
	end

	if foundZone ~= currentZone then
		-- Fade out previous
		if currentZone and zoneConfigs[currentZone] then
			fadeSound(zoneConfigs[currentZone].Sound, 0, 1.5)
		end
		-- Fade in new
		if foundZone and zoneConfigs[foundZone] then
			fadeSound(zoneConfigs[foundZone].Sound, zoneConfigs[foundZone].Volume, 1.5)
			setReverb(zoneConfigs[foundZone].Reverb)
		else
			setReverb(Enum.ReverbType.NoReverb)
		end
		currentZone = foundZone
	end
end)