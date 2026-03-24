local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishItPanelV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 120)
stroke.Thickness = 2.5
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "🐟 FISH IT PANEL v2"
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Position = UDim2.new(0, 15, 0, 45)
fpsLabel.Size = UDim2.new(1, -30, 0, 22)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Font = Enum.Font.GothamSemibold
fpsLabel.TextScaled = true
fpsLabel.Parent = mainFrame

local cpuLabel = Instance.new("TextLabel")
cpuLabel.Position = UDim2.new(0, 15, 0, 70)
cpuLabel.Size = UDim2.new(1, -30, 0, 22)
cpuLabel.BackgroundTransparency = 1
cpuLabel.Text = "CPU: 245 MB"
cpuLabel.TextColor3 = Color3.new(1, 1, 1)
cpuLabel.TextXAlignment = Enum.TextXAlignment.Left
cpuLabel.Font = Enum.Font.GothamSemibold
cpuLabel.TextScaled = true
cpuLabel.Parent = mainFrame

local netLabel = Instance.new("TextLabel")
netLabel.Position = UDim2.new(0, 15, 0, 95)
netLabel.Size = UDim2.new(1, -30, 0, 22)
netLabel.BackgroundTransparency = 1
netLabel.Text = "Network: 45 ms"
netLabel.TextColor3 = Color3.new(1, 1, 1)
netLabel.TextXAlignment = Enum.TextXAlignment.Left
netLabel.Font = Enum.Font.GothamSemibold
netLabel.TextScaled = true
netLabel.Parent = mainFrame

local caughtLabel = Instance.new("TextLabel")
caughtLabel.Position = UDim2.new(0, 15, 0, 120)
caughtLabel.Size = UDim2.new(1, -30, 0, 25)
caughtLabel.BackgroundTransparency = 1
caughtLabel.Text = "Caught: 0"
caughtLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
caughtLabel.TextXAlignment = Enum.TextXAlignment.Left
caughtLabel.Font = Enum.Font.GothamBold
caughtLabel.TextScaled = true
caughtLabel.Parent = mainFrame

local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local fps = 0
local lastTick = tick()
RunService.RenderStepped:Connect(function()
    fps += 1
    local now = tick()
    if now - lastTick >= 1 then
        fpsLabel.Text = "FPS: " .. math.floor(fps)
        fps = 0
        lastTick = now
    end
end)

local function updateStats()
    cpuLabel.Text = "CPU: " .. math.floor(Stats:GetTotalMemoryUsageMb()) .. " MB"
    local pingText = "N/A"
    local robloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if robloxGui then
        local perf = robloxGui:FindFirstChild("PerformanceStats")
        if perf then
            for _, v in ipairs(perf:GetChildren()) do
                if v:FindFirstChild("StatsMiniTextPanelClass") then
                    local titleLbl = v.StatsMiniTextPanelClass:FindFirstChild("TitleLabel")
                    if titleLbl and titleLbl.Text == "Ping" then
                        local val = v.StatsMiniTextPanelClass:FindFirstChild("ValueLabel")
                        if val then pingText = val.Text end
                        break
                    end
                end
            end
        end
    end
    netLabel.Text = "Network: " .. pingText
end
RunService.Heartbeat:Connect(updateStats)

local caughtCount = 0
caughtLabel.Text = "Caught: " .. caughtCount
local lastCaughtTime = 0
local DETECT_COOLDOWN = 0.5

playerGui.DescendantAdded:Connect(function(desc)
    if desc:IsA("TextLabel") or desc:IsA("TextButton") then
        local text = desc.Text:lower()
        local now = tick()
        if now - lastCaughtTime > DETECT_COOLDOWN and
           (text:find("caught") or text:find("you caught") or text:find("fish") or text:find("reel in")) then
            caughtCount += 1
            caughtLabel.Text = "Caught: " .. caughtCount
            caughtLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
            task.delay(0.4, function()
                caughtLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            end)
            lastCaughtTime = now
        end
    end
end)

task.spawn(function()
    local lastFishTotal = 0
    while task.wait(2) do
        local totalFish = 0
        local inv = playerGui:FindFirstChild("Inventory") or playerGui:FindFirstChild("Backpack") or playerGui:FindFirstChild("FishingInventory") or player:FindFirstChild("Inventory")
        if inv then
            for _, item in ipairs(inv:GetDescendants()) do
                if item:IsA("TextLabel") and item.Text:match("%d+") then
                    totalFish += tonumber(item.Text:match("%d+")) or 0
                end
            end
        end
        if totalFish > lastFishTotal then
            local added = totalFish - lastFishTotal
            caughtCount += added
            caughtLabel.Text = "Caught: " .. caughtCount
            lastFishTotal = totalFish
        end
    end
end)
