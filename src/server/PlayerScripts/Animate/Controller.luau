--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedPackages = ReplicatedStorage.SharedPackages
local CharacterAnimate = require(SharedPackages.CharacterAnimate)

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
