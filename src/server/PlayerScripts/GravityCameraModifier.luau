--!strict
local GravityCameraModifier = require(game.ReplicatedStorage.Wallstick.GravityCameraModifier)

return function(PlayerModule)
	local cameraModule = PlayerModule:GetCameras()
	GravityCameraModifier(cameraModule)
end
