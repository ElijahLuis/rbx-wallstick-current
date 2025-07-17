--!strict
local GravityCameraModifier = require(script.Parent.GravityCameraModifier)

local patched = setmetatable({}, { __mode = "k" })

return function(cameraModule: any)
	if not patched[cameraModule] then
		patched[cameraModule] = true
		GravityCameraModifier(cameraModule)
	end
end
