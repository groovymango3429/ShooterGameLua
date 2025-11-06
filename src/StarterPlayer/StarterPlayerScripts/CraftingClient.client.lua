-- CraftingClient.lua
-- Client-side script for Crafting UI, favorites, server-integrated crafting, "I" key toggle, and required item check

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RecipeDatabase = require(ReplicatedStorage.Modules.RecipeDatabase)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local craftingGui = playerGui:WaitForChild("CraftingTab")
local background = craftingGui:WaitForChild("Background")

local categoriesFrame = background:WaitForChild("Categories")
local scrollingFrame = background:WaitForChild("ScrollingFrame")
local itemTemplate = scrollingFrame:FindFirstChild("ItemTemplate")
local craftButton = background:WaitForChild("Craft")

itemTemplate.Visible = false

local favoriteRecipes = {}
local currentCategory = nil
local selectedRecipe = nil
local currentStation = nil -- Track which station we're at (nil = no filter)

-- RemoteEvent for crafting (should exist in ReplicatedStorage)
local Events = ReplicatedStorage:WaitForChild("Events")
local CraftEvent = Events:WaitForChild("CraftEvent")

local function IsRecipeFavorited(recipeName)
	return favoriteRecipes[recipeName] == true
end

local function SetRecipeFavorite(recipeName, isFav)
	favoriteRecipes[recipeName] = isFav
end

local function ClearRecipeItems()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") and child ~= itemTemplate then
			child:Destroy()
		end
	end
end

local function CreateRecipeItem(index, recipe)
	local itemFrame = itemTemplate:Clone()
	itemFrame.Name = "Item" .. tostring(index)
	itemFrame.Visible = true

	if itemFrame:FindFirstChild("Image") then
		local icon = recipe.icon or ""
		itemFrame.Image.Image = icon
	end

	if itemFrame:FindFirstChild("ItemName") then
		itemFrame.ItemName.Text = recipe.name
	end

	-- Favorite logic for ImageButton
	if itemFrame:FindFirstChild("FavouriteButton") then
		local favBtn = itemFrame.FavouriteButton
		local function updateFavoriteVisual()
			favBtn.Image = IsRecipeFavorited(recipe.name)
				and "rbxassetid://11422927314"
				or "rbxassetid://11430231167"
		end
		updateFavoriteVisual()
		favBtn.MouseButton1Click:Connect(function()
			local nowFav = not IsRecipeFavorited(recipe.name)
			SetRecipeFavorite(recipe.name, nowFav)
			updateFavoriteVisual()
			if currentCategory == "Favourites" then
				ShowRecipesByCategory("Favourites")
			end
		end)
	end

	itemFrame.MouseButton1Click:Connect(function()
		ShowRecipeDetails(recipe)
		selectedRecipe = recipe
		UpdateCraftButtonState()
	end)

	itemFrame.Parent = scrollingFrame
end

function ShowRecipesByCategory(category)
	currentCategory = category
	ClearRecipeItems()
	local recipes
	if category == "Favourites" then
		recipes = {}
		for _, recipe in ipairs(RecipeDatabase:GetByCategory("All")) do
			if IsRecipeFavorited(recipe.name) then
				table.insert(recipes, recipe)
			end
		end
	else
		recipes = RecipeDatabase:GetByCategory(category)
	end
	
	-- Filter by station if we're at a workstation
	if currentStation then
		local filteredRecipes = {}
		for _, recipe in ipairs(recipes) do
			local recipeStation = recipe.station or "None"
			if recipeStation == currentStation or recipeStation == "None" then
				table.insert(filteredRecipes, recipe)
			end
		end
		recipes = filteredRecipes
	end
	
	for i, recipe in ipairs(recipes) do
		CreateRecipeItem(i, recipe)
	end
end

