--[[
    Filename.: Source.luau
    Description.: A simple thread identity validator for Roblox Internals/Externals.
    Author.: lucibedroque \\ RazAPIx64 \\ RazAPI \\ Raz \\ Lucien
]]

local PrintConsole = function(Option, Message, Repeat)
	assert(Option < 4, "No options above 3")

	local Options = {[1] = print, [2] = warn, [3] = error}
	if not Options[Option] then return "Invalid Option" end

	return Options[Option](Message)
end

PrintConsole(1, "")
PrintConsole(1, "[ Validator - Intro ]: Running IV (Identity Validator) Build 331202610P")
task.wait(0.3)
PrintConsole(1, "[ Validator - Intro ]: Starting...")

local ProcessSearch = function(ProcessClosure)
	local Env = getgenv and getgenv() or getfenv(0)

	while Env and ProcessClosure ~= "" do
		local StrTotalOutput, StrTotalXport = string.match(ProcessClosure, "^([^.]+)%.?(.*)$")

		Env = Env[StrTotalOutput]
		ProcessClosure = StrTotalXport
	end

	return Env
end

--// Services
local LogService = game:GetService("LogService")

LogService.MessageOut:Connect(function(Message)
	LastMessage = Message
end)

local LogLastMsg = function()
    return LastMessage
end

local LastMessage
local AgentInfo = { Name = getexecutorname and getexecutorname() or "Unknown", Environment = getgenv and getgenv() or getfenv(0) }
local TestDependencies = { Passes = 0, Failures = 0, Tested = 0, SendTest = function(Statement, Reason) if not Statement then PrintConsole(3, Reason) end end,
	CaptureDeps = {
		GetNumFTex = function(Ignore)
			local String = "" 
			string.gsub(Ignore, "%d+", function(Out) String = String .. Out end)
			return tonumber(String)
		end
	}
}

if AgentInfo.Environment["ValidatorConfiguration"] == nil then
	PrintConsole(2, `[ Validator - Config Settings ]: Failed to find configuration settings (error code 0x8F), setting default values...`)

	AgentInfo.Environment["ValidatorConfiguration"] = {
		["DisplayTimeTaken"] = true
	}
end

local TestProcess = function(TestName, Callback)
	task.spawn(function()
		local Function = TestName
		local Success, Result = pcall(Callback)

		if Success then
			TestDependencies.Passes += 1
			TestDependencies.Tested += 1

			PrintConsole(1, `✅ {Function} • {Result}`)
			--// prod. lucien
		else
			TestDependencies.Failures += 1
			TestDependencies.Tested += 1

			PrintConsole(2, `❌ {Function}: {Result}`)
		end
	end)
end

PrintConsole(1, "")
PrintConsole(1, "[ Validator - Assistant ]: Setup finished")

PrintConsole(1, "[ Validator - Assistant ]: Checking dependencies")

local AllDeps = { ["getthreadidentity"] = true, ["setthreadidentity"] = true, ["debug.info"] = true }

for i,v in AllDeps do
    if AgentInfo.Environment[i] == nil then
        PrintConsole(2, `[ Validator - Assistant ]: One or more dependencies are missing, and the script cannot continue executing.\n\nHere's the error code: 0x1C\nThe dependency: {i}`)
        return
    end
end

--// finish proper deps

TestDependencies.GTDSTService = function(Level, Callback, Reason)
	local Function = getidentity and getidentity() or getthreadidentity and getthreadidentity()

	if Function() == Level then
		local Success, Result = pcall(Callback)
		TestDependencies.SendTest(Success, Reason)
	end
end

task.wait(0.5)

PrintConsole(1, "")
PrintConsole(1, "[ Validator - Assistant ]: Beginning test")
PrintConsole(1, "[ Validator - Core ]: Testing printidentity")
PrintConsole(1, "")

--// printidentity
local CalculatedTests = {}
local PrintIdentityTimeServer = os.clock()

TestProcess("printidentity - Environment Check", function()
   TestDependencies.SendTest(AgentInfo.Environment.printidentity, "function doesn't exist??")

    if AgentInfo.Environment.getrenv then
        TestDependencies.SendTest(AgentInfo.Environment.getrenv().printidentity, "printidentity does not exist in the Roblox Environment")
    end

   return "Passed"
end)

