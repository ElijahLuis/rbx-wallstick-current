--!strict
return function(PlayerModule)
	local pm = if typeof(PlayerModule) == "Instance" then require(PlayerModule) else PlayerModule
	local cameraModule = pm:GetCameras()

	if typeof(cameraModule) == "table" then
		local function applyPatch()
			local patchCameraModule = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)
			patchCameraModule(cameraModule)
		end
		applyPatch()
	end
end
