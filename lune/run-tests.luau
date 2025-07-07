--!strict

local stdio = require("@lune/stdio")
local process = require("@lune/process")

local function run(cmd: string, args: {string})
	stdio.write(stdio.style("bold"))
	print("> " .. cmd .. " " .. table.concat(args, " "))
	stdio.write(stdio.style("reset"))

	local child = process.create(cmd, args, {stdio = "inherit", shell = true})
	local res = child:status()
	if res.code > 0 then
	    process.exit(res.code)
	end
end

run("rojo", {"build", "tests.project.json", "-o", "TestPlace.rbxl"})
run("lune", {"test", "tests.project.json"})
