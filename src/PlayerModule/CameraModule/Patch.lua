--!strict
local Patch = {}

function Patch.redirect(cameraModule: any)
	local PatchCameraModule = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)
	PatchCameraModule(cameraModule)
end

return Patch
