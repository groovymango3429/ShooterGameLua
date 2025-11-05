--[[
	Day-Night Cycle System
	Controls the time of day and adjusts zombie threat levels accordingly
	
	Configuration:
	- Day starts at 6:00 (06:00)
	- Night starts at 18:00 (18:00)
	- One full cycle = 24 minutes (1 minute = 1 hour in-game)
	- Zombies are more aggressive at night
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local DAY_LENGTH = 24 * 60 -- 24 minutes for a full day-night cycle (in seconds)
local MINUTES_PER_SECOND = 24 / (DAY_LENGTH / 60) -- How many in-game minutes pass per real second
local DAY_START_HOUR = 6 -- 6 AM
local NIGHT_START_HOUR = 18 -- 6 PM

-- Lighting settings for day and night
local DAY_SETTINGS = {
	Brightness = 2,
	OutdoorAmbient = Color3.fromRGB(128, 128, 128),
	Ambient = Color3.fromRGB(0, 0, 0),
	ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
	ColorShift_Top = Color3.fromRGB(0, 0, 0),
}

local NIGHT_SETTINGS = {
	Brightness = 0.5,
	OutdoorAmbient = Color3.fromRGB(50, 50, 80),
	Ambient = Color3.fromRGB(0, 0, 0),
	ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
	ColorShift_Top = Color3.fromRGB(50, 50, 100),
}

local DUSK_SETTINGS = {
	Brightness = 1,
	OutdoorAmbient = Color3.fromRGB(100, 80, 60),
	ColorShift_Top = Color3.fromRGB(100, 50, 0),
}

local DAWN_SETTINGS = {
	Brightness = 1.5,
	OutdoorAmbient = Color3.fromRGB(120, 100, 80),
	ColorShift_Top = Color3.fromRGB(255, 100, 50),
}

-- Create or get day/night status value
local TimeOfDayValue = ReplicatedStorage:FindFirstChild("TimeOfDayStatus")
if not TimeOfDayValue then
	TimeOfDayValue = Instance.new("StringValue")
	TimeOfDayValue.Name = "TimeOfDayStatus"
	TimeOfDayValue.Value = "Day"
	TimeOfDayValue.Parent = ReplicatedStorage
end

-- Create zombie threat multiplier attribute
local ZombieThreatValue = ReplicatedStorage:FindFirstChild("ZombieThreatMultiplier")
if not ZombieThreatValue then
	ZombieThreatValue = Instance.new("NumberValue")
	ZombieThreatValue.Name = "ZombieThreatMultiplier"
	ZombieThreatValue.Value = 1
	ZombieThreatValue.Parent = ReplicatedStorage
end

-- Helper function to smoothly transition lighting
local function lerpLighting(settings, alpha)
	Lighting.Brightness = Lighting.Brightness + (settings.Brightness - Lighting.Brightness) * alpha
	Lighting.OutdoorAmbient = Lighting.OutdoorAmbient:Lerp(settings.OutdoorAmbient, alpha)
	if settings.Ambient then
		Lighting.Ambient = Lighting.Ambient:Lerp(settings.Ambient, alpha)
	end
	if settings.ColorShift_Bottom then
		Lighting.ColorShift_Bottom = Lighting.ColorShift_Bottom:Lerp(settings.ColorShift_Bottom, alpha)
	end
	if settings.ColorShift_Top then
		Lighting.ColorShift_Top = Lighting.ColorShift_Top:Lerp(settings.ColorShift_Top, alpha)
	end
end

-- Function to get current hour (0-24)
local function getCurrentHour()
	local timeStr = Lighting.TimeOfDay
	local hour, minute = timeStr:match("(%d+):(%d+)")
	return tonumber(hour) + tonumber(minute) / 60
end

-- Function to determine time period
local function getTimePeriod(hour)
	if hour >= DAY_START_HOUR and hour < (DAY_START_HOUR + 1) then
		return "Dawn"
	elseif hour >= (DAY_START_HOUR + 1) and hour < (NIGHT_START_HOUR - 1) then
		return "Day"
	elseif hour >= (NIGHT_START_HOUR - 1) and hour < NIGHT_START_HOUR then
		return "Dusk"
	else
		return "Night"
	end
end

-- Initialize lighting
Lighting.ClockTime = DAY_START_HOUR
local currentPeriod = "Day"
TimeOfDayValue.Value = currentPeriod

print("[DayNight] Day-Night cycle started!")
print("[DayNight] One full cycle = " .. (DAY_LENGTH / 60) .. " minutes")
print("[DayNight] Day starts at " .. DAY_START_HOUR .. ":00, Night starts at " .. NIGHT_START_HOUR .. ":00")

-- Main cycle loop
task.spawn(function()
	while true do
		task.wait(1) -- Update every second
		
		-- Increment time
		Lighting.ClockTime = Lighting.ClockTime + (MINUTES_PER_SECOND / 60)
		
		-- Get current hour and period
		local hour = getCurrentHour()
		local newPeriod = getTimePeriod(hour)
		
		-- Update period if changed
		if newPeriod ~= currentPeriod then
			currentPeriod = newPeriod
			TimeOfDayValue.Value = currentPeriod
			print("[DayNight] Time changed to: " .. currentPeriod .. " (Hour: " .. string.format("%.1f", hour) .. ")")
		end
		
		-- Apply lighting based on period
		if currentPeriod == "Day" then
			lerpLighting(DAY_SETTINGS, 0.05)
			ZombieThreatValue.Value = 1
		elseif currentPeriod == "Night" then
			lerpLighting(NIGHT_SETTINGS, 0.05)
			ZombieThreatValue.Value = 2 -- Zombies are twice as threatening at night
		elseif currentPeriod == "Dusk" then
			lerpLighting(DUSK_SETTINGS, 0.05)
			ZombieThreatValue.Value = 1.3
		elseif currentPeriod == "Dawn" then
			lerpLighting(DAWN_SETTINGS, 0.05)
			ZombieThreatValue.Value = 1.2
		end
	end
end)
