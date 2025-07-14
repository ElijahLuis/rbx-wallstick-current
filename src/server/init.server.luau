--!strict

local PhysicsService = game:GetService("PhysicsService") :: PhysicsService

local PlayerScripts = require(script.PlayerScripts)
require(script.GravityManager)

if not game.ReplicatedStorage:FindFirstChild("Wallstick") then
	warn("[Wallstick] Wallstick modules missing. Did you run 'rojo build'?")
	return
end

local ok, Replication = pcall(require, game.ReplicatedStorage.Wallstick.Replication)
if not ok then
	warn("[Wallstick] Failed to load replication module. Ensure dependencies are installed.")
	return
end

local Config = require(game.ReplicatedStorage:WaitForChild("WallstickConfig"))

-- Private

local function setupCollisions()
	PhysicsService:RegisterCollisionGroup("WallstickCollision")
	PhysicsService:RegisterCollisionGroup("WallstickNoCollision")

	for _, group in PhysicsService:GetRegisteredCollisionGroups() do
		PhysicsService:CollisionGroupSetCollidable(group.name, "WallstickCollision", false)
		PhysicsService:CollisionGroupSetCollidable(group.name, "WallstickNoCollision", false)
	end

	PhysicsService:CollisionGroupSetCollidable("WallstickCollision", "WallstickCollision", true)
end

--

local wallstickFolder = Instance.new("Folder")
wallstickFolder.Name = "Wallstick"
wallstickFolder.Parent = workspace

PlayerScripts.setup()
setupCollisions()

Replication.listenServer()
