--[[
    Victoria Script - Fixed Version
    by sazaraaax & dhanzy
    Fixed: ESP toggle, dropItem nil, collect return to base
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:FindFirstChildOfClass("Humanoid")
end)

local InteractiveItem = workspace:WaitForChild("GameSystem"):WaitForChild("InteractiveItem")
local WorldFolder = workspace:WaitForChild("GameSystem"):WaitForChild("Loots"):WaitForChild("World")
local NPCModels = workspace:WaitForChild("GameSystem"):WaitForChild("NPCModels")
local BasePart = workspace["\231\148\181\230\162\175"].Left4["\229\141\135\233\153\141\229\143\176"]:WaitForChild("Ground")

-- STATE
local isOpeningActive = false
local isCollectingActive = false
local isMonsterActive = false
local totalCollected = 0
local totalOpened = 0
local totalSkipped = 0
local noclipEnabled = false
local isFlying = false
local isMinimized = false
local sessionStart = tick()
local currentTab = "farm"
local potatoMode = false
local originalQuality = nil
local espEnabled = true

-- SETTINGS
local settings = {
    delayMode = "normal",
    skipList = {},
    itemFilter = {},
    waypoints = {},
}

-- DETECT MOBILE
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- DELAYS
local DELAYS = {
    fast   = { tp = 0.10, look = 0.08, highlight = 1.0, afterE = 0.15, base = 0.10 },
    normal = { tp = 0.20, look = 0.10, highlight = 1.5, afterE = 0.30, base = 0.15 },
    safe   = { tp = 0.40, look = 0.20, highlight = 2.0, afterE = 0.60, base = 0.35 },
}

local RARITY_COLORS = {
    ["Cash"]             = Color3.fromRGB(52, 199, 109),
    ["Gift Box"]         = Color3.fromRGB(255, 126, 179),
    ["Peppermint Candy"] = Color3.fromRGB(200, 100, 255),
    ["Corn"]             = Color3.fromRGB(255, 220, 50),
}
local DEFAULT_ESP_COLOR = Color3.fromRGB(80, 160, 230)

local SKIP_BASE_ITEMS = { ["Cash"] = true }

local logEntries = {}

local function addLog(text, color)
    color = color or Color3.fromRGB(95, 108, 102)
    table.insert(logEntries, { text = text, color = color, time = os.date("%H:%M:%S") })
    if #logEntries > 100 then table.remove(logEntries, 1) end
end

-- ============================================================
-- HELPER FUNCTIONS (early definitions)
-- ============================================================
local function enableNoclip() noclipEnabled = true end
local function disableNoclip()
    noclipEnabled = false
    if character then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function startFly()
    isFlying = true
    humanoidRootPart.Anchored = true
    enableNoclip()
    if humanoid then humanoid.WalkSpeed = 0; humanoid.JumpPower = 0 end
end

local function stopFly()
    isFlying = false
    disableNoclip()
    humanoidRootPart.Anchored = false
    if humanoid then humanoid.WalkSpeed = 16; humanoid.JumpPower = 50 end
end

local function anchorTP(targetCFrame)
    startFly()
    humanoidRootPart.CFrame = targetCFrame
    local d = DELAYS[settings.delayMode]
    task.wait(d.tp)
    stopFly()
end

local function lookAt(targetPart)
    local origin = humanoidRootPart.Position
    local target = targetPart.Position
    local direction = Vector3.new(target.X - origin.X, 0, target.Z - origin.Z).Unit
    humanoidRootPart.CFrame = CFrame.new(origin, origin + direction)
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(origin + Vector3.new(0, 2, 0), target)
    local d = DELAYS[settings.delayMode]
    task.wait(d.look)
    camera.CameraType = Enum.CameraType.Custom
end

local function hasHighlight(model)
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") then return true end
    end
    return false
end

local function waitForHighlight(model)
    local d = DELAYS[settings.delayMode]
    local elapsed = 0
    while elapsed < d.highlight do
        if hasHighlight(model) then return true end
        task.wait(0.05)
        elapsed = elapsed + 0.05
    end
    return false
end

local function getStandPart(model)
    local folder = model:FindFirstChildWhichIsA("Folder")
    if not folder then return nil end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "Interactable" then return child end
    end
    return nil
end

-- ============================================================
-- MOBILE INTERACTION FUNCTIONS (reliable)
-- ============================================================
local function findGuiButton(path)
    local parts = {}
    for part in path:gmatch("[^%.]+") do
        table.insert(parts, part)
    end
    local current = playerGui
    for _, part in ipairs(parts) do
        if not current then return nil end
        current = current:FindFirstChild(part)
    end
    return current
end

local function getInteractButton()
    local paths = {
        "Touch.Right.InteractButton",
        "Interactable.Main.Frame.Touch",
        "Main.HomePage.Bottom.InteractButton"
    }
    for _, path in ipairs(paths) do
        local btn = findGuiButton(path)
        if btn and btn:IsA("GuiButton") then return btn end
    end
    return nil
end

local function getDropButton()
    local paths = {
        "Touch.Right.DropButton",
        "Main.HomePage.Bottom.DropButton"
    }
    for _, path in ipairs(paths) do
        local btn = findGuiButton(path)
        if btn and btn:IsA("GuiButton") then return btn end
    end
    return nil
end

local function getSlotButton(slotNumber)
    local paths = {
        "Main.HomePage.Bottom." .. tostring(slotNumber),
        "Touch.Right.Slot" .. tostring(slotNumber)
    }
    for _, path in ipairs(paths) do
        local btn = findGuiButton(path)
        if btn and btn:IsA("GuiButton") then return btn end
    end
    return nil
end

local function tapButton(button)
    if not button or not button:IsA("GuiButton") then return false end
    for _ = 1, 3 do
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        if pos.X > 0 and pos.Y > 0 and size.X > 0 and size.Y > 0 then
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2
            VirtualInputManager:SendTouchEvent(1, x, y, true, game)
            task.wait(0.05)
            VirtualInputManager:SendTouchEvent(1, x, y, false, game)
            return true
        end
        task.wait(0.1)
    end
    return false
end

local function interactWithPart(part)
    if isMobile then
        local interactBtn = getInteractButton()
        if interactBtn then
            return tapButton(interactBtn)
        else
            local screenPos, onScreen = camera:WorldToScreenPoint(part.Position)
            if onScreen then
                VirtualInputManager:SendTouchEvent(1, screenPos.X, screenPos.Y, true, game)
                task.wait(0.05)
                VirtualInputManager:SendTouchEvent(1, screenPos.X, screenPos.Y, false, game)
                return true
            end
        end
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        return true
    end
    return false
end

local function dropItem()
    if isMobile then
        local dropBtn = getDropButton()
        if dropBtn then
            return tapButton(dropBtn)
        end
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
        return true
    end
    return false
end

local function useBatInSlot(slotNumber)
    if isMobile then
        local slotBtn = getSlotButton(slotNumber)
        if slotBtn then
            return tapButton(slotBtn)
        end
    else
        local key = Enum.KeyCode.One
        if slotNumber == 2 then key = Enum.KeyCode.Two
        elseif slotNumber == 3 then key = Enum.KeyCode.Three
        elseif slotNumber == 4 then key = Enum.KeyCode.Four end
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        return true
    end
    return false
end

-- ============================================================
-- ANTI VOID / NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not humanoidRootPart then return end
    if not isFlying and humanoidRootPart.Position.Y < 200 then
        humanoidRootPart.Anchored = true
        humanoidRootPart.CFrame = BasePart.CFrame + Vector3.new(0, 4, 0)
        task.wait(0.2)
        humanoidRootPart.Anchored = false
    end
end)

-- ============================================================
-- CLEANUP OLD GUIs
-- ============================================================
for _, g in ipairs({"VictoriaScript", "VictoriaESP", "VictoriaRadar"}) do
    if playerGui:FindFirstChild(g) then playerGui[g]:Destroy() end
end

-- ============================================================
-- MAIN GUI (RESPONSIVE)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VictoriaScript"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local viewportSize = camera.ViewportSize
local scaleFactor = math.clamp(viewportSize.X / 1920, 0.7, 1.2)
local BASE_WIDTH = 290
local BASE_HEIGHT = 560
local MINI_HEIGHT = 50
local WIDTH = BASE_WIDTH * scaleFactor
local FULL_H = BASE_HEIGHT * scaleFactor
local MINI_H = MINI_HEIGHT * scaleFactor

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, WIDTH, 0, FULL_H)
mainFrame.Position = UDim2.new(1, -(WIDTH + 16), 0.5, -FULL_H / 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 15, 17)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12 * scaleFactor)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(38, 43, 48)
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(1, 0, 0, 100 * scaleFactor)
topGlow.BackgroundColor3 = Color3.fromRGB(52, 199, 109)
topGlow.BackgroundTransparency = 0.94
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 0
topGlow.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, MINI_H)
header.BackgroundColor3 = Color3.fromRGB(18, 20, 22)
header.BorderSizePixel = 0
header.ZIndex = 5
header.Parent = mainFrame

local headerDiv = Instance.new("Frame")
headerDiv.Size = UDim2.new(1, 0, 0, 1)
headerDiv.Position = UDim2.new(0, 0, 1, -1)
headerDiv.BackgroundColor3 = Color3.fromRGB(38, 43, 48)
headerDiv.BorderSizePixel = 0
headerDiv.ZIndex = 6
headerDiv.Parent = header

