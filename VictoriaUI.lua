local VictoriaUI = {}
VictoriaUI.__index = VictoriaUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local UI_NAME = "VictoriaUI_Pro"

-- ==========================
-- THEMES & ICONS
-- ==========================
VictoriaUI.Themes = {
    Cyan = { Accent = Color3.fromRGB(0, 210, 255), Bg = Color3.fromRGB(15, 15, 20), Card = Color3.fromRGB(24, 24, 30), Text = Color3.fromRGB(255, 255, 255) },
    Sakura = { Accent = Color3.fromRGB(255, 105, 180), Bg = Color3.fromRGB(20, 15, 18), Card = Color3.fromRGB(30, 24, 28), Text = Color3.fromRGB(255, 240, 245) },
    Blood = { Accent = Color3.fromRGB(220, 20, 60), Bg = Color3.fromRGB(15, 10, 10), Card = Color3.fromRGB(25, 15, 15), Text = Color3.fromRGB(255, 200, 200) },
    Matrix = { Accent = Color3.fromRGB(0, 255, 65), Bg = Color3.fromRGB(10, 15, 10), Card = Color3.fromRGB(15, 25, 15), Text = Color3.fromRGB(200, 255, 200) }
}

-- Built-in popular Lucide Icons for convenience
local Lucide = {
    Home = "rbxassetid://3926305904",
    Settings = "rbxassetid://3926307971",
    User = "rbxassetid://3926305904",
    Search = "rbxassetid://3926305904",
    Code = "rbxassetid://3926305904",
    Gamepad = "rbxassetid://3926305904",
    Sword = "rbxassetid://3926305904",
    Shield = "rbxassetid://3926305904",
    Star = "rbxassetid://3926305904",
    Folder = "rbxassetid://3926305904"
}
local function GetIcon(icon)
    if not icon then return "" end
    if string.find(icon, "rbxassetid://") then return icon end
    return Lucide[icon] or ""
end

-- ==========================
-- UTILS & CONFIG
-- ==========================
local function MakeTween(instance, info, properties)
    local tween = TweenService:Create(instance, TweenInfo.new(unpack(info)), properties)
    tween:Play(); return tween
end

local function Create(className, properties, children)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do instance[k] = v end
    for _, child in ipairs(children or {}) do child.Parent = instance end
    return instance
end

local function LoadConfig(folderName)
    if isfolder and readfile and isfolder(folderName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(folderName .. "/config.json")) end)
        if success and type(data) == "table" then return data end
    end
    return {}
end

local function SaveConfig(folderName, data)
    if makefolder and writefile then
        if not isfolder(folderName) then makefolder(folderName) end
        pcall(function() writefile(folderName .. "/config.json", HttpService:JSONEncode(data)) end)
    end
end

