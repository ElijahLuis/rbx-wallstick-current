--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local patched = false

local function patchCameraModule(cameraModule: any)
	if patched or type(cameraModule) ~= "table" then
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

	patched = true
end

local function patchFromScripts(playerModule: ModuleScript)
	if patched then
		return
	end

	local cameraModuleScript = playerModule:FindFirstChild("CameraModule")
	if cameraModuleScript then
		local okCam, cameraModule = pcall(require, cameraModuleScript)
		if okCam then
			patchCameraModule(cameraModule)
		end
	end

	local okPm, pmTable = pcall(require, playerModule)
	if okPm and type(pmTable) == "table" then
		if type(pmTable.CameraModule) ~= "table" and cameraModuleScript then
			local okCam, camMod = pcall(require, cameraModuleScript)
			if okCam then
				pmTable.CameraModule = camMod
			end
		end
		if type(pmTable.CameraModule) == "table" then
			patchCameraModule(pmTable.CameraModule)
		end
	end
end

local function setupWatchers(playerScripts: Instance)
	local function onChildAdded(child: Instance)
		if child.Name == "PlayerModule" and child:IsA("ModuleScript") then
			child.ChildAdded:Connect(function(grand)
				if grand.Name == "CameraModule" then
					patchFromScripts(child)
				end
			end)
			patchFromScripts(child)
		end
	end

	playerScripts.ChildAdded:Connect(onChildAdded)

	for _, child in playerScripts:GetChildren() do
		onChildAdded(child)
		if patched then
			break
		end
	end
end

local function tryPatch(): boolean?
	if patched then
		return true
	end

	local player = Players.LocalPlayer
	if not player then
		return nil
	end

	local playerScripts = player:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return nil
	end

	setupWatchers(playerScripts)

	return if patched then true else nil
end

-- Attempt immediately and keep retrying each render step until patched
if not tryPatch() then
	RunService:BindToRenderStep("VRTransformFix", Enum.RenderPriority.First.Value, function()
		if tryPatch() then
			RunService:UnbindFromRenderStep("VRTransformFix")
		end
	end)
end
