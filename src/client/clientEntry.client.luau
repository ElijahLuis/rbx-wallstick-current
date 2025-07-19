--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedPackages = ReplicatedStorage:FindFirstChild("SharedPackages")
if not SharedPackages then
	warn("[Wallstick] SharedPackages missing. Did you run 'wally install'?")
	return
end

local ok, RaycastHelper = pcall(require, SharedPackages:FindFirstChild("RaycastHelper"))
if not ok then
	warn("[Wallstick] Failed to load RaycastHelper. Ensure dependencies are installed.")
	return
end

local Config = require(ReplicatedStorage:WaitForChild("WallstickConfig"))

local WallstickClass = require(ReplicatedStorage.Wallstick)
local Replication = require(ReplicatedStorage.Wallstick.Replication)
local DoubleJump = require(ReplicatedStorage.Wallstick.DoubleJump)

local LIMB_NAMES: { [string]: boolean } = {
	-- R6
	Head = true,
	Torso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	-- R15
	UpperTorso = true,
	LowerTorso = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

local function ignoreCharacterParts(result: RaycastResult)
	local hit = result.Instance :: BasePart
	local accessory = hit:FindFirstAncestorWhichIsA("Accessory")

	local character = (accessory or hit).Parent
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	if character and humanoid then
		return not (accessory or LIMB_NAMES[hit.Name] ~= nil)
	end

	return true
end

local function onCharacterAdded(character: Model)
	local wallstick = WallstickClass.new({
		parent = workspace:WaitForChild("Wallstick"),
		origin = CFrame.new(2000, 0, 0),
		retainWorldVelocity = true,
		camera = {
			tilt = true,
			spin = true,
		},
	})

	local humanoid = character and character:WaitForChild("Humanoid") :: Humanoid
	humanoid.WalkSpeed = 20
	local hrp = humanoid and humanoid.RootPart :: BasePart

	local cleanupDoubleJump = DoubleJump.setup(wallstick.fake.humanoid, wallstick.real.humanoid)

	local rayParams = RaycastHelper.params({
		filterType = Enum.RaycastFilterType.Exclude,
		instances = { character :: Instance },
	})

	local function findNearestSurface(range: number, planetsOnly: boolean?)
		local hrpCF = hrp.CFrame
		local directions = {
			-hrpCF.YVector,
			Vector3.yAxis * -1,
			hrpCF.LookVector,
			-hrpCF.LookVector,
			hrpCF.RightVector,
			-hrpCF.RightVector,
		}

		local best
		for _, dir in ipairs(directions) do
			local result = workspace:Raycast(hrp.Position, dir.Unit * range, rayParams)
			if result and (not planetsOnly or result.Instance.Name:sub(1, 6) == "Planet") then
				if not best or result.Distance < best.Distance then
					best = result
				end
			end
		end

		return best
	end

	local simulationConnection = RunService.PreSimulation:Connect(function(dt)
		if not wallstick:isEnabled() then
			return
		end

		local hipHeight = humanoid.HipHeight
		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			hipHeight = 2
		end

		local hrpCF = hrp.CFrame
		local result = RaycastHelper.raycast({
			origin = hrpCF.Position,
			direction = -(hipHeight + hrp.Size.Y / 2 + Config.STICK_RANGE) * hrpCF.YVector,
			filter = ignoreCharacterParts,
			rayParams = rayParams,
		})

		if result then
			local stickPart = (result.Instance :: BasePart).AssemblyRootPart
			local stickNormal = stickPart.CFrame:VectorToObjectSpace(result.Normal)

			wallstick:setAndPivot(stickPart, stickNormal, result.Position)
		else
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				local planetHit = findNearestSurface(Config.STICK_RANGE, true)
				if planetHit then
					local planetPart = (planetHit.Instance :: BasePart).AssemblyRootPart
					local planetNormal = planetPart.CFrame:VectorToObjectSpace(planetHit.Normal)
					wallstick:setAndPivot(planetPart, planetNormal, planetHit.Position)
				end
			end
		end
	end)

	humanoid.Died:Wait()
	simulationConnection:Disconnect()
	cleanupDoubleJump()
	wallstick:Destroy()
end

assert(not workspace.StreamingEnabled, "Wallstick does not support streaming enabled.")

if Players.LocalPlayer.Character then
	onCharacterAdded(Players.LocalPlayer.Character)
end

Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

Replication.listenClient()