local function makeTraffic(color, posX)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10 * scaleFactor, 0, 10 * scaleFactor)
    dot.Position = UDim2.new(0, posX * scaleFactor, 0.5, -5 * scaleFactor)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    dot.Parent = header
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot
end
makeTraffic(Color3.fromRGB(255, 95, 87), 12)
makeTraffic(Color3.fromRGB(255, 189, 46), 26)
makeTraffic(Color3.fromRGB(52, 199, 109), 40)

local tildeLabel = Instance.new("TextLabel")
tildeLabel.Size = UDim2.new(0, 12 * scaleFactor, 0, 24 * scaleFactor)
tildeLabel.Position = UDim2.new(0, 66 * scaleFactor, 0.5, -12 * scaleFactor)
tildeLabel.BackgroundTransparency = 1
tildeLabel.Text = "~"
tildeLabel.TextColor3 = Color3.fromRGB(52, 199, 109)
tildeLabel.TextScaled = true
tildeLabel.Font = Enum.Font.Code
tildeLabel.ZIndex = 6
tildeLabel.Parent = header

local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(0, 115 * scaleFactor, 0, 15 * scaleFactor)
logoLabel.Position = UDim2.new(0, 82 * scaleFactor, 0.5, -7 * scaleFactor)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "Victoria Script"
logoLabel.TextColor3 = Color3.fromRGB(218, 224, 218)
logoLabel.TextScaled = true
logoLabel.Font = Enum.Font.GothamBold
logoLabel.TextXAlignment = Enum.TextXAlignment.Left
logoLabel.ZIndex = 6
logoLabel.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24 * scaleFactor, 0, 24 * scaleFactor)
minBtn.Position = UDim2.new(1, -54 * scaleFactor, 0.5, -12 * scaleFactor)
minBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
minBtn.BorderSizePixel = 0
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(95, 108, 102)
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
minBtn.ZIndex = 7
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6 * scaleFactor)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24 * scaleFactor, 0, 24 * scaleFactor)
closeBtn.Position = UDim2.new(1, -26 * scaleFactor, 0.5, -12 * scaleFactor)
closeBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(95, 108, 102)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 7
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6 * scaleFactor)

-- DRAG HANDLER
local dragging = false
local dragStart = nil
local dragStartPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        dragStartPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if dragging then
        dragging = false
    end
end)

-- TAB BAR
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36 * scaleFactor)
tabBar.Position = UDim2.new(0, 0, 0, MINI_H)
tabBar.BackgroundColor3 = Color3.fromRGB(16, 18, 20)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 5
tabBar.Parent = mainFrame

local tabBarDiv = Instance.new("Frame")
tabBarDiv.Size = UDim2.new(1, 0, 0, 1)
tabBarDiv.Position = UDim2.new(0, 0, 1, -1)
tabBarDiv.BackgroundColor3 = Color3.fromRGB(38, 43, 48)
tabBarDiv.BorderSizePixel = 0
tabBarDiv.ZIndex = 6
tabBarDiv.Parent = tabBar

local tabBarLayout = Instance.new("UIListLayout")
tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
tabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabBarLayout.Padding = UDim.new(0, 0)
tabBarLayout.Parent = tabBar

local CONTENT_TOP = MINI_H + 36 * scaleFactor

-- SCROLL FRAMES
local scrollFrames = {}
local tabBtns = {}

local function makeScrollFrame()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, -CONTENT_TOP)
    sf.Position = UDim2.new(0, 0, 0, CONTENT_TOP)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3 * scaleFactor
    sf.ScrollBarImageColor3 = Color3.fromRGB(52, 199, 109)
    sf.ScrollBarImageTransparency = 0.5
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.ZIndex = 2
    sf.Visible = false
    sf.Parent = mainFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10 * scaleFactor)
    pad.PaddingBottom = UDim.new(0, 14 * scaleFactor)
    pad.Parent = sf

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8 * scaleFactor)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = sf

    return sf
end

local function makeTabBtn(label, tabName, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, WIDTH / 3, 1, 0)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(95, 108, 102)
    btn.TextScaled = true
    btn.Font = Enum.Font.Code
    btn.ZIndex = 6
    btn.LayoutOrder = order
    btn.Parent = tabBar

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0.6, 0, 0, 2 * scaleFactor)
    indicator.Position = UDim2.new(0.2, 0, 1, -2 * scaleFactor)
    indicator.BackgroundColor3 = Color3.fromRGB(52, 199, 109)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.ZIndex = 7
    indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    tabBtns[tabName] = { btn = btn, indicator = indicator }
    return btn
end

local tabFarm    = makeTabBtn("farm", "farm", 1)
local tabStats   = makeTabBtn("stats", "stats", 2)
local tabNav     = makeTabBtn("nav", "nav", 3)

scrollFrames["farm"]   = makeScrollFrame()
scrollFrames["stats"]  = makeScrollFrame()
scrollFrames["nav"]    = makeScrollFrame()

local function switchTab(name)
    currentTab = name
    for tabName, sf in pairs(scrollFrames) do
        sf.Visible = (tabName == name)
    end
    for tabName, data in pairs(tabBtns) do
        if tabName == name then
            TweenService:Create(data.btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(52, 199, 109)}):Play()
            TweenService:Create(data.indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        else
            TweenService:Create(data.btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(95, 108, 102)}):Play()
            TweenService:Create(data.indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end
end

tabFarm.MouseButton1Click:Connect(function() switchTab("farm") end)
tabStats.MouseButton1Click:Connect(function() switchTab("stats") end)
tabNav.MouseButton1Click:Connect(function() switchTab("nav") end)

-- ============================================================
-- WIDGET HELPERS
-- ============================================================
local function makeSectionLabel(sf, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24 * scaleFactor, 0, 16 * scaleFactor)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(95, 108, 102)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.LayoutOrder = order
    lbl.Parent = sf
    return lbl
end

local function makeDivider(sf, order)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(1, -24 * scaleFactor, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(38, 43, 48)
    d.BorderSizePixel = 0
    d.ZIndex = 3
    d.LayoutOrder = order
    d.Parent = sf
    return d
end

local function makeBtn(sf, labelText, subText, accentColor, order)
    accentColor = accentColor or Color3.fromRGB(52, 199, 109)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24 * scaleFactor, 0, 50 * scaleFactor)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 3
    btn.LayoutOrder = order
    btn.Parent = sf

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9 * scaleFactor)
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(38, 43, 48)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3 * scaleFactor, 0, 28 * scaleFactor)
    accentBar.Position = UDim2.new(0, 10 * scaleFactor, 0.5, -14 * scaleFactor)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 4
    accentBar.Parent = btn
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local mainLbl = Instance.new("TextLabel")
    mainLbl.Size = UDim2.new(1, -65 * scaleFactor, 0, 20 * scaleFactor)
    mainLbl.Position = UDim2.new(0, 22 * scaleFactor, 0, 7 * scaleFactor)
    mainLbl.BackgroundTransparency = 1
    mainLbl.Text = labelText
    mainLbl.TextColor3 = Color3.fromRGB(218, 224, 218)
    mainLbl.TextScaled = true
    mainLbl.Font = Enum.Font.GothamBold
    mainLbl.TextXAlignment = Enum.TextXAlignment.Left
    mainLbl.ZIndex = 4
    mainLbl.Parent = btn

    local subLbl = Instance.new("TextLabel")
    subLbl.Name = "Sub"
    subLbl.Size = UDim2.new(1, -65 * scaleFactor, 0, 14 * scaleFactor)
    subLbl.Position = UDim2.new(0, 22 * scaleFactor, 0, 28 * scaleFactor)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = subText
    subLbl.TextColor3 = Color3.fromRGB(95, 108, 102)
    subLbl.TextScaled = true
    subLbl.Font = Enum.Font.Code
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.ZIndex = 4
    subLbl.Parent = btn

    local badge = Instance.new("TextLabel")
    badge.Name = "Badge"
    badge.Size = UDim2.new(0, 40 * scaleFactor, 0, 18 * scaleFactor)
    badge.Position = UDim2.new(1, -50 * scaleFactor, 0.5, -9 * scaleFactor)
    badge.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
    badge.BorderSizePixel = 0
    badge.Text = "OFF"
    badge.TextColor3 = Color3.fromRGB(95, 108, 102)
    badge.TextScaled = true
    badge.Font = Enum.Font.Code
    badge.ZIndex = 4
    badge.Parent = btn
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5 * scaleFactor)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 29, 32)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = accentColor, Transparency = 0.55}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 22, 24)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(38, 43, 48), Transparency = 0}):Play()
    end)

    return btn, badge, accentBar, btnStroke
end

local function makeSmallBtn(sf, text, accentColor, order)
    accentColor = accentColor or Color3.fromRGB(52, 199, 109)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24 * scaleFactor, 0, 32 * scaleFactor)
    btn.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(95, 108, 102)
    btn.TextScaled = true
    btn.Font = Enum.Font.Code
    btn.ZIndex = 3
    btn.LayoutOrder = order
    btn.Parent = sf
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7 * scaleFactor)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(38, 43, 48)
    s.Thickness = 1
    s.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 29, 32), TextColor3 = accentColor}):Play()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = accentColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 22, 24), TextColor3 = Color3.fromRGB(95, 108, 102)}):Play()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = Color3.fromRGB(38, 43, 48)}):Play()
    end)
    return btn, s
end

