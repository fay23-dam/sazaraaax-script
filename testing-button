local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

if CoreGui:FindFirstChild("AxelMobileKey") then
    CoreGui.AxelMobileKey:Destroy()
end

local ImageId = "rbxassetid://6031094678"
local ButtonColor = Color3.fromRGB(30, 30, 30)
local AccentColor = Color3.fromRGB(255, 255, 255)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxelMobileKey"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainBtn = Instance.new("ImageButton")
MainBtn.Name = "KButton"
MainBtn.Parent = ScreenGui
MainBtn.Size = UDim2.new(0, 55, 0, 55)
MainBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
MainBtn.AnchorPoint = Vector2.new(0, 0)
MainBtn.BackgroundColor3 = ButtonColor
MainBtn.BackgroundTransparency = 0.2
MainBtn.BorderSizePixel = 0
MainBtn.AutoButtonColor = false
MainBtn.Active = true
MainBtn.Draggable = false -- kita pakai custom drag

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = AccentColor
UIStroke.Transparency = 0.8
UIStroke.Thickness = 1.5
UIStroke.Parent = MainBtn

local Icon = Instance.new("ImageLabel")
Icon.Parent = MainBtn
Icon.Size = UDim2.new(0.6, 0, 0.6, 0)
Icon.Position = UDim2.new(0.2, 0, 0.2, 0)
Icon.BackgroundTransparency = 1
Icon.Image = ImageId
Icon.ImageColor3 = AccentColor
Icon.ScaleType = Enum.ScaleType.Fit

-- DRAG SYSTEM FIXED
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
        
        -- Clamp agar tidak keluar layar
        local screenSize = workspace.CurrentCamera.ViewportSize
        local btnSize = MainBtn.AbsoluteSize
        
        newX = math.clamp(newX, 0, screenSize.X - btnSize.X)
        newY = math.clamp(newY, 0, screenSize.Y - btnSize.Y)
        
        MainBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- CLICK EFFECT
MainBtn.MouseButton1Click:Connect(function()
    local shrink = TweenService:Create(MainBtn, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 50, 0, 50)
    })
    local expand = TweenService:Create(MainBtn, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 55, 0, 55)
    })
    
    shrink:Play()
    shrink.Completed:Wait()
    expand:Play()

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.K, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.K, false, game)
end)
