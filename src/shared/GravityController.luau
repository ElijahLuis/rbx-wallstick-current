--!strict

-- Handles planetary gravity for characters on server
local Config = require(script.Parent:WaitForChild("WallstickConfig"))

local FALL_TIME_LIMIT = Config.FALL_TIME_LIMIT
local MAX_DISTANCE = Config.MAX_DISTANCE
local REBOUND_FORCE_MULTIPLIER = Config.REBOUND_FORCE_MULTIPLIER
local REBOUND_COOLDOWN = Config.REBOUND_COOLDOWN
local REBOUND_SOFT_TIME = Config.REBOUND_SOFT_TIME
local GROUND_CHECK_DISTANCE = 4

export type GravityController = {
	root: BasePart,
	humanoid: Humanoid,
	planetsFolder: Folder,
	force: VectorForce,
	orientation: AlignOrientation,
	fallTime: number,
	lastVelocity: Vector3,
	isOutOfBounds: boolean,
	reboundTarget: BasePart?,
	reboundLaunched: boolean,
	storedSpeed: number,
	rayParams: RaycastParams,
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

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	params.IgnoreWater = true
	self.rayParams = params

	self.fallTime = 0
	self.lastVelocity = Vector3.zero
	self.isOutOfBounds = false
	self.reboundTarget = nil
	self.reboundLaunched = false
	self.storedSpeed = 0

	return self
end

function GravityController:destroy()
	self.force:Destroy()
	self.orientation:Destroy()
end

local function planetRadius(planet: BasePart): number
	return math.max(planet.Size.X, planet.Size.Y, planet.Size.Z) / 2
end

-- Finds closest planet within orbit radius
local function findNearestPlanet(planets: Folder, position: Vector3)
	local closest
	local closestDist = math.huge

	for _, planet in ipairs(planets:GetChildren()) do
		if planet:IsA("BasePart") and planet.Name:sub(1, 6) == "Planet" then
			local dist = (planet.Position - position).Magnitude
			local radius = planetRadius(planet) * Config.PLANET_ORBIT_MULTIPLIER
			if dist <= radius and dist < closestDist then
				closest = planet
				closestDist = dist
			end
		end
	end

	return closest
end

local function findClosestPlanet(planets: Folder, position: Vector3)
	local closest
	local closestDist = math.huge

	for _, planet in ipairs(planets:GetChildren()) do
		if planet:IsA("BasePart") and planet.Name:sub(1, 6) == "Planet" then
			local dist = (planet.Position - position).Magnitude
			if dist < closestDist then
				closest = planet
				closestDist = dist
			end
		end
	end

	return closest, closestDist
end

function GravityController:isGrounded()
	local result = workspace:Raycast(self.root.Position, Vector3.new(0, -GROUND_CHECK_DISTANCE, 0), self.rayParams)
	return result ~= nil
end

function GravityController:isFalling()
	return self.root.AssemblyLinearVelocity.Y < -0.1 and not self:isGrounded()
end

function GravityController:isTooFarFromAnyPlanet()
	local _, dist = findClosestPlanet(self.planetsFolder, self.root.Position)
	return not dist or dist > MAX_DISTANCE
end

function GravityController:getNearestPlanet()
	local planet = select(1, findClosestPlanet(self.planetsFolder, self.root.Position))
	return planet
end

function GravityController:update(dt: number)
	if not self.root or not self.humanoid then
		return
	end

	self.lastVelocity = self.root.AssemblyLinearVelocity

	if self:isGrounded() then
		if self.force.Enabled then
			self.force.Enabled = false
			self.force.Force = Vector3.zero
		end
		if self.orientation.Enabled then
			self.orientation.Enabled = false
		end

		self.fallTime = 0
		if self.isOutOfBounds then
			self.root:SetAttribute("IsOutOfBounds", false)
		end
		self.isOutOfBounds = false
		self.reboundTarget = nil
		self.reboundLaunched = false

		return
	end

	local rootPos = self.root.Position
	local planet = findNearestPlanet(self.planetsFolder, rootPos)

	if self:isFalling() and self:isTooFarFromAnyPlanet() then
		self.fallTime += dt
	else
		self.fallTime = 0
	end

	if self.fallTime >= FALL_TIME_LIMIT and not self.isOutOfBounds then
		self.isOutOfBounds = true
		self.root:SetAttribute("IsOutOfBounds", true)

		self.storedSpeed = self.lastVelocity.Magnitude
		self.reboundTarget = self:getNearestPlanet()
		self.reboundLaunched = false

		self.root.AssemblyLinearVelocity = Vector3.zero

		task.delay(REBOUND_SOFT_TIME, function()
			if not self.root or not self.reboundTarget then
				return
			end

			local dir = (self.reboundTarget.Position - self.root.Position).Unit
			local reboundVel = dir * self.storedSpeed * REBOUND_FORCE_MULTIPLIER
			self.root.AssemblyLinearVelocity = reboundVel
			self.reboundLaunched = true
		end)

		task.delay(REBOUND_COOLDOWN, function()
			if self.root then
				self.root:SetAttribute("IsOutOfBounds", false)
			end
			self.isOutOfBounds = false
			self.reboundLaunched = false
			self.reboundTarget = nil
		end)

		self.fallTime = 0
	end

	if self.isOutOfBounds and self.reboundLaunched and self.reboundTarget then
		local dir = (self.reboundTarget.Position - rootPos).Unit
		local current = self.root.AssemblyLinearVelocity
		if current.Magnitude == 0 or current.Unit:Dot(dir) < 0.9 then
			local reboundVel = dir * self.storedSpeed * REBOUND_FORCE_MULTIPLIER
			self.root.AssemblyLinearVelocity = reboundVel
		end
		self.force.Force = dir * self.root.AssemblyMass * Config.PLANET_GRAVITY
		self.force.Enabled = true

		local up = -dir
		local look = self.root.CFrame.LookVector
		self.orientation.CFrame = CFrame.lookAt(rootPos, rootPos + look, up)
		self.orientation.Enabled = true
	elseif planet then
		local direction = (planet.Position - rootPos).Unit
		self.force.Force = direction * self.root.AssemblyMass * Config.PLANET_GRAVITY
		self.force.Enabled = true

		local up = -direction
		local look = self.root.CFrame.LookVector
		self.orientation.CFrame = CFrame.lookAt(rootPos, rootPos + look, up)
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
