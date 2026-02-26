local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Hapus jika sudah ada
if CoreGui:FindFirstChild("AxelMobileKey") then
    CoreGui.AxelMobileKey:Destroy()
end

-- CONFIG
local ImageId = "rbxassetid://6031094678"
local ButtonColor = Color3.fromRGB(30, 30, 30)
local AccentColor = Color3.fromRGB(255, 255, 255)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxelMobileKey"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- BUTTON
local MainBtn = Instance.new("ImageButton")
MainBtn.Name = "KButton"
MainBtn.Parent = ScreenGui
MainBtn.Size = UDim2.new(0, 55, 0, 55)
MainBtn.Position = UDim2.new(0, 100, 0, 300)
MainBtn.BackgroundColor3 = ButtonColor
MainBtn.BackgroundTransparency = 0.15
MainBtn.BorderSizePixel = 0
MainBtn.AutoButtonColor = false
MainBtn.Active = true

-- CORNER
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainBtn

-- STROKE
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = AccentColor
UIStroke.Transparency = 0.8
UIStroke.Thickness = 1.5
UIStroke.Parent = MainBtn

-- ICON
local Icon = Instance.new("ImageLabel")
Icon.Parent = MainBtn
Icon.Size = UDim2.new(0.6, 0, 0.6, 0)
Icon.Position = UDim2.new(0.2, 0, 0.2, 0)
Icon.BackgroundTransparency = 1
Icon.Image = ImageId
Icon.ImageColor3 = AccentColor
Icon.ScaleType = Enum.ScaleType.Fit

-- =========================
-- DRAG SYSTEM (FIXED SAFE)
-- =========================

local dragging = false
local dragStart
local startPos

MainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        
        dragging = true
        dragStart = input.Position
        startPos = MainBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and 
       (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch) then
        
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y

        -- Batasi agar tidak keluar layar
        local screenSize = workspace.CurrentCamera.ViewportSize
        local btnSize = MainBtn.AbsoluteSize

        newX = math.clamp(newX, 0, screenSize.X - btnSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - btnSize.Y)

        MainBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- =========================
-- TOGGLE RAYFIELD ONLY
-- =========================

local function ToggleRayfield()

    -- Cari Rayfield di CoreGui
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name:lower():find("rayfield") then
            gui.Enabled = not gui.Enabled
        end
    end

end

-- CLICK
MainBtn.MouseButton1Click:Connect(function()

    -- animasi kecil
    local shrink = TweenService:Create(MainBtn, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 48, 0, 48)
    })
    local expand = TweenService:Create(MainBtn, TweenInfo.new(0.08), {
        Size = UDim2.new(0, 55, 0, 55)
    })

    shrink:Play()
    shrink.Completed:Wait()
    expand:Play()

    ToggleRayfield()

end)