function ShowRecipeDetails(recipe)
	selectedRecipe = recipe
	local itemFrame = background:FindFirstChild("Item")
	if itemFrame and itemFrame:FindFirstChild("Image") then
		itemFrame.Image.Image = recipe.icon or ""
	end
	if itemFrame and itemFrame:FindFirstChild("Title") then
		itemFrame.Title.Text = recipe.name
	end

	local descFrame = background:FindFirstChild("Description")
	if descFrame then
		local descText = descFrame:FindFirstChild("Description") and descFrame.Description:FindFirstChild("Text")
		if descText then
			descText.Text = recipe.description or "No description"
		end
	end

	local requiredFrame = background:FindFirstChild("RequiredItems")
	if requiredFrame then
		for i = 1, 4 do
			local itemBox = requiredFrame:FindFirstChild("Item" .. i)
			local req = recipe.requiredItems and recipe.requiredItems[i]
			if itemBox then
				if req then
					itemBox.Visible = true
					if itemBox:FindFirstChild("Image") then itemBox.Image.Image = "" end
					if itemBox:FindFirstChild("Item") then itemBox.Item.Text = req.item end
					if itemBox:FindFirstChild("Quantity") then itemBox.Quantity.Text = "x" .. req.amount end
				else
					itemBox.Visible = false
				end
			end
		end
	end

	local outputsFrame = background:FindFirstChild("Outputs")
	if outputsFrame then
		local outputs = type(recipe.outputItem) == "table" and recipe.outputItem or {recipe.outputItem}
		for i = 1, 2 do
			local outBox = outputsFrame:FindFirstChild("Item" .. i)
			local output = outputs[i]
			if outBox then
				if output then
					outBox.Visible = true
					if outBox:FindFirstChild("Image") then outBox.Image.Image = "" end
					if outBox:FindFirstChild("Item") then outBox.Item.Text = output.item end
					if outBox:FindFirstChild("Quantity") then outBox.Quantity.Text = "x" .. (output.amount or 1) end
				else
					outBox.Visible = false
				end
			end
		end
	end

	UpdateCraftButtonState()
end

-- Utility to check if local inventory has required items (client-side, for button state)
local function HasRequiredItems(recipe)
	-- You should update this to pull from the latest client inventory if available
	return true -- fallback: let server check for security
end

-- Update Craft button enabled/disabled state
function UpdateCraftButtonState()
	if craftButton then
		if selectedRecipe and HasRequiredItems(selectedRecipe) then
			craftButton.AutoButtonColor = true
			craftButton.BackgroundTransparency = 0
			craftButton.Active = true
		else
			craftButton.AutoButtonColor = false
			craftButton.BackgroundTransparency = 0.5
			craftButton.Active = false
		end
	end
end

-- Craft button event: ask server to craft
craftButton.MouseButton1Click:Connect(function()
	if selectedRecipe then
		print("[CLIENT] Craft button clicked for recipe:", selectedRecipe.name)
		CraftEvent:FireServer(selectedRecipe.name)
	else
		print("[CLIENT] No recipe selected!")
	end
end)

-- Listen for DebugMessage from server
local DebugMessageEvent = Events:FindFirstChild("DebugMessage")
if DebugMessageEvent then
	DebugMessageEvent.OnClientEvent:Connect(function(msg)
		print("[SERVER DEBUG]", msg)
		-- Optionally display msg in a GUI popup!
	end)
end

-- Connect category buttons
for _, button in ipairs(categoriesFrame:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseButton1Click:Connect(function()
			ShowRecipesByCategory(button.Text)
		end)
	end
end

-- Function to update station title in UI
local function UpdateStationTitle()
	-- Look for a station title label in the UI
	local titleLabel = background:FindFirstChild("StationTitle")
	if titleLabel and titleLabel:IsA("TextLabel") then
		if currentStation then
			titleLabel.Text = "Crafting at: " .. currentStation
			titleLabel.Visible = true
		else
			titleLabel.Visible = false
		end
	end
end

local function SetMouseVisible(visible)
	UserInputService.MouseIconEnabled = visible
end

-- Listen for OpenCraftingGUI event from server
local OpenCraftingGUIEvent = Events:WaitForChild("OpenCraftingGUI")
OpenCraftingGUIEvent.OnClientEvent:Connect(function(stationName)
	print("[CraftingClient] Opening crafting menu for station:", stationName)
	currentStation = stationName
	background.Visible = true
	UpdateStationTitle()
	ShowRecipesByCategory(currentCategory or "All")
end)

background:GetPropertyChangedSignal("Visible"):Connect(function()
	SetMouseVisible(background.Visible)
	-- Clear station filter when closing GUI
	if not background.Visible then
		currentStation = nil
		UpdateStationTitle()
	end
end)

SetMouseVisible(background.Visible)
ShowRecipesByCategory("All")

local firstRecipes = RecipeDatabase:GetByCategory("All")
if firstRecipes[1] then
	ShowRecipeDetails(firstRecipes[1])
end

-- T key toggles crafting GUI (without station filter)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		background.Visible = not background.Visible
		SetMouseVisible(background.Visible)
		-- Clear station filter when opening manually
		if background.Visible then
			currentStation = nil
			UpdateStationTitle()
			ShowRecipesByCategory(currentCategory or "All")
		end
	end
end)

return {}