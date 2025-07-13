--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedPackages = ReplicatedStorage:FindFirstChild("SharedPackages")
local CharacterAnimate = nil
if SharedPackages then
	CharacterAnimate = require(SharedPackages:WaitForChild("CharacterAnimate"))
end

if not CharacterAnimate or typeof(CharacterAnimate.animate) ~= "function" then
	warn("[Wallstick] CharacterAnimate.animate missing; using fallback")
	CharacterAnimate = {
		animate = function()
			return {
				cleanup = function() end,
				playEmote = function() end,
			}
		end,
	}
end

local animate = script.Parent
local character = animate.Parent
local performer = character:WaitForChild("Humanoid")

local AnimateControllerModule = {}
local activeController

function AnimateControllerModule.matchAnimate(director: Humanoid)
	if activeController then
		activeController.cleanup()
	end

	activeController = CharacterAnimate.animate(animate, director, performer)
end

animate:WaitForChild("PlayEmote").OnInvoke = function(emote)
	return activeController.playEmote(emote)
end

AnimateControllerModule.matchAnimate(performer)

return AnimateControllerModule
