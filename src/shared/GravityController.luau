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
}

local GravityController = {}
GravityController.__index = GravityController

function GravityController.new(character: Model, planetsFolder: Folder): GravityController?
	local self = setmetatable({}, GravityController)

	self.planetsFolder = planetsFolder
	self.root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 10)
	self.humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 10)

	if not self.root or not self.humanoid then
		warn("GravityController: character missing required parts")
		return nil
	end

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

		return
	end

	local planet = findNearestPlanet(self.planetsFolder, self.root.Position)

	local distance = planet and (planet.Position - self.root.Position).Magnitude or nil

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
			local radius = planet.Size.Magnitude / 2
			local target = planet.Position + dir * (radius + Config.STICK_RANGE)
			self.humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			self.root.AssemblyLinearVelocity = Vector3.zero
			self.root.CFrame = CFrame.new(target, planet.Position)
			self.force.Enabled = false
			self.force.Force = Vector3.zero
			self.orientation.Enabled = false
		end
		self.fallTime = 0
		self.prevDistance = nil
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
