local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TakeDamageEvent = ReplicatedStorage:WaitForChild("TakeDamageEvent")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

TakeDamageEvent.OnClientEvent:Connect(function(damage)
	if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character.Humanoid:TakeDamage(damage)
	end
end)