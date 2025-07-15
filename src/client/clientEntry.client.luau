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
	local fallTime = 0

	local function getPlanets()
		local list = {}
		for _, obj in ipairs(workspace:GetChildren()) do
			if obj:IsA("BasePart") and obj.Name:sub(1, 6) == "Planet" then
				table.insert(list, obj)
			end
		end
		return list
	end

	local planets = getPlanets()
	local spawnLocation = workspace:FindFirstChild("SpawnLocation")

	local function findNearestPlanet()
		local closest
		local closestDist = math.huge
		local pos = hrp.Position

               for _, planet in ipairs(planets) do
                       local dist = (planet.Position - pos).Magnitude
                       local radius = math.max(planet.Size.X, planet.Size.Y, planet.Size.Z)
                               * 0.5
                               * Config.PLANET_ORBIT_MULTIPLIER
                       if dist <= radius and dist < closestDist then
                               closest = planet
                               closestDist = dist
                       end
               end

		return closest
	end

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

        local outOfBounds = false
        local touchedConnections = {} :: { RBXScriptConnection }

        local function onPlanetTouched(_part: BasePart, hit: BasePart)
                if hit.Name:sub(1, 6) == "Planet" then
                        local surface = findNearestSurface(Config.STICK_RANGE, true)
                        if surface then
                                local part = (surface.Instance :: BasePart).AssemblyRootPart
                                local normal = part.CFrame:VectorToObjectSpace(surface.Normal)
                                wallstick:setAndPivot(part, normal, surface.Position)
                                fallTime = 0

                                if outOfBounds then
                                        hrp.AssemblyLinearVelocity = Vector3.zero
                                        wallstick:setEnabled(true)
                                        outOfBounds = false
                                end
                        end
                end
        end

        local function connectTouchListeners(model: Model)
                for _, p in ipairs(model:GetDescendants()) do
                        if p:IsA("BasePart") then
                                table.insert(touchedConnections, p.Touched:Connect(function(hit)
                                        onPlanetTouched(p, hit)
                                end))
                        end
                end
        end

        connectTouchListeners(wallstick.fake.character)

        local simulationConnection = RunService.PreSimulation:Connect(function(dt)
                if outOfBounds then
                        return
                end

                if wallstick.fake.rootPart.Position.Y <= workspace.FallenPartsDestroyHeight then
                        outOfBounds = true
                end

                if outOfBounds then
                        local planet = findNearestPlanet()
                        if planet then
                                local direction = (planet.Position - hrp.Position).Unit
                                local speed = hrp.AssemblyLinearVelocity.Magnitude
                                hrp.AssemblyLinearVelocity = direction * speed
                        end
                        wallstick:setEnabled(false)
                        return
                end

                if not wallstick:isEnabled() then
                        return
                end

                if wallstick:getFallDistance() < -Config.MAX_FALL_DISTANCE then
                        wallstick:set(workspace.Terrain, Vector3.yAxis)
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
                        fallTime = 0
                else
                        if wallstick.fake.humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                                fallTime += dt

                                if fallTime >= Config.RESPAWN_TIME then
                                        if spawnLocation then
                                                hrp.AssemblyLinearVelocity = Vector3.zero
                                                hrp.CFrame = spawnLocation.CFrame
                                                        * CFrame.new(0, spawnLocation.Size.Y / 2 + humanoid.HipHeight, 0)
                                                wallstick:set(workspace.Terrain, Vector3.yAxis)
                                        end
                                        fallTime = 0
                                elseif fallTime >= Config.OUT_OF_BOUNDS_TIME then
                                        outOfBounds = true
                                end
                        else
                                fallTime = 0
                        end
                end
        end)

        humanoid.Died:Wait()
        simulationConnection:Disconnect()
        for _, con in ipairs(touchedConnections) do
                con:Disconnect()
        end
        cleanupDoubleJump()
        wallstick:Destroy()
end

assert(not workspace.StreamingEnabled, "Wallstick does not support streaming enabled.")

if Players.LocalPlayer.Character then
	onCharacterAdded(Players.LocalPlayer.Character)
end

Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

Replication.listenClient()
