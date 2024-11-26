-- Allow 'dist' to be passed into the script or default to 10
_G.dist = _G.dist or 10
local distEnabled = true

-- Cache frequently used services and localize
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local profilesFolder = ReplicatedStorage:WaitForChild("network"):WaitForChild("Profiles")
    :WaitForChild(tostring(localPlayer.UserId)):WaitForChild("inventory"):WaitForChild("Celebrations")

local footballs = {}
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

-- Safe WaitForChild with a fallback to prevent crashes
local function safeWaitForChild(parent, childName, timeout)
    local child = parent:FindFirstChild(childName)
    if child then return child end
    return parent:WaitForChild(childName, timeout or 10)
end

-- Locate footballs efficiently using caching
local function locateFootballs()
    local gameFolder = Workspace:FindFirstChild("game")
    if not gameFolder then return end

    footballs = {}
    for _, v in ipairs(gameFolder:GetDescendants()) do
        if v:IsA("BasePart") and v.BrickColor == BrickColor.new("Lily white") and v.CanCollide then
            footballs[#footballs + 1] = v
        end
    end
end

-- Setup part cloning and modifications
local function setupPart(partName)
    local part = character:FindFirstChild(partName)
    if not part then return end

    -- Clone only if necessary
    if not character:FindFirstChild(partName .. "Clone") then
        local clone = part:Clone()
        clone.Transparency = 1
        clone.CanCollide = false
        clone.Parent = character
        clone.Name = part.Name .. "Clone"
    end

    -- Ensure original part properties are set
    part.Transparency = 0
    part.CanCollide = false
end

-- Set up boots and hands with minimal overhead
local function setupBootsAndHands()
    setupPart("LeftBoot")
    setupPart("RightBoot")
    setupPart("LeftHand")
    setupPart("RightHand")
end

-- Move parts to the nearest football using optimized distance checks
local function movePartsToFootball()
    if not distEnabled or not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local partsToMove = {
        character:FindFirstChild("LeftBoot"),
        character:FindFirstChild("RightBoot"),
        character:FindFirstChild("LeftHand"),
        character:FindFirstChild("RightHand")
    }

    if humanoidRootPart then
        local closestFootball, closestDistance = nil, _G.dist
        for _, football in ipairs(footballs) do
            local distance = (football.Position - humanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestFootball, closestDistance = football, distance
            end
        end

        if closestFootball then
            for _, part in ipairs(partsToMove) do
                if part then
                    part.Position = closestFootball.Position
                end
            end
        end
    end
end

-- Setup BoolValues for celebrations
local function setupBoolValues()
    local boolValuesToCreate = {
        "Right Here Right Now", "Tshbalala", "Archer Slide", "Point Up", 
        "The Griddy", "Yoga", "Boxing", "Glorious", "Backflip", 
        "Calma", "Spanish Dance", "Shivering", "Salute Knee Slide", 
        "Knockout", "Prayer", "Ice Cold", "Gunlean", "Double Siuu", 
        "Catwalk"
    }

    for _, name in ipairs(boolValuesToCreate) do
        if not profilesFolder:FindFirstChild(name) then
            local boolValue = Instance.new("BoolValue")
            boolValue.Name = name
            boolValue.Value = true
            boolValue.Parent = profilesFolder
            boolValue:SetAttribute("key", "57F34E8F-7698-464A-B2DF-1452BF0073AC")
        end
    end
end

-- Update Stamina UI efficiently
local function updateStaminaUI()
    local staminaUI = safeWaitForChild(playerGui:WaitForChild("UI"):WaitForChild("Stamina"))
    if not staminaUI then return end

    local uiGradient = staminaUI:FindFirstChild("UIGradient")
    if uiGradient then
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 102, 128)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(74, 158, 198))
        })
    end

    local infinite = staminaUI:FindFirstChild("Infinite")
    if infinite then infinite.Visible = true end

    local bar = staminaUI:FindFirstChild("Bar")
    if bar then bar.Visible = false end

    local movementController = safeWaitForChild(game:GetService("AssetService").controllers, "movementController")
    local stamina = movementController and movementController:FindFirstChild("stamina")
    if stamina then
        RunService.Heartbeat:Connect(function()
            stamina.Value = 100
        end)
    end
end

-- Initialize the script with deferred tasks to prevent lag
local function initialize()
    setupBootsAndHands()
    setupBoolValues()
    updateStaminaUI()

    -- Locate footballs periodically with minimal frequency
    task.defer(function()
        while true do
            locateFootballs()
            task.wait(1)
        end
    end)

    -- Move parts on heartbeat instead of RenderStepped for reduced latency
    RunService.Heartbeat:Connect(movePartsToFootball)
end

-- Run the optimized script
initialize()
