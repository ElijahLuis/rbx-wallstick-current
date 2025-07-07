--!strict
local TestEZ = require(game.ReplicatedStorage.DevPackages.TestEZ)
local results = TestEZ.TestBootstrap:run({game.ServerScriptService.Tests})
if results.failureCount > 0 then
	error(string.format("%d tests failed", results.failureCount))
end
