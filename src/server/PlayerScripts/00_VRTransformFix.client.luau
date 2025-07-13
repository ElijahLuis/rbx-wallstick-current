--!strict

local originalRequire = require

local function defaultApplyVRTransform(self: any, ...)
	if self.activeCameraController and self.activeCameraController.ApplyVRTransform then
		return self.activeCameraController:ApplyVRTransform(...)
	end
	return nil
end

function require(moduleScript: ModuleScript, ...)
	local result = originalRequire(moduleScript, ...)

	if moduleScript.Name == "CameraModule" and type(result) == "table" then
		if result.ApplyVRTransform == nil then
			result.ApplyVRTransform = defaultApplyVRTransform
		end

		-- Also expose the patched method through PlayerModule.CameraModule
		local parent = moduleScript.Parent
		if parent and parent:IsA("ModuleScript") then
			local parentTable = originalRequire(parent)
			if type(parentTable) == "table" and parentTable.CameraModule then
				if parentTable.CameraModule.ApplyVRTransform == nil then
					parentTable.CameraModule.ApplyVRTransform = result.ApplyVRTransform
				end
			end
		end
	elseif moduleScript.Name == "PlayerModule" and type(result) == "table" then
		if result.CameraModule and type(result.CameraModule) == "table" then
			if result.CameraModule.ApplyVRTransform == nil then
				local cameraTable = originalRequire(moduleScript:WaitForChild("CameraModule"))
				if type(cameraTable) == "table" and cameraTable.ApplyVRTransform then
					result.CameraModule.ApplyVRTransform = cameraTable.ApplyVRTransform
				end
			end
		end
	end

	return result
end
