local dist = _G.dist or 7
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local footballs = {}
local gravity = Vector3.new(0,-0.50,0)
local predictionTime = 0.1 -- Increased for better ball tracking

local function locateFootballs()
    local humanoid = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoid then
        footballs = {}
        local gameFolder = game.Workspace:FindFirstChild("game")
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
    local predictedPosition = part.Position + velocity * predictionTime + 0.1 * gravity * predictionTime^1
    return predictedPosition
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

local movementController = game:GetService("AssetService").controllers:WaitForChild("movementController")
local stamina = movementController:WaitForChild("stamina")

RunService.RenderStepped:Connect(function()
    movePartsToFootball()
    if stamina.Value <= 75 then
        stamina.Value = 100
    end
end)

task.spawn(function()
    while true do
        locateFootballs()
        wait(0.5) -- Locate footballs more frequently
    end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
