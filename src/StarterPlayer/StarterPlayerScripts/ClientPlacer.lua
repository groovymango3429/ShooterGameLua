local ReplicatedStorage = game:GetService("ReplicatedStorage")
local boxOutlineTemplate = ReplicatedStorage:WaitForChild("BoxOutline")
local placeableObjects = ReplicatedStorage:WaitForChild("PlaceableObjects")
local Events = ReplicatedStorage:WaitForChild("Events")
local tryPlace = Events:WaitForChild("TryPlace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local PlacementValidator = require(ReplicatedStorage:WaitForChild("PlacementValidator"))

local PREVIEW_RENDER = "RenderPreview"
local PLACE_ACTION = "Place"
local ROTATE_ACTION = "Rotate"
local SNAP_ACTION = "Snap"

local function snapToGrid(pos, gridSize)
	return Vector3.new(
		math.round(pos.X / gridSize) * gridSize,
		pos.Y,
		math.round(pos.Z / gridSize) * gridSize
	)
end

local function castMouse()
	local mouseLocation = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local localPlayer = game:GetService("Players").LocalPlayer
	raycastParams.FilterDescendantsInstances = {localPlayer.Character}
	return workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
end

local ClientPlacer = {}
ClientPlacer.__index = ClientPlacer

function ClientPlacer.new(plot, placeableName)
	local self = setmetatable({
		Plot = plot,
		Preview = nil,
		PlaceableName = placeableName,
		GridSize = 0,
		Rotation = 0,
	}, ClientPlacer)

	self:InitiateRenderPreview()
	ContextActionService:BindAction(PLACE_ACTION, function(...) self:TryPlaceBlock(...) end, false, Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction(ROTATE_ACTION, function(...) self:RotateBlock(...) end, false, Enum.KeyCode.R)
	ContextActionService:BindAction(SNAP_ACTION, function(...) self:ToggleGrid(...) end, false, Enum.KeyCode.G)
	return self
end

function ClientPlacer:InitiateRenderPreview()
	pcall(function()
		RunService:UnbindFromRenderStep(PREVIEW_RENDER)
	end)
	local model = placeableObjects:FindFirstChild(self.PlaceableName)
	self:PreparePreviewModel(model)
	RunService:BindToRenderStep(PREVIEW_RENDER, Enum.RenderPriority.Camera.Value, function(...) self:RenderPreview(...) end)
end

function ClientPlacer:PreparePreviewModel(model)
	if self.Preview then
		self.Preview:Destroy()
		self.Preview = nil
	end
	if not model then return end

	self.Preview = model:Clone()

	-- Find the boundary box part (can be nil)
	local boundaryBox = self.Preview:FindFirstChild("BoundaryBox")
	local clientBox = self.Preview:FindFirstChild("ClientBox")

	local boxOutline = boxOutlineTemplate:Clone()
	-- Use ClientBox for adornment if exists, otherwise the whole preview model
	boxOutline.Adornee = clientBox or self.Preview
	boxOutline.Parent = self.Preview

	for _, part in self.Preview:GetDescendants() do
		if part:IsA("BasePart") then
			-- Make ClientBox, BoundaryBox, and Primary transparent
			if part.Name == "ClientBox" or part.Name == "BoundaryBox" or part.Name == "Primary" then
				part.Transparency = 1
			else
				part.Transparency = 0.5 -- You can adjust this if other parts should not be transparent
			end
			part.CanCollide = false
			part.CanQuery = false
		end
	end

	self.Preview.Parent = workspace
end

function ClientPlacer:RenderPreview()
	local cast = castMouse()
	if cast and cast.Position then
		local position = self.GridSize > 0 and snapToGrid(cast.Position, self.GridSize) or cast.Position
		local cf = CFrame.new(position) * CFrame.Angles(0, self.Rotation, 0)
		self.Preview:PivotTo(cf)

		-- Use BoundaryBox part if it exists, otherwise use GetExtentsSize
		local boundaryBox = self.Preview:FindFirstChild("BoundaryBox")
		local size, boxCF
		if boundaryBox and boundaryBox:IsA("BasePart") then
			size = boundaryBox.Size
			boxCF = boundaryBox.CFrame
			print(
				"[PLACER] Using BoundaryBox dimensions:",
				"Size =", tostring(size),
				"Position =", tostring(boundaryBox.Position)
			)
		else
			size = self.Preview:GetExtentsSize()
			boxCF = self.Preview:GetPivot()
			print(
				"[PLACER] Using Preview Model ExtentsSize:",
				"Size =", tostring(size),
				"Pivot Position =", tostring(self.Preview:GetPivot().Position)
			)
		end

		-- Print the BoxOutline's adornment size and position
		if self.Preview.BoxOutline and self.Preview.BoxOutline.Adornee then
			local adornee = self.Preview.BoxOutline.Adornee
			local outlineSize, outlinePos
			if adornee:IsA("BasePart") then
				outlineSize = adornee.Size
				outlinePos = adornee.Position
			else
				outlineSize = self.Preview:GetExtentsSize()
				outlinePos = self.Preview:GetPivot().Position
			end
			print(
				"[PLACER] BoxOutline Adornee:",
				"Size =", tostring(outlineSize),
				"Position =", tostring(outlinePos)
			)
		end

		-- Store validity for TryPlaceBlock -- placement uses BoundaryBox (not ClientBox)!
		self._lastValidPlacement = PlacementValidator.WithinBounds(self.Plot, self.Preview)
			and PlacementValidator.NotIntersectingObjects(self.Plot, self.Preview)
			and PlacementValidator.NotAboveWater(self.Preview)

		self.Preview.BoxOutline.Color3 = self._lastValidPlacement and Color3.new(0, 0.666667, 1) or Color3.new(1, 0, 0)
	end
end

function ClientPlacer:TryPlaceBlock(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end
	if not self.Preview then return end

	-- Only place if last preview is valid
	if not self._lastValidPlacement then
		warn("Cannot place: invalid location!")
		return
	end

	tryPlace:InvokeServer(self.PlaceableName, self.Preview:GetPivot())
end

function ClientPlacer:RotateBlock(_, state, _)
	if state == Enum.UserInputState.Begin then
		self.Rotation += math.pi / 6
	end
end

function ClientPlacer:ToggleGrid(_, state, _)
	if state == Enum.UserInputState.Begin then
		self.GridSize = self.GridSize == 0 and 4 or 0
	end
end

function ClientPlacer:Destroy()
	if self.Preview then
		self.Preview:Destroy()
		self.Preview = nil
	end
	pcall(function()
		RunService:UnbindFromRenderStep(PREVIEW_RENDER)
	end)
	ContextActionService:UnbindAction(PLACE_ACTION)
	ContextActionService:UnbindAction(ROTATE_ACTION)
	ContextActionService:UnbindAction(SNAP_ACTION)
end

return ClientPlacer