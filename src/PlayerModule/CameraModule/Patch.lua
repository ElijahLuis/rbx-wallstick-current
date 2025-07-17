--!strict
local patched = setmetatable({}, { __mode = "k" })

local Patch = {}

function Patch.redirect(cameraModule: any)
	if not patched[cameraModule] then
		patched[cameraModule] = true
		local patchCamera = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)
		patchCamera(cameraModule)
	end
end

return Patch
