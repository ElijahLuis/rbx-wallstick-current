--!strict

local Config = require(script.Parent:WaitForChild("WallstickConfig"))

export type GravityController = {
	root: BasePart,
	humanoid: Humanoid,
	planetsFolder: Folder,
	force: VectorForce,
	orientation: AlignOrientation,
	fallTime: number,
	prevDistance: number?,
	outPlanet: BasePart?,
}

local GravityController = {}
GravityController.__index = GravityController

function GravityController.new(character: Model, planetsFolder: Folder): GravityController
	local self = setmetatable({}, GravityController)

	self.planetsFolder = planetsFolder
	self.root = character:WaitForChild("HumanoidRootPart", 5)
	self.humanoid = character:WaitForChild("Humanoid", 5)

	assert(self.root and self.humanoid, "GravityController: character missing required parts")

	local attachment = self.root:FindFirstChild("RootAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "RootAttachment"
		attachment.Parent = self.root
	end

	local force = Instance.new("VectorForce")
	force.Attachment0 = attachment
	force.RelativeTo = Enum.ActuatorRelativeTo.World
	force.Force = Vector3.zero
	force.Enabled = false
	force.Parent = self.root
	self.force = force

	local orient = Instance.new("AlignOrientation")
	orient.Attachment0 = attachment
	orient.Mode = Enum.OrientationAlignmentMode.OneAttachment
	orient.MaxTorque = 1_000_000
	orient.Responsiveness = 50
	orient.Enabled = false
	orient.Parent = self.root
	self.orientation = orient

	self.fallTime = 0
	self.prevDistance = nil
	self.outPlanet = nil

	return self
end

function GravityController:destroy()
	self.force:Destroy()
	self.orientation:Destroy()
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

function GravityController:update(dt: number)
	if self.humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
		if self.force.Enabled then
			self.force.Enabled = false
			self.force.Force = Vector3.zero
		end
		if self.orientation.Enabled then
			self.orientation.Enabled = false
		end
		self.fallTime = 0
		self.prevDistance = nil
		self.outPlanet = nil
		return
	end

	local planet = findNearestPlanet(self.planetsFolder, self.root.Position)
	local distance = planet and (planet.Position - self.root.Position).Magnitude or nil

	if self.outPlanet and planet == self.outPlanet then
		if distance and self.prevDistance and distance >= self.prevDistance then
			local dir = (self.outPlanet.Position - self.root.Position).Unit
			local offset = dir * (self.outPlanet.Size.Magnitude / 2 + 50)
			self.root.AssemblyLinearVelocity = Vector3.zero
			self.root.CFrame = CFrame.new(self.outPlanet.Position + offset)
		end
		self.outPlanet = nil
		self.fallTime = 0
	end

	if distance then
		if self.prevDistance and distance > self.prevDistance then
			self.fallTime += dt
		else
			self.fallTime = 0
		end
		self.prevDistance = distance
	else
		self.fallTime += dt
	end

	if self.fallTime >= Config.OUT_OF_BOUNDS_TIME or (distance and distance > Config.OUT_OF_BOUNDS_DISTANCE) then
		if planet then
			local dir = (planet.Position - self.root.Position).Unit
			local speed = self.root.AssemblyLinearVelocity.Magnitude
			self.root.AssemblyLinearVelocity = dir * speed
			self.force.Enabled = false
			self.force.Force = Vector3.zero
			self.orientation.Enabled = false
			self.outPlanet = planet
			self.prevDistance = distance
		end
		self.fallTime = 0
		return
	end

	if planet then
		local direction = (planet.Position - self.root.Position).Unit
		self.force.Force = direction * self.root.AssemblyMass * Config.PLANET_GRAVITY
		self.force.Enabled = true

		local up = -direction
		local look = self.root.CFrame.LookVector
		self.orientation.CFrame = CFrame.lookAt(self.root.Position, self.root.Position + look, up)
		self.orientation.Enabled = true
	else
		if self.force.Enabled then
			self.force.Enabled = false
			self.force.Force = Vector3.zero
		end
		if self.orientation.Enabled then
			self.orientation.Enabled = false
		end
	end
end

return GravityController
