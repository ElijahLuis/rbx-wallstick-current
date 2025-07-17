--!strict
return function(PlayerModule)
	local pm = if typeof(PlayerModule) == "Instance" then require(PlayerModule) else PlayerModule
	local cameraModule = pm:GetCameras()

	-- load the patch table if it exists on the player module's camera folder
	local patchScript = if typeof(pm.CameraModule) == "Instance" then pm.CameraModule:FindFirstChild("Patch") else nil
	if patchScript then
		local Patch = require(patchScript)
		if typeof(Patch) == "table" and typeof(Patch.redirect) == "function" then
			Patch.redirect(cameraModule)
		end
	end
end