local function makeInfoRow(sf, label, value, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24 * scaleFactor, 0, 28 * scaleFactor)
    row.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.LayoutOrder = order
    row.Parent = sf
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7 * scaleFactor)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10 * scaleFactor, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(95, 108, 102)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Name = "Value"
    val.Size = UDim2.new(0.5, -10 * scaleFactor, 1, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextColor3 = Color3.fromRGB(52, 199, 109)
    val.TextScaled = true
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.ZIndex = 4
    val.Parent = row

    return row, val
end

-- ============================================================
-- TAB: FARM
-- ============================================================
local sfFarm = scrollFrames["farm"]

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -24 * scaleFactor, 0, 30 * scaleFactor)
statusBar.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 3
statusBar.LayoutOrder = 1
statusBar.Parent = sfFarm
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 7 * scaleFactor)
local statusBarStroke = Instance.new("UIStroke")
statusBarStroke.Color = Color3.fromRGB(38, 43, 48)
statusBarStroke.Thickness = 1
statusBarStroke.Parent = statusBar

local pingDot = Instance.new("Frame")
pingDot.Size = UDim2.new(0, 6 * scaleFactor, 0, 6 * scaleFactor)
pingDot.Position = UDim2.new(0, 10 * scaleFactor, 0.5, -3 * scaleFactor)
pingDot.BackgroundColor3 = Color3.fromRGB(52, 199, 109)
pingDot.BorderSizePixel = 0
pingDot.ZIndex = 4
pingDot.Parent = statusBar
Instance.new("UICorner", pingDot).CornerRadius = UDim.new(1, 0)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -26 * scaleFactor, 1, 0)
statusLabel.Position = UDim2.new(0, 22 * scaleFactor, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "status: idle"
statusLabel.TextColor3 = Color3.fromRGB(95, 108, 102)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Code
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 4
statusLabel.Parent = statusBar

local counterBar = Instance.new("Frame")
counterBar.Size = UDim2.new(1, -24 * scaleFactor, 0, 28 * scaleFactor)
counterBar.BackgroundColor3 = Color3.fromRGB(15, 40, 24)
counterBar.BorderSizePixel = 0
counterBar.ZIndex = 3
counterBar.LayoutOrder = 2
counterBar.Parent = sfFarm
Instance.new("UICorner", counterBar).CornerRadius = UDim.new(0, 7 * scaleFactor)
local counterBarStroke = Instance.new("UIStroke")
counterBarStroke.Color = Color3.fromRGB(52, 199, 109)
counterBarStroke.Thickness = 1
counterBarStroke.Transparency = 0.65
counterBarStroke.Parent = counterBar

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, -16 * scaleFactor, 1, 0)
counterLabel.Position = UDim2.new(0, 8 * scaleFactor, 0, 0)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "// opened: 0  · collected: 0  · skipped: 0"
counterLabel.TextColor3 = Color3.fromRGB(52, 199, 109)
counterLabel.TextScaled = true
counterLabel.Font = Enum.Font.Code
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.ZIndex = 4
counterLabel.Parent = counterBar

local function updateCounter()
    counterLabel.Text = "// opened: " .. totalOpened .. "  · collected: " .. totalCollected .. "  · skipped: " .. totalSkipped
end

local function setStatus(text, color)
    statusLabel.Text = "status: " .. text
    statusLabel.TextColor3 = color or Color3.fromRGB(95, 108, 102)
    pingDot.BackgroundColor3 = color or Color3.fromRGB(52, 199, 109)
end

makeSectionLabel(sfFarm, "// farm controls", 3)
local btnOpen, badgeOpen, _, strokeOpen = makeBtn(sfFarm, "AUTO OPEN", "// open all containers", Color3.fromRGB(52, 199, 109), 4)
local btnCollect, badgeCollect, _, strokeCollect = makeBtn(sfFarm, "AUTO COLLECT", "// collect all loot", Color3.fromRGB(80, 160, 230), 5)
local btnMonster, badgeMonster, _, strokeMonster = makeBtn(sfFarm, "AUTO MONSTER", "// kill monsters with bat", Color3.fromRGB(255, 80, 120), 6)

makeSectionLabel(sfFarm, "// navigation", 7)
local btnBase, badgeBase = makeBtn(sfFarm, "TP TO BASE", "// teleport to ground base", Color3.fromRGB(255, 185, 55), 8)
badgeBase.Text = "GO"
badgeBase.TextColor3 = Color3.fromRGB(255, 185, 55)
badgeBase.BackgroundColor3 = Color3.fromRGB(42, 30, 6)

local btnNearestLoot, _ = makeBtn(sfFarm, "NEAREST LOOT", "// tp to closest loot item", Color3.fromRGB(200, 100, 255), 9)
local badgeNearestLoot = btnNearestLoot:FindFirstChild("Badge")
badgeNearestLoot.Text = "TP"
badgeNearestLoot.TextColor3 = Color3.fromRGB(200, 100, 255)
badgeNearestLoot.BackgroundColor3 = Color3.fromRGB(30, 15, 40)

local btnNPC, badgeNPC = makeBtn(sfFarm, "NPC: NONE", "// no active npc found", Color3.fromRGB(255, 126, 179), 10)

-- ============================================================
-- SKIP ITEMS UI (Fixed Scrolling)
-- ============================================================
local v1 = {}
v1[101] = { name = "Cash", type = "Money" }
v1[102] = { name = "Cash", type = "Money" }
v1[201] = { name = "Golden Bar", type = "MoneyGoldBar" }
v1[10001] = { name = "Tomato soup", type = "Food" }
v1[10003] = { name = "Milk", type = "Food" }
v1[10014] = { name = "Corn", type = "Food" }
v1[10027] = { name = "Peppermint Candy", type = "Food" }
v1[10035] = { name = "Gift Box", type = "Tool" }

local allItemNames = {}
for _, data in pairs(v1) do
    if data.name then
        allItemNames[data.name] = true
    end
end

local function buildSkipItemsUI()
    local existing = sfFarm:FindFirstChild("SkipListFrame")
    if existing then existing:Destroy() end

    makeSectionLabel(sfFarm, "// skip items (select to skip)", 51)

    local skipListFrame = Instance.new("ScrollingFrame")
    skipListFrame.Name = "SkipListFrame"
    skipListFrame.Size = UDim2.new(1, -24 * scaleFactor, 0, 200 * scaleFactor)
    skipListFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
    skipListFrame.BorderSizePixel = 0
    skipListFrame.ZIndex = 3
    skipListFrame.LayoutOrder = 52
    skipListFrame.Parent = sfFarm
    skipListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    skipListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", skipListFrame).CornerRadius = UDim.new(0, 8 * scaleFactor)
    Instance.new("UIStroke", skipListFrame).Color = Color3.fromRGB(38, 43, 48)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4 * scaleFactor)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = skipListFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6 * scaleFactor)
    pad.PaddingBottom = UDim.new(0, 6 * scaleFactor)
    pad.PaddingLeft = UDim.new(0, 8 * scaleFactor)
    pad.PaddingRight = UDim.new(0, 8 * scaleFactor)
    pad.Parent = skipListFrame

    local function addCheckboxRow(itemName)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 32 * scaleFactor)
        row.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
        row.BorderSizePixel = 0
        row.ZIndex = 4
        row.Parent = skipListFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6 * scaleFactor)

        local check = Instance.new("ImageLabel")
        check.Size = UDim2.new(0, 20 * scaleFactor, 0, 20 * scaleFactor)
        check.Position = UDim2.new(0, 8 * scaleFactor, 0.5, -10 * scaleFactor)
        check.BackgroundTransparency = 1
        check.Image = "rbxassetid://6023426926"
        check.ZIndex = 5
        check.Parent = row

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -40 * scaleFactor, 1, 0)
        nameLbl.Position = UDim2.new(0, 36 * scaleFactor, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = itemName
        nameLbl.TextColor3 = Color3.fromRGB(218, 224, 218)
        nameLbl.TextScaled = true
        nameLbl.Font = Enum.Font.Code
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 5
        nameLbl.Parent = row

        local checkboxState = false
        for _, skip in ipairs(settings.skipList) do
            if string.lower(skip) == string.lower(itemName) then
                checkboxState = true
                break
            end
        end

        local function updateCheckboxImage()
            if checkboxState then
                check.Image = "rbxassetid://6023426926"
                check.ImageColor3 = Color3.fromRGB(52, 199, 109)
            else
                check.Image = "rbxassetid://0"
                check.ImageColor3 = Color3.fromRGB(95, 108, 102)
            end
        end
        updateCheckboxImage()

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 6
        btn.Parent = row

        btn.MouseButton1Click:Connect(function()
            checkboxState = not checkboxState
            updateCheckboxImage()
            if checkboxState then
                table.insert(settings.skipList, itemName)
            else
                for j, val in ipairs(settings.skipList) do
                    if string.lower(val) == string.lower(itemName) then
                        table.remove(settings.skipList, j)
                        break
                    end
                end
            end
            addLog("skip list updated: " .. itemName .. " = " .. tostring(checkboxState), Color3.fromRGB(255, 185, 55))
        end)
    end

    local sortedNames = {}
    for name in pairs(allItemNames) do
        table.insert(sortedNames, name)
    end
    table.sort(sortedNames)
    for _, name in ipairs(sortedNames) do
        addCheckboxRow(name)
    end
end
buildSkipItemsUI()

-- ============================================================
-- DELAY MODE
-- ============================================================
makeDivider(sfFarm, 11)
makeSectionLabel(sfFarm, "// delay mode", 12)

local delayFrame = Instance.new("Frame")
delayFrame.Size = UDim2.new(1, -24 * scaleFactor, 0, 36 * scaleFactor)
delayFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
delayFrame.BorderSizePixel = 0
delayFrame.ZIndex = 3
delayFrame.LayoutOrder = 13
delayFrame.Parent = sfFarm
Instance.new("UICorner", delayFrame).CornerRadius = UDim.new(0, 9 * scaleFactor)
Instance.new("UIStroke", delayFrame).Color = Color3.fromRGB(38, 43, 48)

local delayLayout = Instance.new("UIListLayout")
delayLayout.FillDirection = Enum.FillDirection.Horizontal
delayLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
delayLayout.VerticalAlignment = Enum.VerticalAlignment.Center
delayLayout.Padding = UDim.new(0, 4 * scaleFactor)
delayLayout.Parent = delayFrame

local delayPad = Instance.new("UIPadding")
delayPad.PaddingLeft = UDim.new(0, 6 * scaleFactor)
delayPad.PaddingRight = UDim.new(0, 6 * scaleFactor)
delayPad.Parent = delayFrame

local delayBtns = {}
for _, mode in ipairs({"fast", "normal", "safe"}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, -4 * scaleFactor, 0, 26 * scaleFactor)
    btn.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
    btn.BorderSizePixel = 0
    btn.Text = mode
    btn.TextColor3 = Color3.fromRGB(95, 108, 102)
    btn.TextScaled = true
    btn.Font = Enum.Font.Code
    btn.ZIndex = 4
    btn.Parent = delayFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6 * scaleFactor)
    delayBtns[mode] = btn
