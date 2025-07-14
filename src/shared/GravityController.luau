--!strict

local RunService = game:GetService("RunService")
local Config = require(script.Parent:WaitForChild("WallstickConfig"))

export type GravityController = {
	root: BasePart,
	humanoid: Humanoid,
	planetsFolder: Folder,
	force: VectorForce,
}

local GravityController = {}
GravityController.__index = GravityController

function GravityController.new(character: Model, planetsFolder: Folder): GravityController
	local self = setmetatable({}, GravityController)

	self.planetsFolder = planetsFolder
	self.root = character:WaitForChild("HumanoidRootPart")
	self.humanoid = character:WaitForChild("Humanoid")

	local attachment = self.root:WaitForChild("RootAttachment")
	local force = Instance.new("VectorForce")
	force.Attachment0 = attachment
	force.RelativeTo = Enum.ActuatorRelative.World
	force.Force = Vector3.zero
	force.Enabled = false
	force.Parent = self.root

	self.force = force

	return self
end

function GravityController:destroy()
	self.force:Destroy()
end

local function findNearestPlanet(planets: Folder, position: Vector3)
	local closest
	local closestDist = math.huge

	for _, planet in ipairs(planets:GetChildren()) do
		if planet:IsA("BasePart") and planet.Name:sub(1, 6) == "Planet" then
			local dist = (planet.Position - position).Magnitude
			local radius = planet.Size.Magnitude * Config.PLANET_ORBIT_MULTIPLIER
			if dist <= radius and dist < closestDist then
				closest = planet
				closestDist = dist
			end
		end
	end

	return closest
end

function GravityController:update()
	if self.humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
		if self.force.Enabled then
			self.force.Enabled = false
			self.force.Force = Vector3.zero
		end
		return
	end

	local planet = findNearestPlanet(self.planetsFolder, self.root.Position)
	if planet then
		local direction = (planet.Position - self.root.Position).Unit
		self.force.Force = direction * self.root.AssemblyMass * Config.PLANET_GRAVITY
		self.force.Enabled = true
	else
		if self.force.Enabled then
			self.force.Enabled = false
			self.force.Force = Vector3.zero
		end
	end
end

return GravityController
