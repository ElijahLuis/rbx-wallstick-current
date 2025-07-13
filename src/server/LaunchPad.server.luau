--!strict

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local attributeName = "DestinationPlanet"
local launchSpeed = 300 -- studs per second

local launchPad = script.Parent
assert(launchPad:IsA("BasePart"), "LaunchPad script must be parented to a BasePart")

local planetsFolder = workspace:WaitForChild("Planets")

local function getDestination(): BasePart?
    local name = launchPad:GetAttribute(attributeName)
    if typeof(name) == "string" then
        local planet = planetsFolder:FindFirstChild(name)
        if planet then
            if planet:IsA("BasePart") then
                return planet
            elseif planet:IsA("Model") then
                return planet.PrimaryPart or planet:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    return nil
end

local function onTouched(other: BasePart)
    local character = other:FindFirstAncestorOfClass("Model")
    if not character then return end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local root = humanoid and humanoid.RootPart
    if not root or not root:IsDescendantOf(workspace) then return end

    local destination = getDestination()
    if not destination then return end

    local direction = (destination.Position - root.Position).Unit

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = direction * launchSpeed
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.P = 1e4
    bodyVelocity.Parent = root

    Debris:AddItem(bodyVelocity, 1)
end

launchPad.Touched:Connect(onTouched)
