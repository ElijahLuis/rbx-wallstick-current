--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
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
	local modifiers = require(patched:WaitForChild("Modifiers")) :: any
	modifiers.add(script.GravityCameraModifier)
	PlayerModulePackage.replace(patched)

	local renamedCharacterSounds = script.CharacterSounds:Clone()
	renamedCharacterSounds.Name = "RbxCharacterSounds"

	replaceIfPresent(StarterCharacterScripts, script.Animate:Clone())
	replaceIfPresent(StarterPlayerScripts, renamedCharacterSounds)
	-- Patch PlayerModule for VR before PlayerScriptsLoader initializes
	replaceIfPresent(StarterPlayerScripts, script["00_VRTransformFix"]:Clone())
end

return PlayerScriptsModule
