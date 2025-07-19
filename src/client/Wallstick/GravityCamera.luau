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

function GravityCamera.getMoveVector(cameraCF: CFrame, inputMove: Vector3?, scale: number?): Vector3
	local move = inputMove or controlModuleObject:GetMoveVector()

	if move.Magnitude > 1e-6 then
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			move = move.Unit * humanoid.WalkSpeed
		else
			move = move.Unit
		end
	end

	local _, _, _, r00, r01, r02, _, r11, r12, _, _, r22 = cameraCF:GetComponents()
	local c, s
	local q = if r11 >= 0 then 1 else -1

	if r12 < 1 and r12 > -1 then
		c = r22
		s = r02
	else
		c = r00
		s = -r01 * math.sign(r12)
	end

	local norm = math.sqrt(c * c + s * s)
	if norm < 1e-6 then
		return move
	end

	local x = (c * move.X * q + s * move.Z) / norm
	local z = (c * move.Z - s * move.X * q) / norm
	local result = Vector3.new(x, 0, z)

	if scale then
		result *= scale
	end

	return result
end

function GravityCamera.getTwistCFrame(): CFrame
	return cameraModuleObject:GetTwistCFrame()
end

return GravityCamera
