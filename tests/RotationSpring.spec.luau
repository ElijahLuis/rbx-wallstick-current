return function()
	local RotationSpring = require(game.ReplicatedStorage.Wallstick.RotationSpring)

	describe("RotationSpring", function()
	    it("maintains position when goal equals position", function()
	        local cframe = CFrame.identity
	        local spring = RotationSpring.new(1, 1, cframe, cframe)
	        local result = spring:step(0.1)
	        expect(result.Position).to.equal(cframe.Position)
	    end)
	end)
end
