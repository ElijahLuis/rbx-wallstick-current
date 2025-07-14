--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

	local success, cameraModule = pcall(require, playerModule:FindFirstChild("CameraModule"))
	if success and type(cameraModule) == "table" then
		patchCameraModule(cameraModule)
	else
		return nil
	end

	local successPm, pmTable = pcall(require, playerModule)
	if successPm and type(pmTable) == "table" and type(pmTable.CameraModule) == "table" then
		patchCameraModule(pmTable.CameraModule)
	end

	RunService:UnbindFromRenderStep("VRTransformFix")
	return true
end

-- Attempt immediately and keep retrying each render step until patched
if not tryPatch() then
	RunService:BindToRenderStep("VRTransformFix", Enum.RenderPriority.First.Value, tryPatch)
end
