--!strict

local Config = {
	STICK_RANGE = 6, -- studs to check downward from root
	DETECTION_SHAPE = "Box", -- Detection shape: "Box" or "Ray"
	MAX_FALL_DISTANCE = 50, -- studs before resetting to terrain
	FALL_PULL_TIME = 4, -- seconds before auto reattaching in freefall
	PULL_SEARCH_RADIUS = 20, -- radius to search for a surface when pulling
	PLANET_PULL_TIME = 4, -- seconds before pulling to nearest planet
	RESPAWN_TIME = 7, -- seconds before teleporting to SpawnLocation
	PLANET_ORBIT_MULTIPLIER = 2, -- multiplier for planet orbit radius based on size
}

return Config
