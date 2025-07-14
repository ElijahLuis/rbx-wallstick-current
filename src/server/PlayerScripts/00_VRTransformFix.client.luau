--!strict

local Players = game:GetService("Players")

local function patchCameraModule(cameraModule: any)
	local function fallback(self: any, ...)
		if self.activeCameraController and self.activeCameraController.ApplyVRTransform then
			return self.activeCameraController:ApplyVRTransform(...)
		end
		return nil
	end

	local function applyTo(object: any)
		if object.ApplyVRTransform == nil then
			object.ApplyVRTransform = fallback
		end
	end

	applyTo(cameraModule)

	if type(cameraModule.new) == "function" then
		local originalNew = cameraModule.new
		cameraModule.new = function(...)
			local obj = originalNew(...)
			applyTo(obj)
			return obj
		end
	end

	-- Also provide the method through a metatable so colon calls succeed
	local mt = getmetatable(cameraModule) or {}
	local originalIndex = mt.__index
	mt.__index = function(t, k)
		if k == "ApplyVRTransform" then
			return fallback
		end
		if originalIndex then
			if type(originalIndex) == "function" then
				return originalIndex(t, k)
			else
				return originalIndex[k]
			end
		end
		return nil
	end
	setmetatable(cameraModule, mt)
end

local function attachPlayerModule(playerModule: Instance)
	-- Grab the actual camera ModuleScript which may be nested in a folder
	local cameraFolder = playerModule:WaitForChild("CameraModule")
	local cameraScript = if cameraFolder:IsA("ModuleScript")
		then cameraFolder
		else cameraFolder:WaitForChild("CameraModule")

	local ok, cameraModule = pcall(require, cameraScript)
	if ok and type(cameraModule) == "table" then
		patchCameraModule(cameraModule)
	end

	local okPm, pmTable = pcall(require, playerModule)
	if okPm and type(pmTable) == "table" and type(pmTable.CameraModule) == "table" then
		patchCameraModule(pmTable.CameraModule)
	end
end

local function onPlayerScripts(playerScripts: Instance)
	if playerScripts:FindFirstChild("PlayerModule") then
		attachPlayerModule(playerScripts.PlayerModule)
	end

	playerScripts.ChildAdded:Connect(function(child)
		if child.Name == "PlayerModule" then
			attachPlayerModule(child)
		end
	end)
end

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

if player:FindFirstChild("PlayerScripts") then
	onPlayerScripts(player.PlayerScripts)
else
	player.ChildAdded:Connect(function(child)
		if child.Name == "PlayerScripts" then
			onPlayerScripts(child)
		end
	end)
end
