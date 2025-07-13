--!strict

local UserInputService = game:GetService("UserInputService")

local DoubleJump = {}

type Connection = RBXScriptConnection

function DoubleJump.setup(fakeHumanoid: Humanoid, realHumanoid: Humanoid)
	local canDouble = true
	local connections: { Connection } = {}

	table.insert(
		connections,
		fakeHumanoid.StateChanged:Connect(function(_, newState)
			if newState == Enum.HumanoidStateType.Landed then
				canDouble = true
			end
		end)
	)

	table.insert(
		connections,
		UserInputService.JumpRequest:Connect(function()
			local state = fakeHumanoid:GetState()
			if (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall) and canDouble then
				realHumanoid.Jump = true
				canDouble = false
			end
		end)
	)

	return function()
		for _, conn in pairs(connections) do
			conn:Disconnect()
		end
	end
end

return DoubleJump
