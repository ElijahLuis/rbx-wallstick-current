-- selene: allow(global_usage)
return function()
	-- stub PlayerModule dependencies
	local fakeControls = {
	    GetMoveVector = function()
	        return Vector3.new(0, 0, 0)
	    end,
	}
	local fakeCameras = {
	    GetUpVector = function()
	        return Vector3.new(0, 1, 0)
	    end,
	    SetTargetUpVector = function() end,
	    GetSpinPart = function() return nil end,
	    SetSpinPart = function() end,
	    GetRotationType = function()
	        return Enum.RotationType.CameraRelative
	    end,
	}
	local fakePlayerModule = {
	    GetCameras = function()
	        return fakeCameras
	    end,
	    GetControls = function()
	        return fakeControls
	    end,
	}

	local fakePlayerScripts = {
	    WaitForChild = function(_, name)
	        if name == "PlayerModule" then
	            return fakePlayerModule
	        end
	    end,
	}

	local fakePlayers = {
	    LocalPlayer = {
	        WaitForChild = function(_, name)
	            if name == "PlayerScripts" then
	                return fakePlayerScripts
	            end
	        end,
	    },
	}

	-- replace global game service
	local originalGame = rawget(_G, "game")
	rawset(_G, "game", {
	    GetService = function(_, service)
	        if service == "Players" then
	            return fakePlayers
	        end
	    end,
	})

	local GravityCamera = require(game.ReplicatedStorage.Wallstick.GravityCamera)

	describe("GravityCamera.getMoveVector", function()
	    it("returns the input vector when camera is identity", function()
	        local input = Vector3.new(1, 0, 0)
	        local result = GravityCamera.getMoveVector(CFrame.identity, input)
	        expect(result).to.equal(input)
	    end)
	end)

	-- restore game
	rawset(_G, "game", originalGame)
end
