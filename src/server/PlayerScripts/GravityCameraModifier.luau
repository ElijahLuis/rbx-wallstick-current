--!strict
return function(PlayerModule)
	local pm = if typeof(PlayerModule) == "Instance" then require(PlayerModule) else PlayerModule
	local cameraModule = pm:GetCameras()
	local patchCamera = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)
	patchCamera(cameraModule)
end