TestProcess("printidentity - Debug Info Check", function()
	local Success, Result = pcall(function()
		--// I'm making sure that i can run debug.info without it erroring
		return debug.info(printidentity, "n")
	end)

	if not Success then
		TestDependencies.SendTest(1 > 2, `Unexpected error occured, (error code 0x3C), Here's what we captured: {Result}`)
    else
        PrintConsole(1, `[ Validator - Debug (printidentity) ]: {#Result > 1 and Result or "No debug name found?"}`)
        TestDependencies.SendTest(LogLastMsg():find("[ Validator - Debug (printidentity) ]: No debug name found?"), "Did not return a debug name")
    end

	return "Passed"
end)

TestProcess("printidentity - Validation Check", function()
	local Success, Result = pcall(function()
		return debug.info(printidentity, "s")
	end)

	if not Success then
		TestDependencies.SendTest(1 > 2, `Unexpected error occured, error code (0x3C), Here's what we captured: {Result}`)
    else
        PrintConsole(1, `[ Validator - Debug (printidentity) ]: Source -> {Result}`)
        TestDependencies.SendTest(Result == "[C]", "Did not return [C] (printidentity is not a C closure)")

        printidentity()
        TestDependencies.SendTest(LogLastMsg():find("Current identity is"), "Nothing was outputted when calling printidentity")
		TestDependencies.SendTest(GetNumFTex(LogLastMsg()) <= 8, "Identity must not be higher than 8")
    end

	return "Passed"
end)

CalculatedTests["printidentity"] = math.floor((os.clock() - PrintIdentityTimeServer) * 1000)

--// getthreadidentity bizz

PrintConsole(1, "")
PrintConsole(1, "[ Validator - Core ]: Testing getthreadidentity")
PrintConsole(1, "")

local GetThreadIdentityTimeServer = os.clock() 

