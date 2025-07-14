local GravityController = {}
GravityController.__index = GravityController

function GravityController.new(player)
	local self = setmetatable({}, GravityController)
	-- initialize here
	return self
end

return GravityController
