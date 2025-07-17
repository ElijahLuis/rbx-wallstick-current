--!strict
local GravityCameraModifier = require(script.Parent.GravityCameraModifier)

return function(cameraModule: any)
	GravityCameraModifier(cameraModule)
end
