--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local StarterCharacterScripts = StarterPlayer:WaitForChild("StarterCharacterScripts")

local ServerPackages = ServerScriptService.ServerPackages
local PlayerModulePackage = require(ServerPackages.PlayerModule)

local PlayerScriptsModule = {}

local function replaceIfPresent(parent: Instance, instance: Instance)
	local found = parent:FindFirstChild(instance.Name)
	if found then
		found:Destroy()
	end

	instance.Parent = parent
end

function PlayerScriptsModule.setup()
       local patched = PlayerModulePackage.getCopy(true)

       -- Patch the CameraModule before any client code runs so PlayerScriptsLoader
       -- never encounters a missing ApplyVRTransform method.
       local cameraScript = patched:FindFirstChild("CameraModule", true)
       if cameraScript and cameraScript:IsA("ModuleScript") then
               local ok, cameraModule = pcall(require, cameraScript)
               if ok and type(cameraModule) == "table" and type(cameraModule.ApplyVRTransform) ~= "function" then
                       function cameraModule:ApplyVRTransform(transform: CFrame?)
                               if typeof(transform) == "CFrame" then
                                       local cam = workspace.CurrentCamera
                                       if cam then
                                               cam.CFrame *= transform
                                       end
                               end
                       end
               end
       end

       local modifiers = require(patched:WaitForChild("Modifiers")) :: any
       modifiers.add(script.GravityCameraModifier)
       PlayerModulePackage.replace(patched)

	local renamedCharacterSounds = script.CharacterSounds:Clone()
	renamedCharacterSounds.Name = "RbxCharacterSounds"

	replaceIfPresent(StarterCharacterScripts, script.Animate:Clone())
	replaceIfPresent(StarterPlayerScripts, renamedCharacterSounds)
	-- Ensure VR compatibility before PlayerScriptsLoader runs
	replaceIfPresent(StarterPlayerScripts, script["00_VRTransformFix"]:Clone())
end

return PlayerScriptsModule
