--!strict
local patched = setmetatable({}, { __mode = "k" })

local function apply(cameraModule: any)
	if typeof(cameraModule) == "table" and not patched[cameraModule] then
		patched[cameraModule] = true
		local patchCamera = require(game.ReplicatedStorage.Wallstick.PatchCameraModule)
		patchCamera(cameraModule)
	end
end

local Patch = { redirect = apply }

return setmetatable(Patch, {
	__call = function(_, cameraModule: any)
		apply(cameraModule)
	end,
})
