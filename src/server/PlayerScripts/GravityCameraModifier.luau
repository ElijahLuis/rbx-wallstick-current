--!strict
local patchCamera = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)

return function(PlayerModule)
	local pm = if typeof(PlayerModule) == "Instance" then require(PlayerModule) else PlayerModule
	local cameraModule = pm:GetCameras()
	patchCamera(cameraModule)
end
