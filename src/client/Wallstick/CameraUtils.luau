--!strict
-- minimal placeholder
local CameraUtils = {}

function CameraUtils.GetAngleBetweenXZVectors(v1: Vector3, v2: Vector3): number
	return math.atan2(v2.X * v1.Z - v2.Z * v1.X, v2.X * v1.X + v2.Z * v1.Z)
end

return CameraUtils
