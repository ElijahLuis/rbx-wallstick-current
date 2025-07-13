--!strict

-- Ensure ApplyVRTransform exists before PlayerScriptsLoader runs.
-- This prevents errors when the loader expects a VR handler in Studio.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local playerModule = require(playerScripts:WaitForChild("PlayerModule"))

local cameraModule = playerModule.CameraModule
if cameraModule.ApplyVRTransform == nil then
local function defaultApplyVRTransform(self: any, ...)
if self.activeCameraController and self.activeCameraController.ApplyVRTransform then
return self.activeCameraController:ApplyVRTransform(...)
end
return nil
end
cameraModule.ApplyVRTransform = defaultApplyVRTransform
end
