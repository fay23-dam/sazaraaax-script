local VictoriaUI = {}
VictoriaUI.__index = VictoriaUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local UI_NAME = "VictoriaUI_Fantasy"
local FONT = Enum.Font.Fantasy

-- ==========================
-- THEMES & ICONS
-- ==========================
VictoriaUI.Themes = {
    Cyan = { 
        Accent1 = Color3.fromRGB(0, 210, 255), 
        Accent2 = Color3.fromRGB(255, 105, 180), -- Pink
        Bg = Color3.fromRGB(15, 15, 20), 
        Card = Color3.fromRGB(24, 24, 30), 
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(120, 120, 130)
    }
}

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
    local Author = Settings.Author or "sazaraaax & dhanzy"
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

    local function SaveCurrentConfig()
        if UseConfig then SaveConfig(ConfigFolder, ConfigData) end
    end

    -- ==========================
    -- OVERLAY (INTRO)
    -- ==========================
    local Overlay = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, ZIndex = 999 })
    Overlay.Parent = gui

    local IntroCard = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 160),
        Position = UDim2.new(0.5, -160, 0.5, -80),
        BackgroundColor3 = Theme.Bg,
        ZIndex = 1000
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", { Color = Theme.Accent1, Thickness = 2 })
    })
    IntroCard.Parent = Overlay

    local TitleFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), ZIndex = 1000 })
    TitleFrame.Parent = IntroCard
    
    Create("TextLabel", { Size = UDim2.new(0, 25, 1, 0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = "~", TextColor3 = Theme.Accent2, Font = FONT, TextSize = 22 }).Parent = TitleFrame
    Create("TextLabel", { Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(0, 25, 0, 0), BackgroundTransparency = 1, Text = "VICTORIA ", TextColor3 = Theme.Accent1, Font = FONT, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left }).Parent = TitleFrame
    Create("TextLabel", { Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(0, 110, 0, 0), BackgroundTransparency = 1, Text = "SCRIPT", TextColor3 = Theme.Accent2, Font = FONT, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left }).Parent = TitleFrame

    Create("TextLabel", { Size = UDim2.new(1, -30, 0, 15), Position = UDim2.new(0, 15, 0, 45), BackgroundTransparency = 1, Text = "// BY " .. string.upper(Author), TextColor3 = Theme.SubText, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1000 }).Parent = IntroCard

    local BtnFrame = Create("Frame", { Size = UDim2.new(1, -30, 0, 35), Position = UDim2.new(0, 15, 0, 75), BackgroundTransparency = 1, ZIndex = 1000 })
    BtnFrame.Parent = IntroCard
    local DiscordBtn = Create("TextButton", { Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 45), Text = "💬 DISCORD", TextColor3 = Color3.fromRGB(150, 150, 255), Font = FONT, TextSize = 14 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Color3.fromRGB(100, 100, 200), Thickness = 1 }) })
    DiscordBtn.Parent = BtnFrame
    local WaBtn = Create("TextButton", { Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), BackgroundColor3 = Color3.fromRGB(20, 40, 20), Text = "📱 WHATSAPP", TextColor3 = Color3.fromRGB(100, 255, 100), Font = FONT, TextSize = 14 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Color3.fromRGB(50, 200, 50), Thickness = 1 }) })
    WaBtn.Parent = BtnFrame

    local LoadingBg = Create("Frame", { Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 130), BackgroundColor3 = Color3.fromRGB(30, 30, 30), ZIndex = 1000 }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    LoadingBg.Parent = IntroCard
    local LoadingFill = Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent2, ZIndex = 1000 }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIGradient", { Color = ColorSequence.new(Theme.Accent2, Theme.Accent1) })
    })
    LoadingFill.Parent = LoadingBg
    local LoadingText = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 0, 140), BackgroundTransparency = 1, Text = "LOADING MODULES...", TextColor3 = Theme.SubText, Font = FONT, TextSize = 12, ZIndex = 1000 })
    LoadingText.Parent = IntroCard

    DiscordBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard("https://discord.gg/victoria") end end)
    WaBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard("https://wa.me/") end end)

    -- ==========================
    -- MAIN UI
    -- ==========================
    local MainFrame = Create("Frame", {
        Name = "Main", Size = UDim2.new(0, 320, 0, 500), Position = UDim2.new(0.5, -160, 0.5, -250),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true, Visible = false
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Create("UIStroke", { Color = Theme.Accent1, Thickness = 1 })
    })
    MainFrame.Parent = gui

    -- Header
    local Header = Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1 })
    Header.Parent = MainFrame

    local TitleFrame2 = Create("Frame", { Size = UDim2.new(0, 200, 0, 20), BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 10) })
    TitleFrame2.Parent = Header
    Create("TextLabel", { Size = UDim2.new(0, 20, 1, 0), BackgroundTransparency = 1, Text = "~", TextColor3 = Theme.Accent2, Font = FONT, TextSize = 18 }).Parent = TitleFrame2
    Create("TextLabel", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Text = "VICTORIA ", TextColor3 = Theme.Accent1, Font = FONT, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left }).Parent = TitleFrame2
    Create("TextLabel", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 90, 0, 0), BackgroundTransparency = 1, Text = "SCRIPT", TextColor3 = Theme.Accent2, Font = FONT, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left }).Parent = TitleFrame2

    Create("TextLabel", { Size = UDim2.new(0, 200, 0, 15), Position = UDim2.new(0, 10, 0, 30), BackgroundTransparency = 1, Text = "// BY " .. string.upper(Author), TextColor3 = Theme.SubText, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Header

    -- Controls
    local MinimizeBtn = Create("TextButton", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -66, 0, 12), BackgroundColor3 = Theme.Bg, Text = "-", TextColor3 = Theme.Accent1, Font = FONT, TextSize = 20 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Theme.Accent1, Thickness = 1 }) })
    MinimizeBtn.Parent = Header
    local CloseBtn = Create("TextButton", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 12), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "X", TextColor3 = Color3.fromRGB(255, 255, 255), Font = FONT, TextSize = 16 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    CloseBtn.Parent = Header

    -- Top Tabs Container
    local TabContainer = Create("ScrollingFrame", { Size = UDim2.new(1, -20, 0, 35), Position = UDim2.new(0, 10, 0, 55), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(2, 0, 0, 0) }, {
        Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5) })
    })
    TabContainer.Parent = MainFrame

    -- Content Area
    local ContentArea = Create("Frame", { Size = UDim2.new(1, -20, 1, -100), Position = UDim2.new(0, 10, 0, 95), BackgroundTransparency = 1 })
    ContentArea.Parent = MainFrame

    -- Floating Icon (Mobile/Minimize Fix)
    local FloatingBtn = Create("TextButton", { Size = UDim2.new(0, 45, 0, 45), Position = UDim2.new(0, 10, 0.5, -20), BackgroundColor3 = Theme.Card, Text = "V", TextColor3 = Theme.Accent2, Font = FONT, TextSize = 26, Visible = false }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Theme.Accent1, Thickness = 2 })
    })
    FloatingBtn.Parent = gui

    -- Dragging Logic
    local dragging, dragStart, dragPos
    Header.InputBegan:Connect(function(input)
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

    local fDrag, fStart, fPos
    FloatingBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fDrag = true; fStart = i.Position; fPos = FloatingBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if fDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - fStart; FloatingBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fDrag = false end end)
    
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatingBtn.Visible = true end)
    FloatingBtn.MouseButton1Click:Connect(function() if not fDrag then FloatingBtn.Visible = false; MainFrame.Visible = true end end)
    CloseBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    local WindowObj = { Tabs = {}, CurrentTab = nil, GUI = gui }
    function WindowObj:Destroy() gui:Destroy() end

    -- ==========================
    -- BOOT LOGIC
    -- ==========================
    local function BootUI()
        MakeTween(LoadingFill, {1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, { Size = UDim2.new(1, 0, 1, 0) })
        task.wait(1.5)
        LoadingText.Text = "READY!"
        task.wait(0.5)
        MakeTween(Overlay, {0.5}, { BackgroundTransparency = 1 })
        MakeTween(IntroCard, {0.5}, { BackgroundTransparency = 1 })
        for _, v in ipairs(IntroCard:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                MakeTween(v, {0.5}, { TextTransparency = 1, BackgroundTransparency = 1 })
                if v:FindFirstChildOfClass("UIStroke") then MakeTween(v:FindFirstChildOfClass("UIStroke"), {0.5}, { Transparency = 1 }) end
            elseif v:IsA("Frame") then
                MakeTween(v, {0.5}, { BackgroundTransparency = 1 })
            elseif v:IsA("UIStroke") then
                MakeTween(v, {0.5}, { Transparency = 1 })
            end
        end
        task.wait(0.5)
        Overlay.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        MakeTween(MainFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, { Size = UDim2.new(0, 320, 0, 500), Position = UDim2.new(0.5, -160, 0.5, -250) })
    end

    task.spawn(BootUI)

    -- ==========================
    -- TAB SYSTEM
    -- ==========================
    function WindowObj:MakeTab(Config)
        local TabName = type(Config) == "table" and Config.Name or Config

        local TabBtn = Create("TextButton", { Size = UDim2.new(0, 100, 1, 0), BackgroundColor3 = Theme.Bg, Text = string.upper(TabName), TextColor3 = Theme.SubText, Font = FONT, TextSize = 14 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Theme.Card, Thickness = 1 }) })
        TabBtn.Parent = TabContainer

        local TabContent = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent1, Visible = false }, {
            Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", { PaddingRight = UDim.new(0, 4) })
        })
        TabContent.Parent = ContentArea

        local TabObj = { Name = TabName, Button = TabBtn, Container = TabContent, Items = {} }

        TabBtn.MouseButton1Click:Connect(function()
            if WindowObj.CurrentTab then
                MakeTween(WindowObj.CurrentTab.Button, {0.2}, { BackgroundColor3 = Theme.Bg, TextColor3 = Theme.SubText })
                WindowObj.CurrentTab.Button:FindFirstChildOfClass("UIStroke").Color = Theme.Card
                WindowObj.CurrentTab.Container.Visible = false
            end
            MakeTween(TabBtn, {0.2}, { BackgroundColor3 = Theme.Card, TextColor3 = Theme.Text })
            TabBtn:FindFirstChildOfClass("UIStroke").Color = Theme.Accent1
            TabContent.Visible = true
            WindowObj.CurrentTab = TabObj
        end)

        if not WindowObj.CurrentTab then
            TabBtn.BackgroundColor3 = Theme.Card; TabBtn.TextColor3 = Theme.Text
            TabBtn:FindFirstChildOfClass("UIStroke").Color = Theme.Accent1
            TabContent.Visible = true; WindowObj.CurrentTab = TabObj
        end

        local function BuildElements(ParentFrame)
            local Elements = {}
            local function MakeCard(h)
                local c = Create("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Theme.Card }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }), Create("UIStroke", { Color = Color3.fromRGB(35, 35, 45), Thickness = 1 }) })
                table.insert(TabObj.Items, c)
                return c
            end

            function Elements:AddSearch()
                local Card = MakeCard(36)
                local Box = Create("TextBox", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, PlaceholderText = "Search...", Text = "", Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
                Box.Parent = Card; Card.Parent = ParentFrame
                Box.Changed:Connect(function(prop)
                    if prop == "Text" then
                        local q = string.lower(Box.Text)
                        for _, item in ipairs(TabObj.Items) do
                            if item ~= Card then
                                local lbl = item:FindFirstChildOfClass("TextLabel") or item:FindFirstChildOfClass("TextButton")
                                if lbl and lbl.Text then item.Visible = q == "" or string.find(string.lower(lbl.Text), q) ~= nil end
                            end
                        end
                    end
                end)
            end

            function Elements:AddSubTab(Config)
                local Card = MakeCard(36)
                local SubContainer = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = false }, { Create("UIListLayout", { Padding = UDim.new(0, 5) }) })
                local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "📂 " .. string.upper(Config.Name), TextColor3 = Theme.Accent1, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
                Btn.Parent = Card; Card.Parent = ParentFrame
                Create("UIPadding", { PaddingLeft = UDim.new(0, 10) }).Parent = Btn
                SubContainer.Parent = ParentFrame
                local open = false
                Btn.MouseButton1Click:Connect(function()
                    open = not open; SubContainer.Visible = open
                    Btn.Text = (open and "📂 " or "📁 ") .. string.upper(Config.Name)
                    MakeTween(Card, {0.2}, { BackgroundColor3 = open and Color3.fromRGB(35, 35, 45) or Theme.Card })
                end)
                return BuildElements(SubContainer)
            end

            function Elements:AddSection(Title)
                local s = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "// " .. string.upper(Title), TextColor3 = Theme.SubText, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
                s.Parent = ParentFrame
                table.insert(TabObj.Items, s)
            end

            function Elements:AddButton(Config)
                local Card = MakeCard(38)
                local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Accent2, Font = FONT, TextSize = 16 })
                Btn.Parent = Card; Card.Parent = ParentFrame
                Btn.MouseButton1Click:Connect(function()
                    MakeTween(Card, {0.1}, { BackgroundColor3 = Color3.fromRGB(45, 45, 55) }); task.wait(0.1); MakeTween(Card, {0.1}, { BackgroundColor3 = Theme.Card })
                    if Config.Callback then Config.Callback() end
                end)
            end

            function Elements:AddToggle(Config)
                local Card = MakeCard(44)
                local Flag = Config.Flag or Config.Name
                local State = Config.Default or false
                if ConfigData[Flag] ~= nil then State = ConfigData[Flag] end

                Create("Frame", { Size = UDim2.new(0, 2, 0, 20), Position = UDim2.new(0, 10, 0.5, -10), BackgroundColor3 = Theme.Accent1 }).Parent = Card
                Create("TextLabel", { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 18, 0, 4), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                Create("TextLabel", { Size = UDim2.new(1, -80, 0, 15), Position = UDim2.new(0, 18, 0, 24), BackgroundTransparency = 1, Text = "// TOGGLE SETTING", TextColor3 = Theme.SubText, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card

                local ToggleBtn = Create("TextButton", { Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -54, 0.5, -12), BackgroundColor3 = Theme.Bg, Text = State and "ON" or "OFF", TextColor3 = State and Theme.Accent1 or Theme.SubText, Font = FONT, TextSize = 14 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
                ToggleBtn.Parent = Card
                
                local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }); Btn.Parent = Card
                Card.Parent = ParentFrame

                local function Fire(val)
                    State = val
                    ToggleBtn.Text = State and "ON" or "OFF"
                    ToggleBtn.TextColor3 = State and Theme.Accent1 or Theme.SubText
                    if Config.Save then ConfigData[Flag] = State; SaveCurrentConfig() end
                    if Config.Callback then Config.Callback(State) end
                end
                Btn.MouseButton1Click:Connect(function() Fire(not State) end)
                if State then Fire(State) end
            end

            function Elements:AddDropdown(Config)
                local Card = MakeCard(44)
                Card.ClipsDescendants = true
                local Flag = Config.Flag or Config.Name
                local Selected = Config.Default or "SELECT..."
                if ConfigData[Flag] ~= nil then Selected = ConfigData[Flag] end

                Create("Frame", { Size = UDim2.new(0, 2, 0, 20), Position = UDim2.new(0, 10, 0, 12), BackgroundColor3 = Theme.Accent2 }).Parent = Card
                Create("TextLabel", { Size = UDim2.new(0, 150, 0, 44), Position = UDim2.new(0, 18, 0, 0), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                
                local ValBtn = Create("TextButton", { Size = UDim2.new(0, 100, 0, 28), Position = UDim2.new(1, -110, 0, 8), BackgroundColor3 = Theme.Bg, TextColor3 = Theme.Accent2, Text = string.upper(Selected), Font = FONT, TextSize = 12 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
                ValBtn.Parent = Card; Card.Parent = ParentFrame

                local DropContainer = Create("ScrollingFrame", { Size = UDim2.new(1, -20, 0, 100), Position = UDim2.new(0, 10, 0, 50), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent1 }, { Create("UIListLayout", { Padding = UDim.new(0, 2) }) })
                DropContainer.Parent = Card

                local open = false
                ValBtn.MouseButton1Click:Connect(function()
                    open = not open; MakeTween(Card, {0.2}, { Size = UDim2.new(1, 0, 0, open and 160 or 44) })
                end)

                for _, opt in ipairs(Config.Options) do
                    local optBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = string.upper(opt), TextColor3 = Theme.Text, Font = FONT, TextSize = 12 })
                    optBtn.Parent = DropContainer
                    optBtn.MouseButton1Click:Connect(function()
                        Selected = opt; ValBtn.Text = string.upper(opt); open = false
                        MakeTween(Card, {0.2}, { Size = UDim2.new(1, 0, 0, 44) })
                        if Config.Save then ConfigData[Flag] = Selected; SaveCurrentConfig() end
                        if Config.Callback then Config.Callback(opt) end
                    end)
                end
            end

            function Elements:AddSlider(Config)
                local Card = MakeCard(54)
                local Flag = Config.Flag or Config.Name
                local State = Config.Default or Config.Min
                if ConfigData[Flag] ~= nil then State = ConfigData[Flag] end

                Create("Frame", { Size = UDim2.new(0, 2, 0, 20), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Theme.Accent1 }).Parent = Card
                Create("TextLabel", { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 18, 0, 6), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
                local ValLbl = Create("TextLabel", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, 6), BackgroundTransparency = 1, Text = tostring(State), TextColor3 = Theme.Accent1, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right })
                ValLbl.Parent = Card
                
                local BarBg = Create("Frame", { Size = UDim2.new(1, -20, 0, 8), Position = UDim2.new(0, 10, 0, 36), BackgroundColor3 = Theme.Bg }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                BarBg.Parent = Card
                local Fill = Create("Frame", { Size = UDim2.new((State - Config.Min)/(Config.Max - Config.Min), 0, 1, 0), BackgroundColor3 = Theme.Accent1 }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
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

            function Elements:AddParagraph(Title, Text)
                local lines = string.split(Text, "\n")
                local h = #lines * 20 + 20
                local Card = MakeCard(h)
                
                local TitleLbl = Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = "• " .. string.upper(Title), TextColor3 = Theme.SubText, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
                TitleLbl.Parent = Card
                
                local formattedText = string.upper(Text)
                if formattedText ~= "" then formattedText = "• " .. formattedText:gsub("\n", "\n• ") end
                
                local TextObj = Create("TextLabel", { Size = UDim2.new(1, -20, 1, -25), Position = UDim2.new(0, 10, 0, 25), BackgroundTransparency = 1, Text = formattedText, TextColor3 = Theme.Text, Font = FONT, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })
                TextObj.Parent = Card
                Card.Parent = ParentFrame
                
                return {
                    SetText = function(self, newText)
                        local ft = string.upper(newText)
                        if ft ~= "" then ft = "• " .. ft:gsub("\n", "\n• ") end
                        TextObj.Text = ft
                        local nlines = #string.split(newText, "\n")
                        Card.Size = UDim2.new(1, 0, 0, nlines * 20 + 20)
                    end
                }
            end

            function Elements:AddDivider() local c = Create("Frame", { Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0, 10, 0, 0), BackgroundColor3 = Theme.Card, BorderSizePixel = 0 }); c.Parent = ParentFrame; table.insert(TabObj.Items, c) end
            function Elements:AddSpace(pixels) local c = Create("Frame", { Size = UDim2.new(1, 0, 0, pixels or 10), BackgroundTransparency = 1 }); c.Parent = ParentFrame; table.insert(TabObj.Items, c) end

            return Elements
        end

        return BuildElements(TabContent)
    end

    return WindowObj
end

return VictoriaUI
