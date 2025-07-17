--!strict
local patched = setmetatable({}, { __mode = "k" })

local Patch = {}

function Patch.redirect(cameraModule: any)
	if typeof(cameraModule) == "table" and not patched[cameraModule] then
		patched[cameraModule] = true
		local patchCamera = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)
		patchCamera(cameraModule)
	end
end

return Patch
