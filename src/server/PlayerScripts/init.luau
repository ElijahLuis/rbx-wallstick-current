--!strict

local StarterPlayer = game:GetService("StarterPlayer")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local StarterCharacterScripts = StarterPlayer:WaitForChild("StarterCharacterScripts")

local ServerPackages = ServerScriptService:WaitForChild("ServerPackages")
local PlayerModulePackage = require(ServerPackages:WaitForChild("PlayerModule"))

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

	local stub = script:FindFirstChild("TransparencyController")
	if stub then
		replaceIfPresent(patched.CameraModule, stub:Clone())
	end

	PlayerModulePackage.replace(patched)

	local renamedCharacterSounds = script.CharacterSounds:Clone()
	renamedCharacterSounds.Name = "RbxCharacterSounds"

	replaceIfPresent(StarterCharacterScripts, script.Animate:Clone())
	replaceIfPresent(StarterPlayerScripts, renamedCharacterSounds)
end

return PlayerScriptsModule
