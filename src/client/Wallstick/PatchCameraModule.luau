--!strict
local patched = setmetatable({}, { __mode = "k" })

return function(cameraModule: any)
	if typeof(cameraModule) == "table" and not patched[cameraModule] then
		patched[cameraModule] = true
		local GravityCameraModifier = require(script.Parent.GravityCameraModifier)
		GravityCameraModifier(cameraModule)
	end
end
