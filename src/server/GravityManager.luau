--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GravityController = require(ReplicatedStorage:WaitForChild("GravityController"))
local Config = require(ReplicatedStorage:WaitForChild("WallstickConfig"))

local Planets = workspace:WaitForChild("Planets")

local controllers: { [Player]: GravityController.GravityController } = {}

local GravityManager = {}

local function setupCharacter(player: Player, character: Model)
       controllers[player] = GravityController.new(character, Planets, player)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		local ctrl = controllers[player]
		if ctrl then
			ctrl:destroy()
			controllers[player] = nil
		end
	end)
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)
	if player.Character then
		setupCharacter(player, player.Character)
	end
end

local function onPlayerRemoving(player: Player)
	local ctrl = controllers[player]
	if ctrl then
		ctrl:destroy()
		controllers[player] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end


RunService.Heartbeat:Connect(function(dt)
	for _, controller in pairs(controllers) do
		controller:update(dt)

	end
end)

return GravityManager
