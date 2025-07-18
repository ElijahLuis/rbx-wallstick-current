--!strict

print("[GravityCamera] Loaded completely")

--[=[
	@class GravityCamera
	Client-side interface for interacting with the modified camera controller.
]=]

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerScripts = localPlayer:WaitForChild("PlayerScripts")

local playerModuleObject = require(playerScripts:WaitForChild("PlayerModule"))

-- Patch the camera module before accessing it
local GravityCameraModifier = require(game.ReplicatedStorage.Wallstick.GravityCameraModifier)
GravityCameraModifier(playerModuleObject)

local cameraModuleObject = playerModuleObject:GetCameras() :: any
print("[GravityCamera] cameraModuleObject.SetSpinPart =", cameraModuleObject.SetSpinPart)

local controlModuleObject = playerModuleObject:GetControls() :: any

local GravityCamera = {}

function GravityCamera.getUpVector(): Vector3
	return cameraModuleObject:GetUpVector()
end

function GravityCamera.setUpVector(target: Vector3)
	cameraModuleObject:SetTargetUpVector(target)
end

function GravityCamera.getSpinPart(): BasePart
	return cameraModuleObject:GetSpinPart()
end

function GravityCamera.setSpinPart(part: BasePart)
	cameraModuleObject:SetSpinPart(part)
end

function GravityCamera.getRotationType(): Enum.RotationType
	return cameraModuleObject:GetRotationType()
end

function GravityCamera.getMoveVector(cameraCF: CFrame, inputMove: Vector3?): Vector3
	return controlModuleObject:GetMoveVector()
end

return GravityCamera
