local PlacementValidator = {}

local function getBoundaryBoxInfo(model)
	if typeof(model) == "Instance" and model:IsA("Model") then
		local boundaryBox = model:FindFirstChild("BoundaryBox")
		if boundaryBox and boundaryBox:IsA("BasePart") then
			return boundaryBox.CFrame, boundaryBox.Size
		else
			return model:GetPivot(), model:GetExtentsSize()
		end
	else
		warn("getBoundaryBoxInfo called with non-Model argument! Type:", typeof(model))
		return nil, nil
	end
end

function PlacementValidator.WithinBounds(plot: Model, previewModel: Model)
	local boxCF, boxSize = getBoundaryBoxInfo(previewModel)
	if not boxCF or not boxSize then
		warn("[PlacementValidator] Could not get boundary box info!")
		return false
	end

	print("[PlacementValidator] Using boundary box for placement:")
	print("  boxCF.Position =", tostring(boxCF.Position))
	print("  boxSize =", tostring(boxSize))

	local plotCF, plotSize = plot:GetBoundingBox()
	local plotWorldY = plotCF.Position.Y
	local plotTopWorldY = plotWorldY + plotSize.Y / 2
	local plotBottomWorldY = plotWorldY - plotSize.Y / 2

	local objectWorldY = boxCF.Position.Y
	local objectBaseWorldY = objectWorldY - boxSize.Y / 2

	if objectBaseWorldY < plotBottomWorldY or objectBaseWorldY > plotTopWorldY then
		return false
	end

	for _, x in {-1, 1} do
		for _, z in {-1, 1} do
			local corner = boxCF:PointToWorldSpace(Vector3.new(x * boxSize.X / 2, -boxSize.Y / 2, z * boxSize.Z / 2))
			print(string.format("    corner: x=%.2f z=%.2f", corner.X, corner.Z))
			if math.abs(corner.X - plotCF.Position.X) > plotSize.X / 2 or math.abs(corner.Z - plotCF.Position.Z) > plotSize.Z / 2 then
				return false
			end
		end
	end

	return true
end

function PlacementValidator.NotIntersectingObjects(plot: Model, previewModel: Model)
	local boxCF, boxSize = getBoundaryBoxInfo(previewModel)
	if not boxCF or not boxSize then
		warn("[PlacementValidator] Could not get boundary box info for NotIntersectingObjects!")
		return false
	end
	local params = OverlapParams.new()
	params:AddToFilter(plot.Objects)
	params.FilterType = Enum.RaycastFilterType.Include
	local parts = workspace:GetPartBoundsInBox(boxCF, boxSize, params)
	local result = #parts == 0
	return result
end

function PlacementValidator.NotAboveWater(previewModel: Model)
	local boxCF, boxSize = getBoundaryBoxInfo(previewModel)
	if not boxCF or not boxSize then
		warn("[PlacementValidator] Could not get boundary box info for NotAboveWater!")
		return false
	end
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if not terrain then
		return true
	end

	local testOffsets = {
		Vector3.new(0, -boxSize.Y / 2, 0),
		Vector3.new(-boxSize.X / 2, -boxSize.Y / 2, -boxSize.Z / 2),
		Vector3.new(-boxSize.X / 2, -boxSize.Y / 2, boxSize.Z / 2),
		Vector3.new(boxSize.X / 2, -boxSize.Y / 2, -boxSize.Z / 2),
		Vector3.new(boxSize.X / 2, -boxSize.Y / 2, boxSize.Z / 2),
	}

	for _, offset in ipairs(testOffsets) do
		local worldPos = boxCF:PointToWorldSpace(offset)
		local startY = worldPos.Y + 10
		local endY = worldPos.Y - 20
		local step = -0.5

		local foundWaterAbove = false
		for y = startY, endY, step do
			local mat = terrain:ReadVoxels(Region3.new(
				Vector3.new(worldPos.X, y, worldPos.Z) - Vector3.new(2,2,2),
				Vector3.new(worldPos.X, y, worldPos.Z) + Vector3.new(2,2,2)
				):ExpandToGrid(4), 4)[1][1][1]
			if mat == Enum.Material.Water then
				foundWaterAbove = true
				break
			elseif mat ~= Enum.Material.Air then
				break
			end
		end
		if foundWaterAbove then
			return false
		end
	end
	return true
end

return PlacementValidator