end

local function updateDelayBtns()
    for mode, btn in pairs(delayBtns) do
        if mode == settings.delayMode then
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(15, 42, 26),
                TextColor3 = Color3.fromRGB(52, 199, 109)
            }):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(28, 32, 36),
                TextColor3 = Color3.fromRGB(95, 108, 102)
            }):Play()
        end
    end
end

updateDelayBtns()
for mode, btn in pairs(delayBtns) do
    btn.MouseButton1Click:Connect(function()
        settings.delayMode = mode
        updateDelayBtns()
        addLog("delay mode set to: " .. mode, Color3.fromRGB(52, 199, 109))
    end)
end

-- ============================================================
-- POTATO MODE
-- ============================================================
makeDivider(sfFarm, 21)
makeSectionLabel(sfFarm, "// potato mode (low graphics)", 22)

local potatoBtn, potatoStroke = makeSmallBtn(sfFarm, "// potato mode (OFF)", Color3.fromRGB(255, 185, 55), 23)

local potatoBadge = Instance.new("TextLabel")
potatoBadge.Size = UDim2.new(0, 40 * scaleFactor, 0, 18 * scaleFactor)
potatoBadge.Position = UDim2.new(1, -50 * scaleFactor, 0.5, -9 * scaleFactor)
potatoBadge.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
potatoBadge.BorderSizePixel = 0
potatoBadge.Text = "OFF"
potatoBadge.TextColor3 = Color3.fromRGB(95, 108, 102)
potatoBadge.TextScaled = true
potatoBadge.Font = Enum.Font.Code
potatoBadge.ZIndex = 4
potatoBadge.Parent = potatoBtn
Instance.new("UICorner", potatoBadge).CornerRadius = UDim.new(0, 5 * scaleFactor)

local CONFIG = { BATCH_SIZE = 200, DISABLE_GUI = false }
local originalData = {}
local potatoConnections = {}

local function saveOriginal(obj, prop, value)
    if not originalData[obj] then originalData[obj] = {} end
    if originalData[obj][prop] == nil then
        originalData[obj][prop] = value
    end
end

local function processObject(obj)
    if obj:IsA("BasePart") then
        saveOriginal(obj, "Material", obj.Material)
        saveOriginal(obj, "Reflectance", obj.Reflectance)
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        saveOriginal(obj, "Transparency", obj.Transparency)
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        saveOriginal(obj, "Enabled", obj.Enabled)
        obj.Enabled = false
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        saveOriginal(obj, "Enabled", obj.Enabled)
        obj.Enabled = false
    elseif CONFIG.DISABLE_GUI and obj:IsA("ScreenGui") then
        saveOriginal(obj, "Enabled", obj.Enabled)
        obj.Enabled = false
    end
end

local function processWorkspace()
    local all = workspace:GetDescendants()
    for i = 1, #all, CONFIG.BATCH_SIZE do
        for j = i, math.min(i + CONFIG.BATCH_SIZE - 1, #all) do
            processObject(all[j])
        end
        task.wait()
    end
end

local function hookNewObjects()
    table.insert(potatoConnections,
        workspace.DescendantAdded:Connect(function(obj)
            task.defer(function()
                if potatoMode then
                    processObject(obj)
                end
            end)
        end)
    )
end

local function clearConnections()
    for _, c in ipairs(potatoConnections) do
        pcall(function() c:Disconnect() end)
    end
    potatoConnections = {}
end

local function restoreAll()
    for obj, props in pairs(originalData) do
        if obj and obj.Parent then
            for prop, value in pairs(props) do
                pcall(function() obj[prop] = value end)
            end
        end
    end
    originalData = {}
end

local function toggleExtremePotato()
    potatoMode = not potatoMode

    if potatoMode then
        pcall(function()
            originalQuality = settings().Rendering.QualityLevel
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        Lighting.GlobalShadows = false
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0

        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                saveOriginal(v, "Density", v.Density)
                v.Density = 0
            elseif v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                saveOriginal(v, "Enabled", v.Enabled)
                v.Enabled = false
            end
        end

        pcall(function()
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            workspace.Terrain.WaterReflectance = 0
            workspace.Terrain.WaterTransparency = 1
        end)

        processWorkspace()
        hookNewObjects()

        potatoBtn.Text = "// potato mode (ON)"
        potatoBadge.Text = "ON"
        potatoBadge.TextColor3 = Color3.fromRGB(255, 185, 55)
        potatoBadge.BackgroundColor3 = Color3.fromRGB(42, 30, 6)

        print("🔥 EXTREME POTATO MODE ON")
    else
        pcall(function()
            settings().Rendering.QualityLevel = originalQuality or Enum.QualityLevel.Level03
        end)

        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1

        restoreAll()
        clearConnections()

        potatoBtn.Text = "// potato mode (OFF)"
        potatoBadge.Text = "OFF"
        potatoBadge.TextColor3 = Color3.fromRGB(95, 108, 102)
        potatoBadge.BackgroundColor3 = Color3.fromRGB(28, 32, 36)

        print("🥔 POTATO MODE OFF")
    end
end

potatoBtn.MouseButton1Click:Connect(function()
    toggleExtremePotato()
end)

-- ============================================================
-- ESP TOGGLE & SYSTEM
-- ============================================================
makeDivider(sfFarm, 24)
makeSectionLabel(sfFarm, "// esp settings", 25)
local espToggleBtn, espToggleStroke = makeSmallBtn(sfFarm, "// esp (on)", Color3.fromRGB(80, 160, 230), 26)

-- ============================================================
-- SYSTEM SECTION
-- ============================================================
makeSectionLabel(sfFarm, "// system", 27)
local btnReset, _ = makeSmallBtn(sfFarm, "// reset counter", Color3.fromRGB(220, 60, 60), 28)
local forceDropBtn, _ = makeSmallBtn(sfFarm, "// force drop item", Color3.fromRGB(200, 100, 0), 29)

makeDivider(sfFarm, 30)

-- Community links
local function makeLinkBtn(sf, icon, labelText, subText, accentColor, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24 * scaleFactor, 0, 44 * scaleFactor)
    btn.BackgroundColor3 = Color3.fromRGB(18, 20, 22)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 3
    btn.LayoutOrder = order
    btn.Parent = sf
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9 * scaleFactor)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(38, 43, 48)
    s.Thickness = 1
    s.Parent = btn

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 28 * scaleFactor, 0, 28 * scaleFactor)
    iconLbl.Position = UDim2.new(0, 10 * scaleFactor, 0.5, -14 * scaleFactor)
    iconLbl.BackgroundColor3 = Color3.fromRGB(
        math.floor(accentColor.R * 255 * 0.1),
        math.floor(accentColor.G * 255 * 0.1),
        math.floor(accentColor.B * 255 * 0.1)
    )
    iconLbl.BorderSizePixel = 0
    iconLbl.Text = icon
    iconLbl.TextScaled = true
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextColor3 = accentColor
    iconLbl.ZIndex = 4
    iconLbl.Parent = btn
    Instance.new("UICorner", iconLbl).CornerRadius = UDim.new(0, 6 * scaleFactor)

    local ml = Instance.new("TextLabel")
    ml.Size = UDim2.new(1, -90 * scaleFactor, 0, 18 * scaleFactor)
    ml.Position = UDim2.new(0, 46 * scaleFactor, 0.5, -18 * scaleFactor)
    ml.BackgroundTransparency = 1
    ml.Text = labelText
    ml.TextColor3 = Color3.fromRGB(218, 224, 218)
    ml.TextScaled = true
    ml.Font = Enum.Font.GothamBold
    ml.TextXAlignment = Enum.TextXAlignment.Left
    ml.ZIndex = 4
    ml.Parent = btn

    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, -90 * scaleFactor, 0, 13 * scaleFactor)
    sl.Position = UDim2.new(0, 46 * scaleFactor, 0.5, 4 * scaleFactor)
    sl.BackgroundTransparency = 1
    sl.Text = subText
    sl.TextColor3 = Color3.fromRGB(95, 108, 102)
    sl.TextScaled = true
    sl.Font = Enum.Font.Code
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.ZIndex = 4
    sl.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20 * scaleFactor, 0, 20 * scaleFactor)
    arrow.Position = UDim2.new(1, -28 * scaleFactor, 0.5, -10 * scaleFactor)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.TextColor3 = accentColor
    arrow.TextScaled = true
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 4
    arrow.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 27, 30)}):Play()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = accentColor, Transparency = 0.6}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 20, 22)}):Play()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = Color3.fromRGB(38, 43, 48), Transparency = 0}):Play()
    end)
    return btn
