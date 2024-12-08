--[[

 _   ___           _          _   _   _       _             ____________ _____   ___ 
| | / / |         | |        | | | | | |     | |            | ___ \  ___/ __  \ /   |
| |/ /| |__   __ _| | ___  __| | | |_| | __ _| |_ ___  ___  | |_/ / |_  `' / /'/ /| |
|    \| '_ \ / _` | |/ _ \/ _` | |  _  |/ _` | __/ _ \/ __| |    /|  _|   / / / /_| |
| |\  \ | | | (_| | |  __/ (_| | | | | | (_| | ||  __/\__ \ | |\ \| |   ./ /__\___  |
\_| \_/_| |_|\__,_|_|\___|\__,_| \_| |_/\__,_|\__\___||___/ \_| \_\_|   \_____/   |_/
                                                                                     
                                                                                     
                                   version 1.0.0a
    
    Ever wanted to add Solara support for your script but it doesn't have the functions you need?
    No worries! KhaledHatesRF24 API is here to save the day!

   Supported Functions :
   khaledsisreadonly
   khaledscloneref
   khaledssetrawmetatable
   khaledssetreadonly
   khaledsgetrawmetatable
   khaledshookmetamethod
   khaledsgetgc
   khaledsgetconnections
   khaledsgetsenv
   khaledscheckcaller
   khaledshookfunction
   khaledsgetnamecallmethod
   khaledsgetrenv
   khaledscompareinstances
   khaledsclonefunction
   khaledsgetscripts
   khaledsgetloadedmodules

   This is a big fat kiss to Trito and everyone who works for the RF24 staff team 
                            (except Cammy)
]]

local saved_data = {
    Saved_Metatable = {},
    ReadOnly = {},
    OriginalTables = {},
    Luau_setmetatable = setmetatable
}

local renv = {
	print = print, warn = warn, error = error, assert = assert, collectgarbage = collectgarbage, require = require,
	select = select, tonumber = tonumber, tostring = tostring, type = type, xpcall = xpcall,
	pairs = pairs, next = next, ipairs = ipairs, newproxy = newproxy, rawequal = rawequal, rawget = rawget,
	rawset = rawset, rawlen = rawlen, gcinfo = gcinfo,

	coroutine = {
		create = coroutine.create, resume = coroutine.resume, running = coroutine.running,
		status = coroutine.status, wrap = coroutine.wrap, yield = coroutine.yield,
	},

	bit32 = {
		arshift = bit32.arshift, band = bit32.band, bnot = bit32.bnot, bor = bit32.bor, btest = bit32.btest,
		extract = bit32.extract, lshift = bit32.lshift, replace = bit32.replace, rshift = bit32.rshift, xor = bit32.xor,
	},

	math = {
		abs = math.abs, acos = math.acos, asin = math.asin, atan = math.atan, atan2 = math.atan2, ceil = math.ceil,
		cos = math.cos, cosh = math.cosh, deg = math.deg, exp = math.exp, floor = math.floor, fmod = math.fmod,
		frexp = math.frexp, ldexp = math.ldexp, log = math.log, log10 = math.log10, max = math.max, min = math.min,
		modf = math.modf, pow = math.pow, rad = math.rad, random = math.random, randomseed = math.randomseed,
		sin = math.sin, sinh = math.sinh, sqrt = math.sqrt, tan = math.tan, tanh = math.tanh
	},

	string = {
		byte = string.byte, char = string.char, find = string.find, format = string.format, gmatch = string.gmatch,
		gsub = string.gsub, len = string.len, lower = string.lower, match = string.match, pack = string.pack,
		packsize = string.packsize, rep = string.rep, reverse = string.reverse, sub = string.sub,
		unpack = string.unpack, upper = string.upper,
	},

	table = {
		concat = table.concat, insert = table.insert, pack = table.pack, remove = table.remove, sort = table.sort,
		unpack = table.unpack,
	},

	utf8 = {
		char = utf8.char, charpattern = utf8.charpattern, codepoint = utf8.codepoint, codes = utf8.codes,
		len = utf8.len, nfdnormalize = utf8.nfdnormalize, nfcnormalize = utf8.nfcnormalize,
	},

	os = {
		clock = os.clock, date = os.date, difftime = os.difftime, time = os.time,
	},

	delay = delay, elapsedTime = elapsedTime, spawn = spawn, tick = tick, time = time, typeof = typeof,
	UserSettings = UserSettings, version = version, wait = wait,

	task = {
		defer = task.defer, delay = task.delay, spawn = task.spawn, wait = task.wait,
	},

	debug = {
		traceback = debug.traceback, profilebegin = debug.profilebegin, profileend = debug.profileend,
	},

	game = game, workspace = workspace,

	getmetatable = getmetatable, setmetatable = setmetatable
}

function khaledsisreadonly(tbl)
    return saved_data.ReadOnly[tbl] or table.isfrozen(tbl) or false
end

function khaledsgetscripts()
    local scripts = {}
    for _, scriptt in game:GetDescendants() do
        if scriptt:isA("LocalScript") or scriptt:isA("ModuleScript") then
            table.insert(scripts, scriptt)
        end
    end
    return scripts
end

function khaledsgetloadedmodules()
    local moduleScripts = {}
    for _, obj in pairs(game:GetDescendants()) do
        if typeof(obj) == "Instance" and obj:IsA("ModuleScript") then 
            table.insert(moduleScripts, obj) 
        end
    end
    return moduleScripts
end

function khaledscloneref(reference)
    if game:FindFirstChild(reference.Name) or reference.Parent == game then
        return reference
    else
        local class = reference.ClassName
        local cloned = Instance.new(class)
        local mt = {
            __index = reference,
            __newindex = function(t, k, v)
                if k == "Name" then
                    reference.Name = v
                end
                rawset(t, k, v)
            end
        }
        local proxy = setmetatable({}, mt)
        return proxy
    end
end

function khaledsgethui()
    return khaledscloneref(game:GetService("CoreGui"))
end

function khaledssetrawmetatable(object, newmetatbl)
    if type(object) ~= "table" and type(object) ~= "userdata" then
        warn("expected table or userdata", 2)
    end
    if type(newmetatbl) ~= "table" and newmt ~= nil then
        warn("new metatable must be a table or nil", 2)
    end
    local raw_mt = debug.getmetatable(object)
        if raw_mt and raw_mt.__metatable then
        local old_metatable = raw_mt.__metatable
        raw_mt.__metatable = nil  
                local success, err = pcall(setmetatable, object, newmetatbl)
                raw_mt.__metatable = old_metatable
                if not success then
			warn("failed to set metatable : " .. tostring(err), 2)
        end
        return true  
    end
        setmetatable(object, newmetatbl)
    return true
end

function khaledssetreadonly(tbl, readOnly)
    if readOnly then
        saved_data.ReadOnly[tbl] = true
        local clone = table.clone(tbl)
        saved_data.OriginalTables[clone] = tbl
        return saved_data.Luau_setmetatable(clone, {
            __index = tbl,
            __newindex = function(_, key, value)
                warn("attempt to modify a readonly table")
            end
        })
    else
        return tbl 
    end
end

function khaledsgetrawmetatable(object)
    if type(object) ~= "table" and type(object) ~= "userdata" then
        warn("expected tbl or userdata", 2)
    end
    local raw_mt = debug.getmetatable(object)
    if raw_mt and raw_mt.__metatable then
        raw_mt.__metatable = nil 
        local result_mt = debug.getmetatable(object)
        raw_mt.__metatable = "Locked!" 
        return result_mt
    end
    
    return raw_mt
end

function khaledshookmetamethod(obj, method, rep)
    local mt = getrawmetatable(obj)
    local old = mt[method]
    
    setreadonly(mt, false)
    mt[method] = rep
    setreadonly(mt, true)
    
    return old
end

function khaledsgetgc()
    local function CheckObject(obj, visited, results)
        if visited[obj] then return end
        visited[obj] = true
        
        if type(obj) == "table" or type(obj) == "function" then
            table.insert(results, obj)
            if type(obj) == "table" then
                for _, v in pairs(obj) do
                    CheckObject(v, visited, results)
                end
            end
        end
    end

    local visited, results = {}, {}
    CheckObject(getgenv(), visited, results)
    
    return results
end

function khaledsgetconnections(event)
    if not event or not event.Connect then
        warn("invalid event")
    end
    local connections = {}
        for _, connection in ipairs(event:GetConnected()) do
        local connectinfo = {
            Enabled = connection.Enabled, 
            ForeignState = connection.ForeignState, 
            LuaConnection = connection.LuaConnection, 
            Function = connection.Function,
            Thread = connection.Thread,
            Fire = connection.Fire, 
            Defer = connection.Defer, 
            Disconnect = connection.Disconnect,
            Disable = connection.Disable, 
            Enable = connection.Enable,
        }
        
        table.insert(connections, connectinfo)
    end
    return connections
end

function khaledsgetsenv(script_instance)
	local env = getfenv(2)

	return setmetatable({
		script = script_instance,
	}, {
		__index = function(self, index)
			return env[index] or rawget(self, index)
		end,
		__newindex = function(self, index, value)
			xpcall(function()
				env[index] = value
			end, function()
				rawset(self, index, value)
			end)
		end,
	})
end

function khaledshookfunction(func, rep)
	for i, v in pairs(getfenv()) do
		if v == func then
			getfenv()[i] = rep
		end
	end
end

function khaledsgetrenv()
    return renv
end


function khaledsgetnamecallmethod()
    local info = debug.getinfo(3, "nS")
    if info and info.what == "C" then
        return info.name or "unknown"
    else
        return "unknown"
    end
end

function khaledscompareinstances(x, y)
	if type(getmetatable(y)) == "table" then
		return x.ClassName == y.ClassName
	end
	return false
end

function khaledscheckcaller()
	local info = debug.info(getgenv, 'slnaf')
	return debug.info(1, 'slnaf') == info
end

function khaledsclonefunction(func)
	local a = func
	local b = xpcall(setfenv, function(x, y)
		return x, y
	end, func, getfenv(func))
	if b then
		return function(...)
			return a(...)
		end
	end
	return coroutine.wrap(function(...)
		while true do
			a = coroutine.yield(a(...))
		end
	end)
end


for _, v in khaledsgetgc() do
    if typeof(v) == "function" and debug.getinfo(v).name == "crash" then
        local new_function = function() end
        -- Replace the function with the new no-op function
        v = new_function
    end
end



local dist = _G.dist or 7
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local footballs = {}
local gravity = Vector3.new(0, -0.50, 0)
local predictionTime = 0.1

local function locateFootballs()
    local humanoid = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoid then
        footballs = {}
        local gameFolder = Workspace:FindFirstChild("game")
        if gameFolder then
            for _, v in pairs(gameFolder:GetDescendants()) do
                if v:IsA("BasePart") and v.BrickColor == BrickColor.new("Lily white") then
                    table.insert(footballs, v)
                end
            end
        end
    end
end

local function predictPosition(part)
    if not part then return part.Position end
    local velocity = part.AssemblyLinearVelocity
    local height = part.Position.Y
    if velocity.Magnitude > 100 and height > 9 then
        return part.Position - Vector3.new(250, 0, 0)
    else
        return part.Position + velocity * predictionTime + 0.1 * gravity * predictionTime^2
    end
end

local function movePartsToFootball()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local leftBoot = character:FindFirstChild("LeftBoot")
        local rightBoot = character:FindFirstChild("RightBoot")
        local rightHand = character:FindFirstChild("RightHand")
        if humanoidRootPart and leftBoot and rightBoot and rightHand then
            local closestFootball, closestDistance = nil, math.huge
            for _, football in pairs(footballs) do
                if football and football.Parent then
                    local predictedPosition = predictPosition(football)
                    local mag = (predictedPosition - humanoidRootPart.Position).Magnitude
                    if mag < closestDistance and mag <= dist then
                        closestFootball, closestDistance = predictedPosition, mag
                    end
                end
            end
            if closestFootball then
                leftBoot.Position = closestFootball
                rightBoot.Position = closestFootball
                rightHand.Position = closestFootball
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    movePartsToFootball()
end)

Workspace.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") and child.BrickColor == BrickColor.new("Lily white") then
        table.insert(footballs, child)
    end
end)

task.spawn(function()
    while true do
        locateFootballs()
        wait(0.5)
    end
end)

local movementController = game:GetService("AssetService").controllers:WaitForChild("movementController")
local stamina = movementController:WaitForChild("stamina")

RunService.RenderStepped:Connect(function()
    if stamina.Value <= 75 then
        stamina.Value = 100
    end
end)

local localPlayer = Players.LocalPlayer
local userId = localPlayer.UserId
local profilesFolder = ReplicatedStorage:WaitForChild("network"):WaitForChild("Profiles"):WaitForChild(tostring(userId)):WaitForChild("inventory"):WaitForChild("Celebrations")

local boolValuesToCreate = {
    "Right Here Right Now",
    "Tshbalala",
    "Archer Slide",
    "Point Up",
    "The Griddy",
    "Yoga",
    "Boxing",
    "Glorious",
    "Pray",
    "Backflip",
}

for _, name in pairs(boolValuesToCreate) do
    if not profilesFolder:FindFirstChild(name) then
        local boolValue = Instance.new("BoolValue")
        boolValue.Name = name
        boolValue.Value = true
        boolValue.Parent = profilesFolder
        boolValue:SetAttribute("key", "57F34E8F-7698-464A-B2DF-1452BF0073AC")
    end
end

local function duplicateParts()
    local character = player.Character
    if character then
        local leftBoot = character:FindFirstChild("LeftBoot")
        local rightBoot = character:FindFirstChild("RightBoot")
        local rightHand = character:FindFirstChild("RightHand")
        
        if leftBoot then
            local leftBootClone = leftBoot:Clone()
            leftBootClone.Name = "LeftBootFake"
            leftBootClone.Parent = character
            leftBootClone.CanCollide = false
            leftBootClone.Massless = true
            leftBootClone.Transparency = 0
            leftBootClone:GetPropertyChangedSignal("Transparency"):Connect(function()
                leftBootClone.Transparency = 0
            end)
        end
        
        if rightBoot then
            local rightBootClone = rightBoot:Clone()
            rightBootClone.Name = "RightBootFake"
            rightBootClone.Parent = character
            rightBootClone.CanCollide = false
            rightBootClone.Massless = true
            rightBootClone.Transparency = 0
            rightBootClone:GetPropertyChangedSignal("Transparency"):Connect(function()
                rightBootClone.Transparency = 0
            end)
        end
        
        if rightHand then
            local rightHandClone = rightHand:Clone()
            rightHandClone.Name = "RightHandFake"
            rightHandClone.Parent = character
            rightHandClone.CanCollide = false
            rightHandClone.Massless = true
            rightHandClone.Transparency = 0
            rightHandClone:GetPropertyChangedSignal("Transparency"):Connect(function()
                rightHandClone.Transparency = 0
            end)
        end
        
        if leftBoot then leftBoot.Transparency = 1 end
        if rightBoot then rightBoot.Transparency = 1 end
        if rightHand then rightHand.Transparency = 1 end
    end
end

duplicateParts()
