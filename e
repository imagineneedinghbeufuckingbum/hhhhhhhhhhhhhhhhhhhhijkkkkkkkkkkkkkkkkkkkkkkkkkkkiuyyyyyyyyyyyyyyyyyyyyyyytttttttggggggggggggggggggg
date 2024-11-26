-- Allow 'dist' to be passed into the script from outside
local dist = _G.dist or 7 -- If 'dist' is not set, it defaults to 7

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

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

-- Move boots and right hand to the nearest football if within range
local function movePartsToFootball()
    local character = player.Character
    if character then
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

-- Monitor stamina and refill if it goes below 40
local movementController = game:GetService("AssetService").controllers:WaitForChild("movementController")
local stamina = movementController:WaitForChild("stamina")

RunService.RenderStepped:Connect(function()
    movePartsToFootball()
    if stamina.Value <= 40 then
        stamina.Value = 100
    end
end)

-- Periodically locate footballs
task.spawn(function()
    while true do
        locateFootballs()
        wait(1)
    end
end)