end

makeSectionLabel(sfFarm, "// community", 31)
local btnDiscord = makeLinkBtn(sfFarm, "D", "Discord", "// discord.gg/HB9gqZGMnT", Color3.fromRGB(114, 137, 218), 32)
local btnWA = makeLinkBtn(sfFarm, "W", "WhatsApp Channel", "// wa channel", Color3.fromRGB(37, 211, 102), 33)
local btnSaweria = makeLinkBtn(sfFarm, "c", "Saweria", "// saweria.co/sazaraaa", Color3.fromRGB(255, 185, 55), 34)

local footerLbl = Instance.new("TextLabel")
footerLbl.Size = UDim2.new(1, -24 * scaleFactor, 0, 24 * scaleFactor)
footerLbl.BackgroundTransparency = 1
footerLbl.Text = "~ Victoria Script · by sazaraaax & dhanzy"
footerLbl.TextColor3 = Color3.fromRGB(38, 48, 42)
footerLbl.TextScaled = true
footerLbl.Font = Enum.Font.Code
footerLbl.ZIndex = 3
footerLbl.LayoutOrder = 35
footerLbl.Parent = sfFarm

-- ============================================================
-- TAB: STATS
-- ============================================================
local sfStats = scrollFrames["stats"]

makeSectionLabel(sfStats, "// session stats", 1)

local _, valTimer    = makeInfoRow(sfStats, "session time", "00:00:00", 2)
local _, valOpened   = makeInfoRow(sfStats, "total opened", "0", 3)
local _, valCollect  = makeInfoRow(sfStats, "total collected", "0", 4)
local _, valSkipped  = makeInfoRow(sfStats, "total skipped", "0", 5)
local _, valIPM      = makeInfoRow(sfStats, "items / min", "0.0", 6)

makeSectionLabel(sfStats, "// activity log", 7)

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -24 * scaleFactor, 0, 260 * scaleFactor)
logFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 22)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 2 * scaleFactor
logFrame.ScrollBarImageColor3 = Color3.fromRGB(52, 199, 109)
logFrame.ScrollBarImageTransparency = 0.6
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.ZIndex = 3
logFrame.LayoutOrder = 8
logFrame.Parent = sfStats
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 8 * scaleFactor)
Instance.new("UIStroke", logFrame).Color = Color3.fromRGB(38, 43, 48)

local logPad = Instance.new("UIPadding")
logPad.PaddingTop = UDim.new(0, 6 * scaleFactor)
logPad.PaddingBottom = UDim.new(0, 6 * scaleFactor)
logPad.PaddingLeft = UDim.new(0, 8 * scaleFactor)
logPad.PaddingRight = UDim.new(0, 8 * scaleFactor)
logPad.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2 * scaleFactor)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logFrame

local logCounter = 0
local function renderLog(entry)
    logCounter = logCounter + 1
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, 0, 0, 16 * scaleFactor)
    row.BackgroundTransparency = 1
    row.Text = "[" .. entry.time .. "] " .. entry.text
    row.TextColor3 = entry.color
    row.TextScaled = true
    row.Font = Enum.Font.Code
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.ZIndex = 4
    row.LayoutOrder = logCounter
    row.Parent = logFrame
    logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
end

local clearLogBtn, _ = makeSmallBtn(sfStats, "// clear log", Color3.fromRGB(220, 60, 60), 9)
clearLogBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(logFrame:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    logEntries = {}
    logCounter = 0
end)

-- Stats update loop
RunService.Heartbeat:Connect(function()
    if currentTab ~= "stats" then return end
    local elapsed = tick() - sessionStart
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = math.floor(elapsed % 60)
    valTimer.Text = string.format("%02d:%02d:%02d", h, m, s)
    valOpened.Text = tostring(totalOpened)
    valCollect.Text = tostring(totalCollected)
    valSkipped.Text = tostring(totalSkipped)
    local mins = math.max(elapsed / 60, 0.01)
    valIPM.Text = string.format("%.1f", totalCollected / mins)
end)

-- ============================================================
-- TAB: NAV
-- ============================================================
local sfNav = scrollFrames["nav"]

makeSectionLabel(sfNav, "// waypoints", 1)

local wpInputRow = Instance.new("Frame")
wpInputRow.Size = UDim2.new(1, -24 * scaleFactor, 0, 32 * scaleFactor)
wpInputRow.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
wpInputRow.BorderSizePixel = 0
wpInputRow.ZIndex = 3
wpInputRow.LayoutOrder = 2
wpInputRow.Parent = sfNav
Instance.new("UICorner", wpInputRow).CornerRadius = UDim.new(0, 8 * scaleFactor)
Instance.new("UIStroke", wpInputRow).Color = Color3.fromRGB(38, 43, 48)

local wpInput = Instance.new("TextBox")
wpInput.Size = UDim2.new(1, -70 * scaleFactor, 1, 0)
wpInput.Position = UDim2.new(0, 8 * scaleFactor, 0, 0)
wpInput.BackgroundTransparency = 1
wpInput.Text = ""
wpInput.PlaceholderText = "waypoint name..."
wpInput.PlaceholderColor3 = Color3.fromRGB(60, 70, 65)
wpInput.TextColor3 = Color3.fromRGB(218, 224, 218)
wpInput.TextScaled = true
wpInput.Font = Enum.Font.Code
wpInput.TextXAlignment = Enum.TextXAlignment.Left
wpInput.ClearTextOnFocus = false
wpInput.ZIndex = 4
wpInput.Parent = wpInputRow

local wpSaveBtn = Instance.new("TextButton")
wpSaveBtn.Size = UDim2.new(0, 56 * scaleFactor, 0, 22 * scaleFactor)
wpSaveBtn.Position = UDim2.new(1, -62 * scaleFactor, 0.5, -11 * scaleFactor)
wpSaveBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 28)
wpSaveBtn.BorderSizePixel = 0
wpSaveBtn.Text = "save"
wpSaveBtn.TextColor3 = Color3.fromRGB(52, 199, 109)
wpSaveBtn.TextScaled = true
wpSaveBtn.Font = Enum.Font.Code
wpSaveBtn.ZIndex = 5
wpSaveBtn.Parent = wpInputRow
Instance.new("UICorner", wpSaveBtn).CornerRadius = UDim.new(0, 5 * scaleFactor)

local wpListFrame = Instance.new("Frame")
wpListFrame.Size = UDim2.new(1, -24 * scaleFactor, 0, 10 * scaleFactor)
wpListFrame.AutomaticSize = Enum.AutomaticSize.Y
wpListFrame.BackgroundTransparency = 1
wpListFrame.BorderSizePixel = 0
wpListFrame.ZIndex = 3
wpListFrame.LayoutOrder = 3
wpListFrame.Parent = sfNav

local wpListLayout = Instance.new("UIListLayout")
wpListLayout.Padding = UDim.new(0, 6 * scaleFactor)
wpListLayout.SortOrder = Enum.SortOrder.LayoutOrder
wpListLayout.Parent = wpListFrame

local wpEmptyLbl = Instance.new("TextLabel")
wpEmptyLbl.Size = UDim2.new(1, 0, 0, 24 * scaleFactor)
wpEmptyLbl.BackgroundTransparency = 1
wpEmptyLbl.Text = "no waypoints saved"
wpEmptyLbl.TextColor3 = Color3.fromRGB(60, 70, 65)
wpEmptyLbl.TextScaled = true
wpEmptyLbl.Font = Enum.Font.Code
wpEmptyLbl.ZIndex = 3
wpEmptyLbl.Parent = wpListFrame

