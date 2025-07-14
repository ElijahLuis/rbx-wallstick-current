--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function patchCameraModule(cameraModule: any)
       if type(cameraModule) ~= "table" then
               return
       end
       if cameraModule.ApplyVRTransform == nil then
               function cameraModule:ApplyVRTransform(...)
                       if self.activeCameraController and self.activeCameraController.ApplyVRTransform then
                               return self.activeCameraController:ApplyVRTransform(...)
                       end
                       return nil
               end
       end
end

local function tryPatch(): boolean?
	local player = Players.LocalPlayer
	if not player then
		return nil
	end

	local playerScripts = player:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return nil
	end

	local playerModule = playerScripts:FindFirstChild("PlayerModule")
	if not playerModule then
		return nil
	end

       local cameraModuleScript = playerModule:FindFirstChild("CameraModule")
       if not cameraModuleScript then
               return nil
       end

       local camSuccess, cameraModule = pcall(require, cameraModuleScript)
       if not camSuccess or type(cameraModule) ~= "table" then
               return nil
       end

       local pmSuccess, pmTable = pcall(require, playerModule)
       if pmSuccess and type(pmTable) == "table" then
               if type(pmTable.CameraModule) ~= "table" then
                       pmTable.CameraModule = cameraModule
               end
               patchCameraModule(pmTable.CameraModule)
       end

       patchCameraModule(cameraModule)

       RunService:UnbindFromRenderStep("VRTransformFix")
       return true
end

-- Attempt immediately and keep retrying each render step until patched
if not tryPatch() then
	RunService:BindToRenderStep("VRTransformFix", Enum.RenderPriority.First.Value, tryPatch)
end
