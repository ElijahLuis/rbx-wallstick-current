--!strict

local function patchCameraModule(playerModuleObject: any)
	print("[Modifier] GravityCameraModifier running...")

	local cameraModule = playerModuleObject:GetCameras()
	local transitionRate: number = 1

	local upCFrame: CFrame = CFrame.identity
	local upVector: Vector3 = upCFrame.YVector
	local targetUpVector: Vector3 = upVector
	local twistCFrame: CFrame = CFrame.identity

	local spinPart: BasePart = workspace.Terrain
	local prevSpinPart: BasePart = spinPart
	local prevSpinCFrame: CFrame = spinPart.CFrame

	local RotationUtils = require(game.ReplicatedStorage.Wallstick.RotationUtils)
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local cameraUtils = require(localPlayer:WaitForChild("PlayerScripts")
	:WaitForChild("PlayerModule")
	:WaitForChild("CameraModule")
	:WaitForChild("CameraUtils"))

	local function swingTwist(inputCF: CFrame, relativeUnitAxis: Vector3)
		local axis, theta = inputCF:ToAxisAngle()
		local w, v = math.cos(theta / 2), math.sin(theta / 2) * axis
		local proj = v:Dot(relativeUnitAxis) * relativeUnitAxis
		local twist = CFrame.new(0, 0, 0, proj.X, proj.Y, proj.Z, w)
		local swing = inputCF * twist:Inverse()
		return swing, twist
	end

	local function calculateUpStep(_dt: number)
		local axis = workspace.CurrentCamera.CFrame.RightVector
		local sphericalArc = RotationUtils.fromToRotation(upVector, targetUpVector, axis)
		local transitionCF = CFrame.new():Lerp(sphericalArc, transitionRate)
		upVector = transitionCF * upVector
		upCFrame = transitionCF * upCFrame
	end

	local function calculateSpinStep(_dt: number, inVehicle: boolean)
		local theta = 0
		if not inVehicle and spinPart == prevSpinPart then
			local rotation = spinPart.CFrame.Rotation
			local prevRotation = prevSpinCFrame.Rotation
			local delta = prevRotation:ToObjectSpace(rotation)
			local spinAxis = delta:VectorToObjectSpace(prevRotation:VectorToObjectSpace(upVector))
			local _, twist = swingTwist(delta, spinAxis)
			local deltaAxis, _ = delta:ToAxisAngle()
			local _, twistTheta = twist:ToAxisAngle()
			theta = math.sign(deltaAxis:Dot(spinAxis)) * twistTheta
		end
		twistCFrame = CFrame.fromEulerAnglesYXZ(0, theta, 0)
		prevSpinPart = spinPart
		prevSpinCFrame = spinPart.CFrame
	end

	-- Override camera utility methods
	function cameraUtils.GetAngleBetweenXZVectors(v1: Vector3, v2: Vector3): number
		v1 = upCFrame:VectorToObjectSpace(v1)
		v2 = upCFrame:VectorToObjectSpace(v2)
		return math.atan2(v2.X * v1.Z - v2.Z * v1.X, v2.X * v1.X + v2.Z * v1.Z)
	end

	-- Override camera module methods
	function cameraModule:GetUpVector()
		return upVector
	end
	function cameraModule:GetTargetUpVector()
		return targetUpVector
	end
	function cameraModule:SetTargetUpVector(target: Vector3)
		targetUpVector = target
	end
	function cameraModule:GetSpinPart()
		return spinPart
	end
	function cameraModule:SetSpinPart(part: BasePart)
		spinPart = part
	end
	function cameraModule:SetTransitionRate(rate: number)
		transitionRate = rate
	end
	function cameraModule:GetTransitionRate(): number
		return transitionRate
	end
	function cameraModule:GetRotationType()
	return Enum.RotationType.CameraRelative
end

	local originalUpdate = cameraModule.Update
	function cameraModule:Update(dt: number)
		calculateUpStep(dt)
		calculateSpinStep(dt, self:ShouldUseVehicleCamera())
		return originalUpdate(self, dt)
	end

	-- CRITICAL PATCH
	-- Override GetCameras to return our patched cameraModule
	if playerModuleObject.originalGetCameras == nil then
		playerModuleObject.originalGetCameras = playerModuleObject.GetCameras
	end

	function playerModuleObject:GetCameras()
		print("[Modifier] Overridden GetCameras() hit!")
		return cameraModule
	end

	print("[Modifier] Patch complete. SetSpinPart =", cameraModule.SetSpinPart)
end

return function(playerModuleObject)
	patchCameraModule(playerModuleObject)
	return playerModuleObject
end
