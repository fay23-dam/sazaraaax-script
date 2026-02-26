-- =========================================
-- SAZARAAAX ULTRA GLITCH LOADER (FINAL)
-- =========================================

if _G.SazaraaaxRunnerActive then
    return
end

_G.SazaraaaxRunnerActive = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")

-- Destroy old if exists
local old = playerGui:FindFirstChild("SazaraaaxUltra")
if old then
    old:Destroy()
end

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SazaraaaxUltra"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(0.6,0,0.12,0)
container.Position = UDim2.new(0.2,0,0.44,0)
container.BackgroundTransparency = 1
container.ClipsDescendants = true
container.Parent = gui

-- Main Text
local mainText = Instance.new("TextLabel")
mainText.BackgroundTransparency = 1
mainText.Size = UDim2.new(0,0,0,0)
mainText.Position = UDim2.new(1,0,0,0)
mainText.Text = "sazaraaax script is loading "
mainText.Font = Enum.Font.Arcade
mainText.TextScaled = true
mainText.TextColor3 = Color3.fromRGB(255,255,255)
mainText.TextStrokeTransparency = 0
mainText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
mainText.Parent = container

-- RGB clones
local red = mainText:Clone()
red.TextColor3 = Color3.fromRGB(255,0,0)
red.TextStrokeTransparency = 1
red.Parent = container

local blue = mainText:Clone()
blue.TextColor3 = Color3.fromRGB(0,170,255)
blue.TextStrokeTransparency = 1
blue.Parent = container

-- Cinematic Zoom
local zoomInfo = TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

TweenService:Create(mainText, zoomInfo, {
    Size = UDim2.new(1,0,1,0)
}):Play()

TweenService:Create(red, zoomInfo, {
    Size = UDim2.new(1,0,1,0)
}):Play()

TweenService:Create(blue, zoomInfo, {
    Size = UDim2.new(1,0,1,0)
}):Play()

task.wait(1.4)

-- Hacker flicker intro
for i = 1, 12 do
    local visible = (i % 2 == 0)
    mainText.Visible = visible
    red.Visible = visible
    blue.Visible = visible
    task.wait(0.05)
end

mainText.Visible = true
red.Visible = true
blue.Visible = true

-- Runner animation
local function runText(label)
    while gui.Parent do
        label.Position = UDim2.new(1,0,0,0)
        local tween = TweenService:Create(
            label,
            TweenInfo.new(6, Enum.EasingStyle.Linear),
            {Position = UDim2.new(-1,0,0,0)}
        )
        tween:Play()
        tween.Completed:Wait()
    end
end

task.spawn(function() runText(mainText) end)
task.spawn(function() runText(red) end)
task.spawn(function() runText(blue) end)

-- Glitch shader simulation
local basePosition = container.Position
local renderConnection

renderConnection = RunService.RenderStepped:Connect(function()

    if not gui.Parent then
        if renderConnection then
            renderConnection:Disconnect()
        end
        return
    end

    -- RGB split
    red.Position = mainText.Position + UDim2.new(0, math.random(-3,3), 0, math.random(-3,3))
    blue.Position = mainText.Position + UDim2.new(0, math.random(-3,3), 0, math.random(-3,3))

    -- brightness flicker
    local flicker = math.random(120,255)
    mainText.TextColor3 = Color3.fromRGB(flicker,flicker,flicker)

    -- random distortion
    if math.random(1,30) == 1 then
        container.Position = basePosition + UDim2.new(0, math.random(-5,5), 0, math.random(-3,3))
        task.delay(0.03, function()
            if container then
                container.Position = basePosition
            end
        end)
    end
end)

-- Public destroy function (biar bisa dipanggil dari script utama)
_G.DestroySazaraaaxRunner = function()

    if not _G.SazaraaaxRunnerActive then
        return
    end

    _G.SazaraaaxRunnerActive = false

    if renderConnection then
        renderConnection:Disconnect()
    end

    if gui then
        -- smooth fade out
        for _,v in pairs(gui:GetDescendants()) do
            if v:IsA("TextLabel") then
                v.TextTransparency = 1
                v.TextStrokeTransparency = 1
            end
        end
        task.wait(0.25)
        gui:Destroy()
    end
end
