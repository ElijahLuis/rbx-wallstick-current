--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function patchCameraModule(cameraModule: any)
        if type(cameraModule.ApplyVRTransform) ~= "function" then
                -- Modern Roblox no longer exposes Camera:ApplyVRTransform.
                -- Provide a shim that directly offsets the current camera CFrame
                -- to maintain compatibility with older loaders that may call it.
                function cameraModule:ApplyVRTransform(transform: CFrame?)
                        if typeof(transform) == "CFrame" then
                                local cam = workspace.CurrentCamera
                                cam.CFrame *= transform
                        end
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
        if not cameraModuleScript or not cameraModuleScript:IsA("ModuleScript") then
                return nil
        end

        local success, cameraModule = pcall(require, cameraModuleScript)
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