local function refreshWaypoints()
    for _, v in ipairs(wpListFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    wpEmptyLbl.Visible = #settings.waypoints == 0
    for i, wp in ipairs(settings.waypoints) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38 * scaleFactor)
        row.BackgroundColor3 = Color3.fromRGB(20, 22, 24)
        row.BorderSizePixel = 0
        row.ZIndex = 3
        row.LayoutOrder = i
        row.Parent = wpListFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8 * scaleFactor)
        Instance.new("UIStroke", row).Color = Color3.fromRGB(38, 43, 48)

        local accentDot = Instance.new("Frame")
        accentDot.Size = UDim2.new(0, 3 * scaleFactor, 0, 20 * scaleFactor)
        accentDot.Position = UDim2.new(0, 8 * scaleFactor, 0.5, -10 * scaleFactor)
        accentDot.BackgroundColor3 = Color3.fromRGB(52, 199, 109)
        accentDot.BorderSizePixel = 0
        accentDot.ZIndex = 4
        accentDot.Parent = row
        Instance.new("UICorner", accentDot).CornerRadius = UDim.new(1, 0)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
        nameLbl.Position = UDim2.new(0, 20 * scaleFactor, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = wp.name
        nameLbl.TextColor3 = Color3.fromRGB(218, 224, 218)
        nameLbl.TextScaled = true
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 4
        nameLbl.Parent = row

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 36 * scaleFactor, 0, 22 * scaleFactor)
        tpBtn.Position = UDim2.new(1, -80 * scaleFactor, 0.5, -11 * scaleFactor)
        tpBtn.BackgroundColor3 = Color3.fromRGB(15, 42, 26)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "tp"
        tpBtn.TextColor3 = Color3.fromRGB(52, 199, 109)
        tpBtn.TextScaled = true
        tpBtn.Font = Enum.Font.Code
        tpBtn.ZIndex = 5
        tpBtn.Parent = row
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5 * scaleFactor)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 30 * scaleFactor, 0, 22 * scaleFactor)
        delBtn.Position = UDim2.new(1, -38 * scaleFactor, 0.5, -11 * scaleFactor)
        delBtn.BackgroundColor3 = Color3.fromRGB(35, 18, 18)
        delBtn.BorderSizePixel = 0
        delBtn.Text = "del"
        delBtn.TextColor3 = Color3.fromRGB(220, 60, 60)
        delBtn.TextScaled = true
        delBtn.Font = Enum.Font.Code
        delBtn.ZIndex = 5
        delBtn.Parent = row
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 5 * scaleFactor)

        local wpCF = wp.cframe
        tpBtn.MouseButton1Click:Connect(function()
            humanoidRootPart.Anchored = true
            humanoidRootPart.CFrame = wpCF + Vector3.new(0, 3, 0)
            task.wait(0.2)
            humanoidRootPart.Anchored = false
            setStatus("tp to waypoint: " .. wp.name, Color3.fromRGB(52, 199, 109))
            addLog("tp to waypoint: " .. wp.name, Color3.fromRGB(52, 199, 109))
        end)

        local idx = i
        delBtn.MouseButton1Click:Connect(function()
            table.remove(settings.waypoints, idx)
            refreshWaypoints()
            addLog("removed waypoint: " .. wp.name, Color3.fromRGB(220, 60, 60))
        end)
    end
end

wpSaveBtn.MouseButton1Click:Connect(function()
    local name = wpInput.Text
    if name ~= "" and humanoidRootPart then
        table.insert(settings.waypoints, { name = name, cframe = humanoidRootPart.CFrame })
        wpInput.Text = ""
        refreshWaypoints()
        addLog("saved waypoint: " .. name, Color3.fromRGB(52, 199, 109))
        setStatus("waypoint saved: " .. name, Color3.fromRGB(52, 199, 109))
    end
end)

refreshWaypoints()

-- ============================================================
-- ESP SYSTEM (FIXED)
-- ============================================================
local espGui = Instance.new("ScreenGui")
espGui.Name = "VictoriaESP"
espGui.ResetOnSpawn = false
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = playerGui

espLabels = {} -- key = object, value = { billboard, adornPart, name, type }

-- Helper functions for loot
local function findLootData(slotChild)
    if slotChild:IsA("BasePart") and slotChild.Name == "Interactable" then
        return slotChild:FindFirstChild("LootUI"), slotChild
    elseif slotChild:IsA("Folder") then
        local interactable = slotChild:FindFirstChild("Interactable")
        if interactable then return interactable:FindFirstChild("LootUI"), interactable end
    elseif slotChild:IsA("Model") then
        local interactable = slotChild:FindFirstChild("Interactable")
        if interactable then return interactable:FindFirstChild("LootUI"), interactable end
    elseif slotChild:IsA("Tool") then
        local folder = slotChild:FindFirstChildWhichIsA("Folder")
        if folder then
            local interactable = folder:FindFirstChild("Interactable")
            if interactable then return interactable:FindFirstChild("LootUI"), interactable end
        end
    end
    return nil, nil
end

local function getItemName(lootUI)
    if not lootUI then return nil end
    local frame = lootUI:FindFirstChild("Frame")
    if not frame then return nil end
    local itemName = frame:FindFirstChild("ItemName")
    if not itemName or itemName.Text == "" then return nil end
    return itemName.Text
end

local function isItemOnBase(adornPart)
    if not adornPart or not adornPart.Parent then return false end
    local basePos = BasePart.Position
    local baseSize = BasePart.Size
    local itemPos = adornPart.Position
    local onX = math.abs(itemPos.X - basePos.X) < (baseSize.X / 2)
    local onZ = math.abs(itemPos.Z - basePos.Z) < (baseSize.Z / 2)
    local onY = itemPos.Y >= basePos.Y - 5 and itemPos.Y <= basePos.Y + 15
    return onX and onZ and onY
end

-- Billboard creator
local function createBillboard(adornPart, name, color)
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200 * scaleFactor, 0, 50 * scaleFactor)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = adornPart
    billboard.Parent = espGui

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.fromRGB(13, 15, 17)
    bg.BackgroundTransparency = 0.25
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BorderSizePixel = 0
    bg.Parent = billboard
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6 * scaleFactor)

    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color = color
    bgStroke.Thickness = 1
    bgStroke.Transparency = 0.5
    bgStroke.Parent = bg

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(0, 3 * scaleFactor, 0, 30 * scaleFactor)
    accentLine.Position = UDim2.new(0, 5 * scaleFactor, 0.5, -15 * scaleFactor)
    accentLine.BackgroundColor3 = color
    accentLine.BorderSizePixel = 0
    accentLine.Parent = bg
    Instance.new("UICorner", accentLine).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = Color3.fromRGB(218, 224, 218)
    label.TextStrokeTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20 * scaleFactor, 0.6, 0)
    label.Position = UDim2.new(0, 14 * scaleFactor, 0, 4 * scaleFactor)
    label.Parent = bg

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Code
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, -20 * scaleFactor, 0.4, 0)
    distLabel.Position = UDim2.new(0, 14 * scaleFactor, 0.6, 0)
    distLabel.Parent = bg

    return billboard
end

local function removeESP(obj)
    if espLabels[obj] then
        espLabels[obj].billboard:Destroy()
        espLabels[obj] = nil
    end
end

local function refreshAllESP()
    -- Destroy all current ESP
    for obj, data in pairs(espLabels) do
        pcall(function() data.billboard:Destroy() end)
    end
    espLabels = {}

    if not espEnabled then return end

    -- Loot ESP
    for _, slot in ipairs(WorldFolder:GetChildren()) do
        for _, child in ipairs(slot:GetChildren()) do
            local lootUI, adornPart = findLootData(child)
            if lootUI and adornPart then
                local name = getItemName(lootUI)
                if name and not isItemOnBase(adornPart) then
                    local color = RARITY_COLORS[name] or DEFAULT_ESP_COLOR
                    local billboard = createBillboard(adornPart, name, color)
                    espLabels[child] = { billboard = billboard, adornPart = adornPart, name = name, type = "loot" }
                end
            end
        end
    end

    -- NPC ESP
    for _, npc in ipairs(NPCModels:GetChildren()) do
        if npc:IsA("Model") then
            local head = npc:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                local billboard = createBillboard(head, npc.Name, Color3.fromRGB(0, 200, 100))
                espLabels[npc] = { billboard = billboard, adornPart = head, name = npc.Name, type = "npc" }
            end
        end
    end

    -- Monster ESP
    local monsters = workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("Monsters")
    if monsters then
        for _, monster in ipairs(monsters:GetChildren()) do
            if monster:IsA("Model") then
                local head = monster:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    local billboard = createBillboard(head, monster.Name, Color3.fromRGB(220, 60, 60))
                    espLabels[monster] = { billboard = billboard, adornPart = head, name = monster.Name, type = "monster" }
                end
            end
        end
    end
end

-- Toggle ESP
espToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espToggleBtn.Text = "// esp (on)"
        refreshAllESP()
    else
        espToggleBtn.Text = "// esp (off)"
        for obj, data in pairs(espLabels) do
            data.billboard:Destroy()
        end
        espLabels = {}
    end
end)

-- Dynamic updates for loot ESP
WorldFolder.DescendantAdded:Connect(function(desc)
    task.defer(function()
        if not espEnabled then return end
        local lootUI, adornPart = findLootData(desc)
        if lootUI and adornPart then
            local name = getItemName(lootUI)
            if name and not isItemOnBase(adornPart) and not espLabels[desc] then
                local color = RARITY_COLORS[name] or DEFAULT_ESP_COLOR
                local billboard = createBillboard(adornPart, name, color)
                espLabels[desc] = { billboard = billboard, adornPart = adornPart, name = name, type = "loot" }
            end
        end
    end)
end)

WorldFolder.DescendantRemoving:Connect(function(desc)
    removeESP(desc)
end)

-- NPC ESP
NPCModels.ChildAdded:Connect(function(npc)
    task.defer(function()
        if not espEnabled then return end
        if npc:IsA("Model") then
            local head = npc:FindFirstChild("Head")
            if head and head:IsA("BasePart") and not espLabels[npc] then
                local billboard = createBillboard(head, npc.Name, Color3.fromRGB(0, 200, 100))
                espLabels[npc] = { billboard = billboard, adornPart = head, name = npc.Name, type = "npc" }
            end
        end
    end)
end)

NPCModels.ChildRemoved:Connect(function(npc)
    removeESP(npc)
end)

-- Monster ESP
local monstersContainer = workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("Monsters")
if monstersContainer then
    local function onMonsterAdded(monster)
        if not espEnabled then return end
        if monster:IsA("Model") then
            local head = monster:FindFirstChild("Head")
            if head and head:IsA("BasePart") and not espLabels[monster] then
                local billboard = createBillboard(head, monster.Name, Color3.fromRGB(220, 60, 60))
                espLabels[monster] = { billboard = billboard, adornPart = head, name = monster.Name, type = "monster" }
            end
        end
    end
    local function onMonsterRemoved(monster)
        removeESP(monster)
    end
    monstersContainer.ChildAdded:Connect(onMonsterAdded)
    monstersContainer.ChildRemoved:Connect(onMonsterRemoved)