TestProcess("getthreadidentity: Validation & Closure Check", function()
	local Success, Result = pcall(function() return getthreadidentity() end)
	TestDependencies.SendTest(Success, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	TestDependencies.SendTest(type(getthreadidentity()) == "number", "Did not return a number.")
	TestDependencies.SendTest(getthreadidentity() <= 8, "Thread identity cannot be higher than 8")
	--// this is actually a getrenv check, it only checks if it's just indexing the current environment (getfenv()) instead of robloxs

	if AgentInfo.Environment.getrenv then
		TestDependencies.SendTest(not AgentInfo.Environment.getrenv()[getthreadidentity] "getthreadidentity should not exist in the Roblox Environment")
	end

	TestDependencies.SendTest(debug.info(getthreadidentity, "s") == "[C]", "getthreadidentity is not a C Closure (MIGHT be inaccurate)")

	return "Passed"
end)

--// Level checks

task.spawn(function()
	TestDependencies.GTDSTService(2, function()
		TestProcess("getthreadidentity: L2", function()
			local Success, Result = pcall(function() return game:GetJobsInfo() end)
			TestDependencies.SendTest(Success, `Failed (game:GetJobsInfo), result: {Result}`)

			--// this is basic instance access
			TestDependencies.SendTest((pcall(function() Instance.new("Part").Name = "FukUpSomeKommasUpYeah" end)), `Failed to access instance properties? 0x8C`)
			return "Passed"
		end)
	end, "Failed L2")

	TestDependencies.GTDSTService(3, function()
		TestProcess("getthreadidentity: L3", function()
			local Success, Result = pcall(function() return game:GetService("CoreGui"):GetFullName() end)
			TestDependencies.SendTest(Success, `Failed (CoreGui:GetFullName), result: {Result}`)

			--// CorePackages, nothing different here.
			local SecondTest, SecondResult = pcall(function() return game:GetService("CorePackages"):GetFullName() end)
			TestDependencies.SendTest(SecondTest, `Failed (CorePackages:GetFullName), result: {SecondResult}`)

			--// RobloxLocked permission <xoxo>
			local Folder = Instance.new("Folder")
			local Lost, Rushi = pcall(function() Folder.RobloxLocked = true end)

			TestDependencies.SendTest(Lost, `Failed (RobloxLocked), result: {Rushi}`)
			return "Passed"
		end)
	end, "Failed L3")

	TestDependencies.GTDSTService(6, function()
		TestProcess("getthreadidentity: L6", function()
			local Success, Result = pcall(function() return Instance.new("SurfaceAppearance").TexturePack end)
			TestDependencies.SendTest(Success, `Couldn't access TexturePack from Class SurfaceAppearance {Result}`)

			return "Passed"
		end)
	end, "Failed L6")

	CalculatedTests["getthreadidentity"] = math.floor((os.clock() - GetThreadIdentityTimeServer) * 1000)
end)

PrintConsole(1, "")
PrintConsole(1, "[ Validator - Core ]: Testing setthreadidentity")
PrintConsole(1, "")

local SetThreadIdentityTimeServer = os.clock()

TestProcess("setthreadidentity: Validation & Closure Check", function()
	local Success, Result = pcall(function() return setthreadidentity(getthreadidentity()) end)
	TestDependencies.SendTest(Success, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	local Type, Checking = pcall(function() return setthreadidentity({}) end)
	TestDependencies.SendTest(not Type, "No typechecking")

	--// this is actually a getrenv check, it only checks if it's just indexing the current environment (getfenv()) instead of robloxs

	if AgentInfo.Environment.getrenv then
		TestDependencies.SendTest(not AgentInfo.Environment.getrenv()[setthreadidentity] "setthreadidentity should not exist in the Roblox Environment")
	end

	TestDependencies.SendTest(debug.info(setthreadidentity, "s") == "[C]", "setthreadidentity is not a C Closure (MIGHT be inaccurate)")

	return "Passed"
end)

TestProcess("setthreadidentity: Identity Check", function()
	local Stored, Identity = pcall(function() return getthreadidentity() end)
	local Success, Result = pcall(function() setthreadidentity(2) end)
	TestDependencies.SendTest(Success, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	local Need, Hydroxycut = pcall(function() return getthreadidentity() end)
	TestDependencies.SendTest(Need, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	TestDependencies.SendTest(Hydroxycut == 2, "Failed to set the thread identity");
	setthreadidentity(Identity); --// 0x1C?
end)

TestProcess("setthreadidentity: L2", function()
	local Stored, Identity = pcall(function() return getthreadidentity() end)
	local Success, Result = pcall(function() setthreadidentity(2) end)
	TestDependencies.SendTest(Success, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	local Need, Hydroxycut = pcall(function() return getthreadidentity() end)
	TestDependencies.SendTest(Need, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	TestDependencies.SendTest(Hydroxycut == 2, "Failed to set the thread identity");
	TestDependencies.SendTest((pcall(function() return require(game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts").PlayerModule)) end), `Couldn't require a ModuleScript at Level 2`);

	setthreadidentity(Identity)
end)

TestProcess("setthreadidentity: L8", function()
	local Stored, Identity = pcall(function() return getthreadidentity() end)
	local Success, Result = pcall(function() setthreadidentity(8) end)
	TestDependencies.SendTest(Success, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	local Need, Hydroxycut = pcall(function() return getthreadidentity() end)
	TestDependencies.SendTest(Need, `An unexpected error occured, (error code 0x7C). Here's what we captured: {Result}`)

	TestDependencies.SendTest(Hydroxycut == 8, "Failed to set the thread identity");
	local ChopStick, MakeANPantsSoil = pcall(function() return Instance.new("Player") end)

	TestDependencies.SendTest(ChopStick, `Couldn't create a player (WritePlayer Permission)`)
	setthreadidentity(Identity)
end)

CalculatedTests["setthreadidentity"] = math.floor((os.clock() - SetThreadIdentityTimeServer) * 1000)

--// finished stuff
task.spawn(function()
	PrintConsole(1, "")
	PrintConsole(1, `[ Validator - Finishing ]: Processing results for {AgentInfo.Name} & calculating results...`)
	PrintConsole(1, "")

	PrintConsole(1, `✅ Tested with a {math.floor((TestDependencies.Passes / TestDependencies.Tested) * 100)}% success rate`)
	PrintConsole(1, `❌ Failed over {math.floor((TestDependencies.Failures / TestDependencies.Tested) * 100)}% of tests`)
	PrintConsole(1, "")

	if AgentInfo.Environment.ValidatorConfiguration["DisplayTimeTaken"] then
		local Success, Result = pcall(function()
			PrintConsole(1, `[ Validator - Time Helper Service ]: printidentity test took {CalculatedTests["printidentity"]}ms`)
			PrintConsole(1, `[ Validator - Time Helper Service ]: getthreadidentity test took {CalculatedTests["getthreadidentity"]}ms`)
			PrintConsole(1, `[ Validator - Time Helper Service ]: setthreadidentity test took {CalculatedTests["setthreadidentity"]}ms`)
			PrintConsole(1, `[ Validator - Time Helper Service ]: Overall tests took {CalculatedTests["printidentity"] + CalculatedTests["getthreadidentity"] + CalculatedTests["setthreadidentity"]}ms`)
		end)

		if not Success then
			PrintConsole(2, `[ Validator - THS Error ]: An error occured while trying to display the time taken by each test (error code 0x6F)`)
		end
	end

	PrintConsole(1, "[ Validator - Assistant ]: If you do not understand any error codes, refer to the README in the repository. (ignore if no errors occured)")
end)