-- ==========================
-- MAIN WINDOW
-- ==========================
function VictoriaUI:MakeWindow(Settings)
    Settings = Settings or {}
    local WindowName = Settings.Name or "Victoria Script"
    local Author = Settings.Author or "by sazaraaax & dhanzy"
    local ThemeName = Settings.Theme or "Cyan"
    local Theme = VictoriaUI.Themes[ThemeName] or VictoriaUI.Themes.Cyan
    local UseConfig = Settings.SaveConfig or false
    local ConfigFolder = Settings.ConfigFolder or "VictoriaConfig"
    local ToggleKey = Settings.ToggleKey or Enum.KeyCode.RightControl
    
    local gui = Create("ScreenGui", { Name = UI_NAME, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    
    local ok = pcall(function()
        local target = (gethui and gethui()) or game:GetService("CoreGui")
        gui.Parent = target
    end)
    
    if not ok or gui.Parent == nil then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local ConfigData = UseConfig and LoadConfig(ConfigFolder) or {}
    local ActiveToggles = {}

    local function SaveCurrentConfig()
        if UseConfig then SaveConfig(ConfigFolder, ConfigData) end
    end

    -- ==========================
    -- OVERLAY (INTRO & KEY SYSTEM)
    -- ==========================
    local Overlay = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, ZIndex = 999 })
    Overlay.Parent = gui

    local IntroText = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0.5, -30), BackgroundTransparency = 1, Text = "Injecting " .. WindowName .. "...", TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 16, ZIndex = 1000 })
    IntroText.Parent = Overlay

    local LoadingBg = Create("Frame", { Size = UDim2.new(0, 200, 0, 4), Position = UDim2.new(0.5, -100, 0.5, 10), BackgroundColor3 = Color3.fromRGB(30, 30, 30), ZIndex = 1000 }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    LoadingBg.Parent = Overlay
    local LoadingFill = Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, ZIndex = 1000 }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    LoadingFill.Parent = LoadingBg

    -- ==========================
    -- MAIN UI
    -- ==========================
    local MainFrame = Create("Frame", {
        Name = "Main", Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true, Visible = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = Color3.fromRGB(40, 45, 55), Thickness = 1 })
    })
    MainFrame.Parent = gui

    -- Global Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    -- Watermark
    if Settings.Watermark then
        local WMFrame = Create("Frame", { Size = UDim2.new(0, 0, 0, 24), Position = UDim2.new(0.5, 0, 0, 10), BackgroundColor3 = Theme.Card, AutomaticSize = Enum.AutomaticSize.X, ClipsDescendants = true }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Theme.Accent, Thickness = 1 }) })
        WMFrame.Parent = gui
        local WMLabel = Create("TextLabel", { Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Text = "Victoria Script", TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 12 })
        WMLabel.Parent = WMFrame
        Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }).Parent = WMFrame
        task.spawn(function()
            local RS = game:GetService("RunService")
            while task.wait(1) do
                local fps = math.floor(1 / RS.RenderStepped:Wait())
                WMLabel.Text = (Settings.WatermarkName or WindowName) .. " | FPS: " .. tostring(fps) .. " | " .. os.date("%H:%M:%S")
            end
        end)
    end

    -- Dragging
    local dragging, dragStart, dragPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; dragPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- Resizing
    local ResizeGrip = Create("TextButton", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, Text = "↘", TextColor3 = Color3.fromRGB(100, 100, 110), TextSize = 12, ZIndex = 10 })
    ResizeGrip.Parent = MainFrame
    local resizing, rStart, rStartSize
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; rStart = input.Position; rStartSize = MainFrame.AbsoluteSize
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - rStart
            local newWidth = math.clamp(rStartSize.X + delta.X, 400, 1000)
            local newHeight = math.clamp(rStartSize.Y + delta.Y, 250, 800)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)

    -- Sidebar
    local Sidebar = Create("Frame", { Size = UDim2.new(0, 160, 1, 0), BackgroundColor3 = Theme.Card, BorderSizePixel = 0 }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("Frame", { Size = UDim2.new(0, 8, 1, 0), Position = UDim2.new(1, -8, 0, 0), BackgroundColor3 = Theme.Card, BorderSizePixel = 0 }),
        Create("UIStroke", { Color = Color3.fromRGB(35, 40, 50), Thickness = 1 })
    })
    Sidebar.Parent = MainFrame

    Create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 15), BackgroundTransparency = 1, Text = WindowName, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Sidebar
    Create("TextLabel", { Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 35), BackgroundTransparency = 1, Text = Author, TextColor3 = Theme.Accent, Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Sidebar

    local TabContainer = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -80), Position = UDim2.new(0, 0, 0, 65), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0 }, {
        Create("UIListLayout", { Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center })
    })
    TabContainer.Parent = Sidebar

    -- Controls (Close / Minimize)
    local MinimizeBtn = Create("TextButton", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -55, 0, 10), BackgroundColor3 = Theme.Card, Text = "-", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14 }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
    MinimizeBtn.Parent = MainFrame
    local CloseBtn = Create("TextButton", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0, 10), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "X", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 12 }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
    CloseBtn.Parent = MainFrame

    local ContentArea = Create("Frame", { Size = UDim2.new(1, -160, 1, 0), Position = UDim2.new(0, 160, 0, 0), BackgroundTransparency = 1 })
    ContentArea.Parent = MainFrame

    -- Floating Icon (Mobile)
    local FloatingBtn = Create("ImageButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20), BackgroundColor3 = Theme.Card, Visible = false }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Theme.Accent, Thickness = 2 })
    })
    FloatingBtn.Parent = gui
    local fDrag, fStart, fPos
    FloatingBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fDrag = true; fStart = i.Position; fPos = FloatingBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if fDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - fStart; FloatingBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fDrag = false end end)
    
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatingBtn.Visible = true end)
    FloatingBtn.MouseButton1Click:Connect(function() if not fDrag then FloatingBtn.Visible = false; MainFrame.Visible = true end end)
    CloseBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local WindowObj = { Tabs = {}, CurrentTab = nil, GUI = gui }
    function WindowObj:Destroy() gui:Destroy() end

    -- ==========================
    -- BOOT LOGIC
    -- ==========================
    local function BootUI()
        MakeTween(LoadingFill, {1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, { Size = UDim2.new(1, 0, 1, 0) })
        task.wait(1.5)
        IntroText.Text = "Welcome!"
        task.wait(0.5)
        MakeTween(Overlay, {0.5}, { BackgroundTransparency = 1 })
        MakeTween(IntroText, {0.5}, { TextTransparency = 1 })
        MakeTween(LoadingBg, {0.5}, { BackgroundTransparency = 1 })
        MakeTween(LoadingFill, {0.5}, { BackgroundTransparency = 1 })
        task.wait(0.5)
        Overlay.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MakeTween(MainFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, { Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200) })
    end

    if Settings.KeySystem then
        IntroText.Text = "Waiting for Key..."
        LoadingBg.Visible = false
        local KeyBox = Create("TextBox", { Size = UDim2.new(0, 200, 0, 30), Position = UDim2.new(0.5, -100, 0.5, 0), BackgroundColor3 = Theme.Card, TextColor3 = Theme.Text, PlaceholderText = "Enter Key Here", Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 1000 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
        KeyBox.Parent = Overlay
        local CheckBtn = Create("TextButton", { Size = UDim2.new(0, 200, 0, 30), Position = UDim2.new(0.5, -100, 0.5, 40), BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(0,0,0), Text = "Verify", Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 1000 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
        CheckBtn.Parent = Overlay

        CheckBtn.MouseButton1Click:Connect(function()
            if KeyBox.Text == Settings.KeySettings.Key then
                CheckBtn.Text = "Success!"
                task.wait(0.5)
                KeyBox:Destroy(); CheckBtn:Destroy()
                LoadingBg.Visible = true
                BootUI()
            else
                CheckBtn.Text = "Invalid Key"
                MakeTween(CheckBtn, {0.3}, { BackgroundColor3 = Color3.fromRGB(220, 50, 50) })
                task.wait(1)
                CheckBtn.Text = "Verify"
                MakeTween(CheckBtn, {0.3}, { BackgroundColor3 = Theme.Accent })
            end
        end)
    else
        task.spawn(BootUI)
    end

    -- ==========================
    -- TAB SYSTEM
    -- ==========================
    function WindowObj:MakeTab(Config)
        local TabName = type(Config) == "table" and Config.Name or Config
        local TabIcon = type(Config) == "table" and GetIcon(Config.Icon) or ""

        local TabBtn = Create("TextButton", { Size = UDim2.new(0, 140, 0, 32), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
        TabBtn.Parent = TabContainer

        local IconImg = Create("ImageLabel", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 10, 0.5, -8), BackgroundTransparency = 1, Image = TabIcon, ImageColor3 = Color3.fromRGB(130, 130, 140) })
        if TabIcon ~= "" then IconImg.Parent = TabBtn end
        local TitleLbl = Create("TextLabel", { Size = UDim2.new(1, -35, 1, 0), Position = UDim2.new(0, TabIcon ~= "" and 35 or 10, 0, 0), BackgroundTransparency = 1, Text = TabName, TextColor3 = Color3.fromRGB(130, 130, 140), Font = Enum.Font.GothamSemibold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
        TitleLbl.Parent = TabBtn

        local TabContent = Create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, Visible = false }, {
            Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", { PaddingRight = UDim.new(0, 6) })
        })
        TabContent.Parent = ContentArea

        local TabObj = { Name = TabName, Button = TabBtn, Container = TabContent, Items = {} }

        TabBtn.MouseButton1Click:Connect(function()
            if WindowObj.CurrentTab then
                MakeTween(WindowObj.CurrentTab.Button, {0.2}, { BackgroundTransparency = 1 })
                MakeTween(WindowObj.CurrentTab.Button:FindFirstChild("TextLabel"), {0.2}, { TextColor3 = Color3.fromRGB(130, 130, 140) })
                if WindowObj.CurrentTab.Button:FindFirstChild("ImageLabel") then MakeTween(WindowObj.CurrentTab.Button:FindFirstChild("ImageLabel"), {0.2}, { ImageColor3 = Color3.fromRGB(130, 130, 140) }) end
                WindowObj.CurrentTab.Container.Visible = false
            end
            MakeTween(TabBtn, {0.2}, { BackgroundTransparency = 0 })
            MakeTween(TitleLbl, {0.2}, { TextColor3 = Theme.Text })
            if IconImg.Parent then MakeTween(IconImg, {0.2}, { ImageColor3 = Theme.Text }) end
            TabContent.Visible = true
            WindowObj.CurrentTab = TabObj
        end)

        if not WindowObj.CurrentTab then
            TabBtn.BackgroundTransparency = 0; TitleLbl.TextColor3 = Theme.Text
            if IconImg.Parent then IconImg.ImageColor3 = Theme.Text end
            TabContent.Visible = true; WindowObj.CurrentTab = TabObj
        end

        local function BuildElements(ParentFrame)
            local Elements = {}
            local function MakeCard(h)
                local c = Create("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Theme.Card }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
                table.insert(TabObj.Items, c)
                return c
            end

            function Elements:AddSearch()
                local Card = MakeCard(36)
                local Box = Create("TextBox", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, PlaceholderText = "Search...", Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
                Box.Parent = Card; Card.Parent = ParentFrame
                Box.Changed:Connect(function(prop)
                    if prop == "Text" then
                        local q = string.lower(Box.Text)
                        for _, item in ipairs(TabObj.Items) do
                            if item ~= Card then
                                local lbl = item:FindFirstChildOfClass("TextLabel") or item:FindFirstChildOfClass("TextButton")
                                if lbl and lbl.Text then
                                    item.Visible = q == "" or string.find(string.lower(lbl.Text), q) ~= nil
                                end
                            end
                        end
                    end
                end)
            end

            function Elements:AddSubTab(Config)
                local Card = MakeCard(36)
                local SubContainer = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = false }, { Create("UIListLayout", { Padding = UDim.new(0, 5) }) })
                
                local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "📂 " .. Config.Name, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                Btn.Parent = Card; Card.Parent = ParentFrame
                Create("UIPadding", { PaddingLeft = UDim.new(0, 10) }).Parent = Btn
                SubContainer.Parent = ParentFrame
                
                local open = false
                Btn.MouseButton1Click:Connect(function()
                    open = not open
                    SubContainer.Visible = open
                    Btn.Text = (open and "📂 " or "📁 ") .. Config.Name
                    MakeTween(Card, {0.2}, { BackgroundColor3 = open and Color3.fromRGB(45, 45, 55) or Theme.Card })
                end)
                
                return BuildElements(SubContainer)
            end

            function Elements:AddSection(Title)
                local s = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                s.Parent = ParentFrame
                table.insert(TabObj.Items, s)
            end

            function Elements:AddButton(Config)
                local Card = MakeCard(36)
                local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = Config.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13 })
                Btn.Parent = Card; Card.Parent = ParentFrame
                Btn.MouseButton1Click:Connect(function()
                    MakeTween(Card, {0.1}, { BackgroundColor3 = Color3.fromRGB(45, 45, 55) })
                    task.wait(0.1)
                    MakeTween(Card, {0.1}, { BackgroundColor3 = Theme.Card })
                    if Config.Callback then Config.Callback() end
                end)
            end

            function Elements:AddToggle(Config)
                local Card = MakeCard(36)
                local Flag = Config.Flag or Config.Name
                Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = Config.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                
                local State = Config.Default or false
                if ConfigData[Flag] ~= nil then State = ConfigData[Flag] end

                local Box = Create("Frame", { Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = State and Theme.Accent or Color3.fromRGB(40, 40, 50) }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                Box.Parent = Card
                local Dot = Create("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, State and 20 or 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255) }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                Dot.Parent = Box
                local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }); Btn.Parent = Card
                Card.Parent = ParentFrame

                local function Fire(val)
                    State = val
                    MakeTween(Box, {0.2}, { BackgroundColor3 = State and Theme.Accent or Color3.fromRGB(40, 40, 50) })
                    MakeTween(Dot, {0.2}, { Position = UDim2.new(0, State and 20 or 2, 0.5, -7) })
                    if Config.Save then ConfigData[Flag] = State; SaveCurrentConfig() end
                    if Config.Callback then Config.Callback(State) end
                end
                Btn.MouseButton1Click:Connect(function() Fire(not State) end)
                if State then Fire(State) end
            end

            function Elements:AddDropdown(Config)
                local Card = MakeCard(36)
                Card.ClipsDescendants = true
                local Flag = Config.Flag or Config.Name
                local Selected = Config.Default or "Select..."
                if ConfigData[Flag] ~= nil then Selected = ConfigData[Flag] end

                Create("TextLabel", { Size = UDim2.new(0, 150, 0, 36), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = Config.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                local ValBtn = Create("TextButton", { Size = UDim2.new(0, 150, 0, 24), Position = UDim2.new(1, -160, 0, 6), BackgroundColor3 = Theme.Bg, TextColor3 = Theme.Accent, Text = Selected, Font = Enum.Font.Gotham, TextSize = 12 }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
                ValBtn.Parent = Card; Card.Parent = ParentFrame

                local DropContainer = Create("ScrollingFrame", { Size = UDim2.new(1, -20, 0, 100), Position = UDim2.new(0, 10, 0, 40), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent }, { Create("UIListLayout", { Padding = UDim.new(0, 2) }) })
                DropContainer.Parent = Card

                local open = false
                ValBtn.MouseButton1Click:Connect(function()
                    open = not open
                    MakeTween(Card, {0.2}, { Size = UDim2.new(1, 0, 0, open and 150 or 36) })
                end)

                for _, opt in ipairs(Config.Options) do
                    local optBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = opt, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12 })
                    optBtn.Parent = DropContainer
                    optBtn.MouseButton1Click:Connect(function()
                        Selected = opt; ValBtn.Text = opt; open = false
                        MakeTween(Card, {0.2}, { Size = UDim2.new(1, 0, 0, 36) })
                        if Config.Save then ConfigData[Flag] = Selected; SaveCurrentConfig() end
                        if Config.Callback then Config.Callback(opt) end
                    end)
                end
            end

            function Elements:AddSlider(Config)
                local Card = MakeCard(50)
                local Flag = Config.Flag or Config.Name
                local State = Config.Default or Config.Min
                if ConfigData[Flag] ~= nil then State = ConfigData[Flag] end

                Create("TextLabel", { Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = Config.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                local ValLbl = Create("TextLabel", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, 5), BackgroundTransparency = 1, Text = tostring(State), TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right })
                ValLbl.Parent = Card
                
                local BarBg = Create("Frame", { Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 32), BackgroundColor3 = Color3.fromRGB(40, 40, 50) }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                BarBg.Parent = Card
                local Fill = Create("Frame", { Size = UDim2.new((State - Config.Min)/(Config.Max - Config.Min), 0, 1, 0), BackgroundColor3 = Theme.Accent }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                Fill.Parent = BarBg
                local DragBtn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }); DragBtn.Parent = BarBg
                Card.Parent = ParentFrame

                local dragging = false
                DragBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false; if Config.Save then ConfigData[Flag] = State; SaveCurrentConfig() end end end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local pct = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                        local val = Config.Min + ((Config.Max - Config.Min) * pct)
                        if Config.Increment then val = math.floor((val / Config.Increment) + 0.5) * Config.Increment end
                        val = math.clamp(val, Config.Min, Config.Max)
                        State = val
                        Fill.Size = UDim2.new((val - Config.Min)/(Config.Max - Config.Min), 0, 1, 0)
                        ValLbl.Text = tostring(val)
                        if Config.Callback then Config.Callback(val) end
                    end
                end)
                if State then if Config.Callback then Config.Callback(State) end end
            end

            function Elements:AddColorpicker(Config)
                local Card = MakeCard(36)
                local Flag = Config.Flag or Config.Name
                local ColorState = Config.Default or Color3.fromRGB(255,255,255)
                if ConfigData[Flag] ~= nil then ColorState = Color3.new(ConfigData[Flag].R, ConfigData[Flag].G, ConfigData[Flag].B) end

                Create("TextLabel", { Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = Config.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                local ColorBox = Create("TextButton", { Size = UDim2.new(0, 40, 0, 24), Position = UDim2.new(1, -50, 0.5, -12), BackgroundColor3 = ColorState, Text = "", BorderSizePixel = 0 }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
                ColorBox.Parent = Card; Card.Parent = ParentFrame

                -- Implement full picker in future, for now clicking randomize color
                ColorBox.MouseButton1Click:Connect(function()
                    ColorState = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                    ColorBox.BackgroundColor3 = ColorState
                    if Config.Save then ConfigData[Flag] = {R = ColorState.R, G = ColorState.G, B = ColorState.B}; SaveCurrentConfig() end
                    if Config.Callback then Config.Callback(ColorState) end
                end)
            end

            function Elements:AddInput(Config)
                local Card = MakeCard(36)
                Create("TextLabel", { Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = Config.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                local Box = Create("TextBox", { Size = UDim2.new(0, 150, 0, 24), Position = UDim2.new(1, -160, 0.5, -12), BackgroundColor3 = Theme.Bg, TextColor3 = Theme.Text, PlaceholderText = Config.Placeholder or "", Text = Config.Default or "", Font = Enum.Font.Gotham, TextSize = 12 }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
                Box.Parent = Card; Card.Parent = ParentFrame
                Box.FocusLost:Connect(function() if Config.Callback then Config.Callback(Box.Text) end end)
            end

            function Elements:AddParagraph(Title, Text)
                local Card = MakeCard(60)
                Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = Title, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                local TextObj = Create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, Text = Text, TextColor3 = Color3.fromRGB(150, 150, 160), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top })
                TextObj.Parent = Card
                Card.Parent = ParentFrame
                
                return {
                    SetText = function(self, newText)
                        TextObj.Text = newText
                    end
                }
            end

            function Elements:AddDivider() local c = Create("Frame", { Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0, 10, 0, 0), BackgroundColor3 = Color3.fromRGB(40, 45, 55), BorderSizePixel = 0 }); c.Parent = ParentFrame; table.insert(TabObj.Items, c) end
            function Elements:AddSpace(pixels) local c = Create("Frame", { Size = UDim2.new(1, 0, 0, pixels or 10), BackgroundTransparency = 1 }); c.Parent = ParentFrame; table.insert(TabObj.Items, c) end

            return Elements
        end

        return BuildElements(TabContent)
    end

    -- ==========================
    -- NOTIFICATION & DIALOG
    -- ==========================
    local NotifContainer = Create("Frame", { Size = UDim2.new(0, 250, 1, -20), Position = UDim2.new(1, -270, 0, 10), BackgroundTransparency = 1, ZIndex = 50 }, { Create("UIListLayout", { Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom }) })
    NotifContainer.Parent = gui

    function WindowObj:MakeNotification(Config)
        local Notif = Create("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Card, Position = UDim2.new(1, 50, 0, 0) }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Theme.Accent, Thickness = 1 }),
            Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = Config.Title or "Notification", TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
            Create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, Text = Config.Content or "", TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true })
        })
        Notif.Parent = NotifContainer
        MakeTween(Notif, {0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, { Position = UDim2.new(0, 0, 0, 0) })
        task.delay(Config.Time or 3, function() MakeTween(Notif, {0.3}, { Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1 }); task.wait(0.3); Notif:Destroy() end)
    end

    return WindowObj
end

return VictoriaUI