end

-- Update distances (throttled)
local lastDistanceUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastDistanceUpdate >= 0.2 then
        lastDistanceUpdate = now
        for obj, data in pairs(espLabels) do
            if not data.adornPart or not data.adornPart.Parent then
                removeESP(obj)
            else
                local dist = (humanoidRootPart.Position - data.adornPart.Position).Magnitude
                local distLabel = data.billboard:FindFirstChild("Frame"):FindFirstChild("Distance")
                if distLabel then
                    distLabel.Text = string.format("%.1f studs", dist)
                    if dist < 20 then
                        distLabel.TextColor3 = Color3.fromRGB(52, 199, 109)
                    elseif dist < 50 then
                        distLabel.TextColor3 = Color3.fromRGB(255, 185, 55)
                    else
                        distLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- CACHE LOOT ITEMS FOR COLLECT
-- ============================================================
local cachedLootItems = {}

local function updateCachedItem(child)
    local lootUI, adornPart = findLootData(child)
    if lootUI and adornPart then
        local name = getItemName(lootUI)
        if name then
            local found = false
            for i, v in ipairs(cachedLootItems) do
                if v.item == child then
                    found = true
                    v.adornPart = adornPart
                    v.name = name
                    break
                end
            end
            if not found then
                table.insert(cachedLootItems, { item = child, adornPart = adornPart, name = name })
            end
        end
    else
        for i, v in ipairs(cachedLootItems) do
            if v.item == child then
                table.remove(cachedLootItems, i)
                break
            end
        end
    end
end

WorldFolder.DescendantAdded:Connect(function(desc)
    task.defer(function()
        updateCachedItem(desc)
        if espEnabled then
            local lootUI, adornPart = findLootData(desc)
            if lootUI and adornPart then
                local name = getItemName(lootUI)
                if name and not isItemOnBase(adornPart) and not espLabels[desc] then
                    local color = RARITY_COLORS[name] or DEFAULT_ESP_COLOR
                    local billboard = createBillboard(adornPart, name, color)
                    espLabels[desc] = { billboard = billboard, adornPart = adornPart, name = name, type = "loot" }
                end
            end
        end
    end)
end)

WorldFolder.DescendantRemoving:Connect(function(desc)
    for i, v in ipairs(cachedLootItems) do
        if v.item == desc then
            table.remove(cachedLootItems, i)
            break
        end
    end
    removeESP(desc)
end)

-- Initial scan for cached items and ESP
local function initialScan()
    for _, slot in ipairs(WorldFolder:GetChildren()) do
        for _, child in ipairs(slot:GetChildren()) do
            updateCachedItem(child)
            if espEnabled then
                local lootUI, adornPart = findLootData(child)
                if lootUI and adornPart then
                    local name = getItemName(lootUI)
                    if name and not isItemOnBase(adornPart) and not espLabels[child] then
                        local color = RARITY_COLORS[name] or DEFAULT_ESP_COLOR
                        local billboard = createBillboard(adornPart, name, color)
                        espLabels[child] = { billboard = billboard, adornPart = adornPart, name = name, type = "loot" }
                    end
                end
            end
            task.wait()
        end
    end
end
task.spawn(initialScan)

-- ============================================================
-- AUTO OPEN
-- ============================================================
local function runOpenModels()
    isOpeningActive = true
    badgeOpen.Text = "ON"
    badgeOpen.TextColor3 = Color3.fromRGB(52, 199, 109)
    badgeOpen.BackgroundColor3 = Color3.fromRGB(15, 42, 26)
    TweenService:Create(strokeOpen, TweenInfo.new(0.2), {Color = Color3.fromRGB(52, 199, 109), Transparency = 0.5}):Play()
    addLog("auto open started", Color3.fromRGB(52, 199, 109))

    local allModels = {}
    local function collectModels(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("Model") then table.insert(allModels, child) end
            collectModels(child)
        end
    end
    collectModels(InteractiveItem)

    for i, model in ipairs(allModels) do
        if not isOpeningActive then break end

        local shouldSkip = false
        for _, skipName in ipairs(settings.skipList) do
            if model.Name:lower():find(skipName:lower()) then
                shouldSkip = true
                break
            end
        end
        if shouldSkip then
            totalSkipped = totalSkipped + 1
            updateCounter()
            addLog("skipped: " .. model.Name, Color3.fromRGB(255, 185, 55))
            continue
        end

        setStatus("opening " .. i .. "/" .. #allModels .. ": " .. model.Name, Color3.fromRGB(52, 199, 109))
        local interactable = model:FindFirstChild("Interactable")
        if not interactable then continue end

        local standPart = getStandPart(model)
        if standPart then
            anchorTP(CFrame.new(standPart.Position + Vector3.new(0, 3, 0)))
        else
            anchorTP(CFrame.new(interactable.Position + Vector3.new(0, 3, 0)))
        end

        lookAt(interactable)

        local highlighted = waitForHighlight(model)
        if not highlighted then
            addLog("no highlight: " .. model.Name, Color3.fromRGB(220, 80, 80))
            continue
        end

        interactWithPart(interactable)
        local d = DELAYS[settings.delayMode]
        task.wait(d.afterE)

        totalOpened = totalOpened + 1
        updateCounter()
        addLog("opened: " .. model.Name, Color3.fromRGB(52, 199, 109))
    end

    isOpeningActive = false
    badgeOpen.Text = "OFF"
    badgeOpen.TextColor3 = Color3.fromRGB(95, 108, 102)
    badgeOpen.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
    TweenService:Create(strokeOpen, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 43, 48), Transparency = 0}):Play()
    setStatus("phase 1 done! opened: " .. totalOpened, Color3.fromRGB(52, 199, 109))
    addLog("auto open done. opened: " .. totalOpened, Color3.fromRGB(52, 199, 109))
end

-- ============================================================
-- AUTO COLLECT (Improved)
-- ============================================================
local function returnToBase()
    setStatus("returning to base...", Color3.fromRGB(255, 185, 55))
    anchorTP(BasePart.CFrame + Vector3.new(0, 4, 0))
    -- Use dropItem safely
    local success, err = pcall(dropItem)
    if not success then
        addLog("dropItem failed: " .. tostring(err), Color3.fromRGB(220, 80, 80))
    end
    local d = DELAYS[settings.delayMode]
    task.wait(d.base)
end

local function runCollectLoots()
    isCollectingActive = true
    badgeCollect.Text = "ON"
    badgeCollect.TextColor3 = Color3.fromRGB(80, 160, 230)
    badgeCollect.BackgroundColor3 = Color3.fromRGB(10, 24, 42)
    TweenService:Create(strokeCollect, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 160, 230), Transparency = 0.5}):Play()
    addLog("auto collect started", Color3.fromRGB(80, 160, 230))

    for i, loot in ipairs(cachedLootItems) do
        if not isCollectingActive then break end
        if not loot.item.Parent then continue end
        if not loot.adornPart or not loot.adornPart.Parent then continue end
        if isItemOnBase(loot.adornPart) then continue end

        if #settings.itemFilter > 0 then
            local allowed = false
            for _, filterName in ipairs(settings.itemFilter) do
                if loot.name:lower():find(filterName:lower()) then
                    allowed = true
                    break
                end
            end
            if not allowed then
                addLog("filtered: " .. loot.name, Color3.fromRGB(255, 185, 55))
                continue
            end
        end

        local shouldSkip = false
        for _, skipName in ipairs(settings.skipList) do
            if loot.name:lower():find(skipName:lower()) then
                shouldSkip = true
                break
            end
        end
        if shouldSkip then
            addLog("skipped (skip list): " .. loot.name, Color3.fromRGB(255, 185, 55))
            totalSkipped = totalSkipped + 1
            updateCounter()
            continue
        end

        setStatus("collecting " .. i .. "/" .. #cachedLootItems .. ": " .. loot.name, Color3.fromRGB(80, 160, 230))

        startFly()
        humanoidRootPart.CFrame = CFrame.new(loot.adornPart.Position + Vector3.new(0, 3, 0))
        local d = DELAYS[settings.delayMode]
        task.wait(d.tp)

        if isMobile then
            local start = tick()
            local btn = getInteractButton()
            while not btn and tick() - start < 3 do
                task.wait(0.1)
                btn = getInteractButton()
            end
            if not btn then
                addLog("interact button not found for: " .. loot.name, Color3.fromRGB(220,80,80))
                continue
            end
        else
            lookAt(loot.adornPart)
            task.wait(0.2)
        end

        interactWithPart(loot.adornPart)
        task.wait(d.afterE)
        stopFly()

        totalCollected = totalCollected + 1
        updateCounter()
        addLog("collected: " .. loot.name, RARITY_COLORS[loot.name] or Color3.fromRGB(80, 160, 230))

        if not SKIP_BASE_ITEMS[loot.name] then
            returnToBase()
        end
    end

    isCollectingActive = false
    badgeCollect.Text = "OFF"
    badgeCollect.TextColor3 = Color3.fromRGB(95, 108, 102)
    badgeCollect.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
    TweenService:Create(strokeCollect, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 43, 48), Transparency = 0}):Play()
    setStatus("done! total collected: " .. totalCollected, Color3.fromRGB(80, 160, 230))
    addLog("collect done. total: " .. totalCollected, Color3.fromRGB(80, 160, 230))
