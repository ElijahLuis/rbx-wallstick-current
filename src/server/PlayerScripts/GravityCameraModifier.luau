--!strict
return function(PlayerModule)
	if typeof(PlayerModule) ~= "table" then
		return
	end

	if typeof(PlayerModule.GetCameras) ~= "function" then
		return
	end

	local cameraModule = PlayerModule:GetCameras()
	if typeof(cameraModule) ~= "table" then
		return
	end

	local patchCameraModule = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)
	patchCameraModule(cameraModule)
end
