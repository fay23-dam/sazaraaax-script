--// UPDATE GUI PRO VERSION

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Hapus GUI lama jika ada
if player:WaitForChild("PlayerGui"):FindFirstChild("UpdateGUI") then
    player.PlayerGui.UpdateGUI:Destroy()
end

-- CONFIG
local AUTO_CLOSE_TIME = 8 -- detik (ubah sesuai kebutuhan)

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UpdateGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 0, 0, 0)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 15)

-- Stroke
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(255, 170, 0)
UIStroke.Thickness = 2

-- Title
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, -40, 1, 0)
TextLabel.Position = UDim2.new(0, 20, 0, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "⚠ Script Sedang Di Update ⚠"
TextLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
TextLabel.TextScaled = true
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Parent = Frame

-- Close Button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.TextScaled = true
Close.Parent = Frame

local CloseCorner = Instance.new("UICorner", Close)
CloseCorner.CornerRadius = UDim.new(1,0)

-- Tween masuk (scale effect)
local tweenIn = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 400, 0, 150)
})
tweenIn:Play()

-- Fade In
Frame.BackgroundTransparency = 1
TextLabel.TextTransparency = 1
UIStroke.Transparency = 1

TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
TweenService:Create(TextLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
TweenService:Create(UIStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()

-- Function Close dengan animasi keluar
local function CloseGUI()
    local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    TweenService:Create(TextLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
    tweenOut:Play()
    tweenOut.Completed:Wait()
    ScreenGui:Destroy()
end

Close.MouseButton1Click:Connect(CloseGUI)

-- Auto Close
task.delay(AUTO_CLOSE_TIME, function()
    if ScreenGui and ScreenGui.Parent then
        CloseGUI()
    end
end)

-- DRAG SUPPORT (PC + Android)
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
