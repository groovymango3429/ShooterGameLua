local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plotTemplate = game:GetService("ServerStorage").Plot
local PlotSpawnPool = require(script.Parent.PlotSpawnPool)
local placeableObjects = ReplicatedStorage.PlaceableObjects
local PlacementValidator = require(ReplicatedStorage.PlacementValidator)
local InventoryServer = require(game:GetService("ServerScriptService").Server.InventoryServer)
local HttpService = game:GetService("HttpService") -- For GUIDs

local PlotManager = {}

local plots = {}

function PlotManager.SpawnPlot(player)
	local plot = plotTemplate:Clone()
	plot.Name = `{player.Name}'s Plot`
	plot:PivotTo(PlotSpawnPool.Get(player).CFrame)
	plot.Parent = workspace.Plots
	plots[player.UserId] = plot
	return plot
end

function PlotManager.Place(player, name, targetCF)
	local object = placeableObjects:FindFirstChild(name)
	local plot = plots[player.UserId]

	if not object or not plot then 
		return false
	end

	-- Clone the object and pivot it first, so validation uses BoundaryBox!
	local previewClone = object:Clone()
	previewClone:PivotTo(targetCF)

	-- Use the clone for validation
	if not PlacementValidator.WithinBounds(plot, previewClone)
		or not PlacementValidator.NotIntersectingObjects(plot, previewClone)
		or not PlacementValidator.NotAboveWater(previewClone)
	then
		return false 
	end

	local removed = InventoryServer.RemovePlacedItem(player, name)
	if not removed then
		previewClone:Destroy()
		return false
	end

	-- Actually parent the clone to plot.Objects after validation
	previewClone.Parent = plot.Objects

	-- Assign StorageId if this is a StorageRack
	if name == "StorageRack" then
		local storageId = HttpService:GenerateGUID(false)
		previewClone:SetAttribute("StorageId", storageId)
	end

	return true 
end

function PlotManager.Delete(player, object)
	local plot = plots[player.UserId]
	if not plot or not object 
		or not object:IsDescendantOf(plot.Objects)	
	then
		return false
	end

	local actualObject = object
	while actualObject.Parent ~= plot.Objects do
		actualObject = actualObject:FindFirstAncestorWhichIsA("Model")
	end
	actualObject:Destroy()
	return true
end

function PlotManager.GetPlot(player)
	return plots[player.UserId]
end

return PlotManager