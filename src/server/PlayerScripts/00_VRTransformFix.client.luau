--!strict

-- Ensure ApplyVRTransform exists before PlayerScriptsLoader runs.
-- This prevents errors when the loader expects a VR handler in Studio.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local playerModuleScript = playerScripts:WaitForChild("PlayerModule")
local playerModule = require(playerModuleScript)

local cameraModuleScript = playerModuleScript:WaitForChild("CameraModule")
local cameraModule = require(cameraModuleScript)
if cameraModule.ApplyVRTransform == nil then
	local function defaultApplyVRTransform(self: any, ...)
		if self.activeCameraController and self.activeCameraController.ApplyVRTransform then
			return self.activeCameraController:ApplyVRTransform(...)
		end
		return nil
	end

	cameraModule.ApplyVRTransform = defaultApplyVRTransform
end

-- Some modules may reference the CameraModule through PlayerModule.CameraModule.
-- Ensure they see the patched method as well.
if playerModule.CameraModule and playerModule.CameraModule.ApplyVRTransform == nil then
	playerModule.CameraModule.ApplyVRTransform = cameraModule.ApplyVRTransform
end
