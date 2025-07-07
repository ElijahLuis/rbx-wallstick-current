return function()
	local CharacterHelper = require(game.ReplicatedStorage.Wallstick.CharacterHelper)

	describe("CharacterHelper.applyCollisionGroup", function()
	    it("changes and restores collision groups", function()
	        local partA = {
	            CollisionGroup = "Default",
	            IsA = function() return true end,
	            ClassName = "Part",
	        }
	        local partB = {
	            CollisionGroup = "Default",
	            IsA = function() return true end,
	            ClassName = "Part",
	        }
	        local model = {
	            GetDescendants = function()
	                return {partA, partB}
	            end,
	        }
	        local revert = CharacterHelper.applyCollisionGroup(model, "Test")
	        expect(partA.CollisionGroup).to.equal("Test")
	        expect(partB.CollisionGroup).to.equal("Test")
	        revert()
	        expect(partA.CollisionGroup).to.equal("Default")
	        expect(partB.CollisionGroup).to.equal("Default")
	    end)
	end)
end
