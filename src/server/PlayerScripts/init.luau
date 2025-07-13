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
	local modifiers = require(patched:WaitForChild("Modifiers")) :: any
	modifiers.add(script.GravityCameraModifier)
	PlayerModulePackage.replace(patched)

	local renamedCharacterSounds = script.CharacterSounds:Clone()
	renamedCharacterSounds.Name = "RbxCharacterSounds"

       replaceIfPresent(StarterCharacterScripts, script.Animate:Clone())
       replaceIfPresent(StarterPlayerScripts, renamedCharacterSounds)
       -- Ensure VR compatibility before PlayerScriptsLoader runs
       replaceIfPresent(StarterPlayerScripts, script.VRTransformFix:Clone())
end

return PlayerScriptsModule
