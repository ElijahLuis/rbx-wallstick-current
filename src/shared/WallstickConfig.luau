--!strict

local Config = {
	STICK_RANGE = 6, -- studs to check downward from root
	DETECTION_SHAPE = "Box", -- Detection shape: "Box" or "Ray"
	MAX_FALL_DISTANCE = 50, -- studs before resetting to terrain
	FALL_PULL_TIME = 3, -- seconds before auto reattaching in freefall
	PULL_SEARCH_RADIUS = 50, -- radius to search for a surface when pulling
	PLANET_PULL_TIME = 5, -- seconds before pulling to nearest planet
	RESPAWN_TIME = 7, -- seconds before teleporting to SpawnLocation
	OUT_OF_BOUNDS_TIME = 4.5, -- seconds in freefall before redirecting to a planet
	OUT_OF_BOUNDS_DISTANCE = 750, -- studs from origin considered out of bounds
	PLANET_ORBIT_MULTIPLIER = 2, -- multiplier for planet orbit radius based on size
	PLANET_GRAVITY = 150, -- strength of planet gravitational pull
}

function Config.update(values: { [string]: any })
	for key, value in pairs(values) do
		if Config[key] ~= nil then
			Config[key] = value
		end
	end
end

function Config.getAll()
	local copy = {} :: { [string]: any }
	for key, value in pairs(Config) do
		if type(value) ~= "function" then
			copy[key] = value
		end
	end
	return copy
end

return Config
