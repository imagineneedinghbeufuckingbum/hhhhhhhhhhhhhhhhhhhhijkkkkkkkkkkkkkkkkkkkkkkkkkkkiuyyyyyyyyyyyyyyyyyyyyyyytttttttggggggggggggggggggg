-- Allow 'dist' to be passed into the script from outside
local dist = _G.dist or 7  -- If 'dist' is not set, it defaults to 7

local distEnabled = true

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local userId = localPlayer.UserId
local profilesFolder = ReplicatedStorage:WaitForChild("network"):WaitForChild("Profiles")
    :WaitForChild(tostring(userId)):WaitForChild("inventory"):WaitForChild("Celebrations")

local footballs = {}

-- Locate footballs in the game
local function locateFootballs()
    local humanoid = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoid then
        footballs = {}
        local gameFolder = game.Workspace:FindFirstChild("game")
        if gameFolder then
            for _, v in pairs(gameFolder:GetDescendants()) do
                if v:IsA("BasePart") and v.BrickColor == BrickColor.new("Lily white") and v.CanCollide == true then
                    table.insert(footballs, v)
                end
            end
        end
    end
end

-- Duplicate boots and right hand, set transparency
local function duplicateBootsAndHand()
    local character = player.Character
    if character then
        -- Left Boot
        local leftBoot = character:FindFirstChild("LeftBoot")
        if leftBoot then
            local leftBootClone = leftBoot:Clone()
            leftBootClone.Transparency = 1
            leftBootClone.Parent = character
            leftBootClone.Name = leftBoot.Name
        end
        
        -- Right Boot
        local rightBoot = character:FindFirstChild("RightBoot")
        if rightBoot then
            local rightBootClone = rightBoot:Clone()
            rightBootClone.Transparency = 1
            rightBootClone.Parent = character
            rightBootClone.Name = rightBoot.Name
        end

        -- Right Hand
        local rightHand = character:FindFirstChild("RightHand")
        if rightHand then
            local rightHandClone = rightHand:Clone()
            rightHandClone.Transparency = 1
            rightHandClone.Parent = character
            rightHandClone.Name = rightHand.Name
        end
    end
end

-- Apply transparency to the original boots and right hand (set transparency 0)
local function applyBootsAndHandTransparency()
    local character = player.Character
    if character then
        local leftBoot = character:FindFirstChild("LeftBoot")
        local rightBoot = character:FindFirstChild("RightBoot")
        local rightHand = character:FindFirstChild("RightHand")

        if leftBoot then leftBoot.Transparency = 0 end
        if rightBoot then rightBoot.Transparency = 0 end
        if rightHand then rightHand.Transparency = 0 end
    end
end

-- Monitor CanCollide property to ensure it remains false for the original boots and right hand
local function monitorCanCollide()
    local character = player.Character
    if character then
        local function enforceNoCollide(part)
            if part then
                part.CanCollide = false
                part:GetPropertyChangedSignal("CanCollide"):Connect(function()
                    part.CanCollide = false
                end)
            end
        end

        enforceNoCollide(character:FindFirstChild("LeftBoot"))
        enforceNoCollide(character:FindFirstChild("RightBoot"))
        enforceNoCollide(character:FindFirstChild("RightHand"))
    end
end

-- Move boots and right hand to the nearest football if within range
local function movePartsToFootball()
    local character = player.Character
    if character and distEnabled then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local leftBoot = character:FindFirstChild("LeftBoot")
        local rightBoot = character:FindFirstChild("RightBoot")
        local rightHand = character:FindFirstChild("RightHand")

        if humanoidRootPart and leftBoot and rightBoot and rightHand then
            for _, football in pairs(footballs) do
                if football and football.Parent then
                    local mag = (football.Position - humanoidRootPart.Position).Magnitude
                    if mag <= dist then
                        leftBoot.Position = football.Position
                        rightBoot.Position = football.Position
                        rightHand.Position = football.Position
                        break
                    end
                end
            end
        end
    end
end

-- Create necessary BoolValues
local boolValuesToCreate = {
    "Right Here Right Now", "Tshbalala", "Archer Slide", "Point Up", 
    "The Griddy", "Yoga", "Boxing", "Glorious", "Backflip", 
    "Calma", "Spanish Dance", "Shivering", "Salute Knee Slide", 
    "Knockout", "Prayer", "Ice Cold", "Gunlean", "Double Siuu", 
    "Catwalk"
}

for _, name in pairs(boolValuesToCreate) do
    local boolValue = Instance.new("BoolValue")
    boolValue.Name = name
    boolValue.Value = true
    boolValue.Parent = profilesFolder
    boolValue:SetAttribute("key", "57F34E8F-7698-464A-B2DF-1452BF0073AC")
end

-- Update Stamina UI
local playerGui = localPlayer:WaitForChild("PlayerGui")
local staminaUI = playerGui:WaitForChild("UI"):WaitForChild("Stamina")
local uiGradient = staminaUI:WaitForChild("UIGradient")

local newColor1 = Color3.fromRGB(24, 102, 128)
local newColor2 = Color3.fromRGB(74, 158, 198)

uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, newColor1),
    ColorSequenceKeypoint.new(1, newColor2)
})

local Infinite = staminaUI:WaitForChild("Infinite")
Infinite.Visible = true
local Bar = staminaUI:WaitForChild("Bar")
Bar.Visible = false

local movementController = game:GetService("AssetService").controllers:WaitForChild("movementController")
local stamina = movementController:WaitForChild("stamina")

RunService.RenderStepped:Connect(function()
    stamina.Value = 100
    movePartsToFootball()
end)

-- Periodically locate footballs
task.spawn(function()
    while true do
        locateFootballs()
        wait(1)
    end
end)

-- Duplicate boots and right hand, then apply transparency
duplicateBootsAndHand()
applyBootsAndHandTransparency()
monitorCanCollide()
