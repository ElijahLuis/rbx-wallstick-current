--!strict
local patched = setmetatable({}, { __mode = "k" })

return function(cameraModule: any)
	if not patched[cameraModule] then
		patched[cameraModule] = true
		local GravityCameraModifier = require(script.Parent.GravityCameraModifier)
		GravityCameraModifier(cameraModule)
	end
end
