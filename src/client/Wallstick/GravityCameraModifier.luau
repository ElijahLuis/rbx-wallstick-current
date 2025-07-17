--!strict
local function patchCameraModule(cameraModule: any)
	local transitionRate: number = 1

	local upCFrame: CFrame = CFrame.identity
	local upVector: Vector3 = upCFrame.YVector
	local targetUpVector: Vector3 = upVector
	local twistCFrame: CFrame = CFrame.identity

	local spinPart: BasePart = workspace.Terrain
	local prevSpinPart: BasePart = spinPart
	local prevSpinCFrame: CFrame = spinPart.CFrame

	local UserGameSettings = UserSettings():GetService("UserGameSettings")
	local RotationUtils = require(game.ReplicatedStorage.Wallstick.RotationUtils)

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
		if inVehicle then
			theta = 0
		elseif spinPart == prevSpinPart then
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

	-- Modify camera controller behavior
	local cameraUtils = require(cameraModule.CameraModule.CameraUtils)
	function cameraUtils.GetAngleBetweenXZVectors(v1: Vector3, v2: Vector3): number
		v1 = upCFrame:VectorToObjectSpace(v1)
		v2 = upCFrame:VectorToObjectSpace(v2)
		return math.atan2(v2.X * v1.Z - v2.Z * v1.X, v2.X * v1.X + v2.Z * v1.Z)
	end

	print("CameraModule type:", typeof(cameraModule))
	print(
		"CameraModule keys:",
		table.concat(
			(function()
				local keys = {}
				for k in pairs(cameraModule) do
					table.insert(keys, tostring(k))
				end
				return keys
			end)(),
			", "
		)
	)

	-- Override cameraModule methods
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

	-- Patch main camera update to include our steps
	local originalUpdate = cameraModule.Update
	function cameraModule:Update(dt: number)
		calculateUpStep(dt)
		calculateSpinStep(dt, self:ShouldUseVehicleCamera())
		return originalUpdate(self, dt)
	end
end
return patchCameraModule
