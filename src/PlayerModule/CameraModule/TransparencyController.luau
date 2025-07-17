--!strict
-- Stubbed TransparencyController to prevent fallback errors
-- Exposes a minimal API expected by PlayerScripts without any logic
local TransparencyController = {}
TransparencyController.__index = TransparencyController

function TransparencyController.new()
	return setmetatable({}, TransparencyController)
end

function TransparencyController:Enable(_enable: boolean) end

function TransparencyController:Update(_dt: number) end

function TransparencyController:Reset() end

function TransparencyController:SetSubject(_subject: any) end

return TransparencyController
