--!strict

local Config = {
	STICK_RANGE = 6, -- studs to check downward from root
	DETECTION_SHAPE = "Box", -- Detection shape: "Box" or "Ray"
	FALL_TIME_LIMIT = 4, -- seconds in freefall before rebounding
	MAX_DISTANCE = 1800, -- studs away from planets before rebounding
	REBOUND_FORCE_MULTIPLIER = 1.2, -- strength multiplier for rebound push
	REBOUND_COOLDOWN = 5, -- seconds before rebound can trigger again
	PLANET_ORBIT_MULTIPLIER = 2, -- multiplier for planet orbit radius based on size
	PLANET_GRAVITY = 100, -- strength of planet gravitational pull
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
