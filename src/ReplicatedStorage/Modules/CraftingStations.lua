local CollectionService = game:GetService("CollectionService")

local CraftingStations = {}

function CraftingStations.PlayerNearStation(player, stationTag, range)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	local pos = char.HumanoidRootPart.Position

	for _, obj in ipairs(CollectionService:GetTagged(stationTag)) do
		if (obj.Position - pos).Magnitude <= range then
			return true
		end
	end
	return false
end

return CraftingStations