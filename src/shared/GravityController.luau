--!strict

-- Handles planetary gravity for characters on server
local Config = require(script.Parent:WaitForChild("WallstickConfig"))

local FALL_TIME_LIMIT = Config.FALL_TIME_LIMIT
local MAX_DISTANCE = Config.MAX_DISTANCE
local REBOUND_FORCE_MULTIPLIER = Config.REBOUND_FORCE_MULTIPLIER
local REBOUND_COOLDOWN = Config.REBOUND_COOLDOWN
local REBOUND_SOFT_TIME = Config.REBOUND_SOFT_TIME

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

function GravityController:isFalling()
	return self.humanoid:GetState() == Enum.HumanoidStateType.Freefall and self.root.AssemblyLinearVelocity.Y < 0
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

	if self.humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
		if self.force.Enabled then
			self.force.Enabled = false
			self.force.Force = Vector3.zero
		end
		if self.orientation.Enabled then
			self.orientation.Enabled = false
		end

		self.fallTime = 0
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
			if not self.root or not self.reboundTarget or not self.humanoid then
				return
			end

			local platform = Instance.new("Part")
			platform.Size = Vector3.new(10, 1, 10)
			platform.CFrame = self.root.CFrame * CFrame.new(0, -3, 0)
			platform.Anchored = true
			platform.Transparency = 1
			platform.CanCollide = true
			platform.Parent = workspace

			self.root.Anchored = true
			print("Rebound pre-state:", self.humanoid:GetState().Name)

			task.delay(0.1, function()
				if not self.root or not self.reboundTarget then
					platform:Destroy()
					return
				end

				self.root.Anchored = false
				local dir = (self.reboundTarget.Position - self.root.Position).Unit
				local reboundVel = dir * self.storedSpeed * REBOUND_FORCE_MULTIPLIER
				self.root.AssemblyLinearVelocity = reboundVel

				self.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				print("Rebound post-state:", self.humanoid:GetState().Name)

				platform:Destroy()
				self.reboundLaunched = true
			end)
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
