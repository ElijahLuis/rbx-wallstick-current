--!strict
local PatchCameraModule = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)

local Patch = {}

function Patch.redirect(cameraModule: any)
	PatchCameraModule(cameraModule)
end

return Patch
