--!strict
local GravityCameraModifier = require(game.ReplicatedStorage.Wallstick.GravityCameraModifier)

return function(PlayerModule)
	local pm = if typeof(PlayerModule) == "Instance" then require(PlayerModule) else PlayerModule
	local cameraModule = pm:GetCameras()
	GravityCameraModifier(cameraModule)
end
