--!strict

local RotationUtils = {}

function RotationUtils.fromToRotation(from: Vector3, to: Vector3, backupUnitAxis: Vector3?): CFrame
	local dot = from:Dot(to)
	if dot < -0.99999 then
		return if backupUnitAxis
			then CFrame.fromAxisAngle(backupUnitAxis, math.pi)
			else CFrame.fromRotationBetweenVectors(from, to)
	end
	local qv = from:Cross(to)
	local qw = math.sqrt(from:Dot(from) * to:Dot(to)) + dot
	return CFrame.new(0, 0, 0, qv.X, qv.Y, qv.Z, qw)
end

return RotationUtils