end

-- ============================================================
-- AUTO MONSTER
-- ============================================================
local function getNearestMonster()
    local monsters = workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("Monsters")
    if not monsters then return nil end
    local nearest = nil
    local nearestDist = math.huge
    for _, monster in ipairs(monsters:GetChildren()) do
        if monster:IsA("Model") then
            local head = monster:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                local dist = (humanoidRootPart.Position - head.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = {model = monster, head = head}
                end
            end
        end
    end
    return nearest
end

local function runAutoMonster()
    isMonsterActive = true
    badgeMonster.Text = "ON"
    badgeMonster.TextColor3 = Color3.fromRGB(255, 80, 120)
    badgeMonster.BackgroundColor3 = Color3.fromRGB(40, 10, 20)
    TweenService:Create(strokeMonster, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 80, 120), Transparency = 0.5}):Play()
    addLog("auto monster started", Color3.fromRGB(255, 80, 120))

    while isMonsterActive do
        local batUsed = false
        for slot = 1, 4 do
            if useBatInSlot(slot) then
                batUsed = true
                break
            end
        end
        if not batUsed then
            setStatus("no bat found!", Color3.fromRGB(255, 80, 120))
            task.wait(1)
            continue
        end

        local monster = getNearestMonster()
        if not monster then
            setStatus("no monster found!", Color3.fromRGB(255, 80, 120))
            task.wait(1)
            continue
        end

        setStatus("attacking monster: " .. monster.model.Name, Color3.fromRGB(255, 80, 120))
        startFly()
        humanoidRootPart.CFrame = CFrame.new(monster.head.Position + Vector3.new(0, 5, 0))
        local d = DELAYS[settings.delayMode]
        task.wait(d.tp)

        if isMobile then
            for slot = 1, 4 do
                if useBatInSlot(slot) then
                    break
                end
            end
        else
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
        task.wait(0.2)
        stopFly()
        task.wait(0.5)
    end

    stopFly()
    badgeMonster.Text = "OFF"
    badgeMonster.TextColor3 = Color3.fromRGB(95, 108, 102)
    badgeMonster.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
    TweenService:Create(strokeMonster, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 43, 48), Transparency = 0}):Play()
    setStatus("auto monster stopped", Color3.fromRGB(255, 80, 120))
    addLog("auto monster stopped", Color3.fromRGB(255, 80, 120))
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        minBtn.Text = "+"
        for _, sf in pairs(scrollFrames) do sf.Visible = false end
        tabBar.Visible = false
        TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {Size = UDim2.new(0, WIDTH, 0, MINI_H)}):Play()
    else
        minBtn.Text = "-"
        tabBar.Visible = true
        scrollFrames[currentTab].Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, WIDTH, 0, FULL_H)}):Play()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Position = UDim2.new(-0.3, 0, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
    })
    tween:Play()
    tween.Completed:Connect(function() mainFrame.Visible = false end)
end)

btnOpen.MouseButton1Click:Connect(function()
    if isOpeningActive then
        isOpeningActive = false
        badgeOpen.Text = "OFF"
        badgeOpen.TextColor3 = Color3.fromRGB(95, 108, 102)
        badgeOpen.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
        TweenService:Create(strokeOpen, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 43, 48), Transparency = 0}):Play()
        setStatus("stopped", Color3.fromRGB(220, 80, 80))
        addLog("auto open stopped", Color3.fromRGB(220, 80, 80))
    else
        task.spawn(runOpenModels)
    end
end)

btnCollect.MouseButton1Click:Connect(function()
    if isCollectingActive then
        isCollectingActive = false
        badgeCollect.Text = "OFF"
        badgeCollect.TextColor3 = Color3.fromRGB(95, 108, 102)
        badgeCollect.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
        TweenService:Create(strokeCollect, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 43, 48), Transparency = 0}):Play()
        setStatus("stopped", Color3.fromRGB(220, 80, 80))
        addLog("auto collect stopped", Color3.fromRGB(220, 80, 80))
    else
        task.spawn(runCollectLoots)
    end
end)

btnMonster.MouseButton1Click:Connect(function()
    if isMonsterActive then
        isMonsterActive = false
    else
        task.spawn(runAutoMonster)
    end
end)

btnBase.MouseButton1Click:Connect(function()
    setStatus("teleporting to base...", Color3.fromRGB(255, 185, 55))
    anchorTP(BasePart.CFrame + Vector3.new(0, 4, 0))
    dropItem()
    setStatus("arrived at base!", Color3.fromRGB(255, 185, 55))
    addLog("tp to base", Color3.fromRGB(255, 185, 55))
end)

btnNearestLoot.MouseButton1Click:Connect(function()
    if not humanoidRootPart then return end
    local nearest, nearestDist = nil, math.huge
    for obj, data in pairs(espLabels) do
        if data.type == "loot" and data.adornPart and data.adornPart.Parent then
            local dist = (humanoidRootPart.Position - data.adornPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = data
            end
        end
    end
    if nearest then
        setStatus("tp to nearest loot (" .. string.format("%.0f", nearestDist) .. " studs)", Color3.fromRGB(200, 100, 255))
        anchorTP(CFrame.new(nearest.adornPart.Position + Vector3.new(0, 3, 0)))
        addLog("tp to nearest loot", Color3.fromRGB(200, 100, 255))
    else
        setStatus("no loot found!", Color3.fromRGB(220, 80, 80))
    end
end)

btnNPC.MouseButton1Click:Connect(function()
    local children = NPCModels:GetChildren()
    if #children == 0 then setStatus("no npc found!", Color3.fromRGB(220, 80, 80)); return end
    local npc = children[1]
    local interactable = npc:FindFirstChild("Interactable")
    if not interactable then setStatus("npc interactable missing!", Color3.fromRGB(220, 80, 80)); return end
    setStatus("tp to npc: " .. npc.Name, Color3.fromRGB(255, 126, 179))
    anchorTP(CFrame.new(interactable.Position + Vector3.new(0, 3, 0)))
    lookAt(interactable)
    task.wait(0.1)
    interactWithPart(interactable)
    setStatus("npc interact done!", Color3.fromRGB(255, 126, 179))
    addLog("interacted with npc: " .. npc.Name, Color3.fromRGB(255, 126, 179))
end)

btnReset.MouseButton1Click:Connect(function()
    totalCollected = 0
    totalOpened = 0
    totalSkipped = 0
    sessionStart = tick()
    updateCounter()
    setStatus("counter reset", Color3.fromRGB(95, 108, 102))
    addLog("counter reset", Color3.fromRGB(95, 108, 102))
end)

forceDropBtn.MouseButton1Click:Connect(function()
    dropItem()
    setStatus("force drop triggered", Color3.fromRGB(200, 100, 0))
    addLog("force drop triggered", Color3.fromRGB(200, 100, 0))
end)

btnDiscord.MouseButton1Click:Connect(function()
    setStatus("discord.gg/HB9gqZGMnT", Color3.fromRGB(114, 137, 218))
end)
btnWA.MouseButton1Click:Connect(function()
    setStatus("whatsapp.com/channel/0029VbCBSBOCRs1pRNYpPN0r", Color3.fromRGB(37, 211, 102))
end)
btnSaweria.MouseButton1Click:Connect(function()
    setStatus("saweria.co/sazaraaa", Color3.fromRGB(255, 185, 55))
end)

-- Update NPC button text
local function updateNPCButton()
    local children = NPCModels:GetChildren()
    local mainLbl = nil
    local subLbl = btnNPC:FindFirstChild("Sub")
    for _, v in ipairs(btnNPC:GetChildren()) do
        if v:IsA("TextLabel") and v.Font == Enum.Font.GothamBold then mainLbl = v end
    end
    if #children > 0 then
        local names = {}
        for _, npc in ipairs(children) do table.insert(names, npc.Name) end
        if mainLbl then mainLbl.Text = "NPC: " .. table.concat(names, ", ") end
        if subLbl then subLbl.Text = "// " .. #children .. " npc active"; subLbl.TextColor3 = Color3.fromRGB(255, 126, 179) end
        badgeNPC.Text = "ON"
        badgeNPC.TextColor3 = Color3.fromRGB(255, 126, 179)
        badgeNPC.BackgroundColor3 = Color3.fromRGB(40, 15, 25)
    else
        if mainLbl then mainLbl.Text = "NPC: NONE" end
        if subLbl then subLbl.Text = "// no active npc found"; subLbl.TextColor3 = Color3.fromRGB(95, 108, 102) end
        badgeNPC.Text = "OFF"
        badgeNPC.TextColor3 = Color3.fromRGB(95, 108, 102)
        badgeNPC.BackgroundColor3 = Color3.fromRGB(28, 32, 36)
    end
end

updateNPCButton()
NPCModels.ChildAdded:Connect(function() task.wait(0.2); updateNPCButton() end)
NPCModels.ChildRemoved:Connect(function() task.wait(0.2); updateNPCButton() end)

-- Log watcher
local lastLogCount = 0
RunService.Heartbeat:Connect(function()
    if #logEntries > lastLogCount then
        for i = lastLogCount + 1, #logEntries do
            renderLog(logEntries[i])
        end
        lastLogCount = #logEntries
    end
end)

-- ENTRANCE
switchTab("farm")
TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0, 16 * scaleFactor, 0.5, -FULL_H / 2)
}):Play()

addLog("Victoria Script loaded!", Color3.fromRGB(52, 199, 109))
print("Victoria Script loaded!")
