--!strict

local Players = game:GetService("Players")

local function patchCameraModule(cameraModule: any)
	if cameraModule.ApplyVRTransform == nil then
		function cameraModule:ApplyVRTransform(...)
			if self.activeCameraController and self.activeCameraController.ApplyVRTransform then
				return self.activeCameraController:ApplyVRTransform(...)
			end
			return nil
		end
	end
end

local function init()
	local player = Players.LocalPlayer
	if not player then
		player = Players.PlayerAdded:Wait()
	end

	local playerScripts = player:WaitForChild("PlayerScripts")
	local playerModule = playerScripts:WaitForChild("PlayerModule")

	-- Ensure CameraModule has a fallback
	local cameraModule = require(playerModule:WaitForChild("CameraModule"))
	patchCameraModule(cameraModule)

	-- Also patch through PlayerModule if it exposes CameraModule
	local pmTable = require(playerModule)
	if type(pmTable) == "table" and type(pmTable.CameraModule) == "table" then
		patchCameraModule(pmTable.CameraModule)
	end
end

init()
