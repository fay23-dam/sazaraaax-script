local VictoriaUI = {}
VictoriaUI.__index = VictoriaUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local UI_NAME = "VictoriaUI_Fantasy"
local FONT = Enum.Font.Fantasy

-- ==========================
-- THEMES
-- ==========================
VictoriaUI.Themes = {
    Cyan = { 
        Accent1 = Color3.fromRGB(0, 210, 255), 
        Accent2 = Color3.fromRGB(255, 105, 180), 
        Bg = Color3.fromRGB(15, 15, 20), 
        Card = Color3.fromRGB(24, 24, 30), 
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(120, 120, 130),
        Orange = Color3.fromRGB(255, 170, 0),
        Green = Color3.fromRGB(50, 255, 50),
        Red = Color3.fromRGB(255, 50, 50),
        Purple = Color3.fromRGB(180, 50, 255)
    }
}

-- ==========================
-- UTILS
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

-- ==========================
-- MAIN BUILDER
-- ==========================
function VictoriaUI:MakeWindow(Settings)
    Settings = Settings or {}
    local WindowName = Settings.Name or "Victoria Script"
    local Author = Settings.Author or "sazaraaax & dhanzy"
    local Theme = VictoriaUI.Themes.Cyan
    
    local gui = Create("ScreenGui", { Name = UI_NAME, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    
    local ok = pcall(function()
        local target = (gethui and gethui()) or game:GetService("CoreGui")
        gui.Parent = target
    end)
    if not ok or gui.Parent == nil then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Floating Icon
    local FloatingBtn = Create("TextButton", { Size = UDim2.new(0, 45, 0, 45), Position = UDim2.new(0, 10, 0.5, -20), BackgroundColor3 = Theme.Card, Text = "V", TextColor3 = Theme.Accent2, Font = FONT, TextSize = 26, Visible = false }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Theme.Accent1, Thickness = 2 })
    })
    FloatingBtn.Parent = gui

    local fDrag, fStart, fPos
    FloatingBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fDrag = true; fStart = i.Position; fPos = FloatingBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i) if fDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - fStart; FloatingBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fDrag = false end end)

    local function MakeDraggable(TopBar, Frame)
        local dragging, dragStart, dragPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; dragPos = Frame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end

    local Panels = {}

    -- Base Window Factory
    local function CreateWindowBase(Name, Size, Pos, isMain)
        local Frame = Create("Frame", {
            Name = Name, Size = Size, Position = Pos,
            BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 50), Thickness = 2 })
        })

        local Header = Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1 })
        Header.Parent = Frame
        MakeDraggable(Header, Frame)

        local ContentArea = Create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 50), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent1 }, {
            Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
        })
        ContentArea.Parent = Frame

        return Frame, Header, ContentArea
    end

    -- Create Main UI
    local MainFrame, MainHeader, MainContent = CreateWindowBase("Main", UDim2.new(0, 320, 0, 500), UDim2.new(0.5, -160, 0.5, -250), true)
    MainFrame.Parent = gui

    -- Main Header Content
    local TitleFrame2 = Create("Frame", { Size = UDim2.new(0, 200, 0, 20), BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 10) })
    TitleFrame2.Parent = MainHeader
    local tilde = Create("TextLabel", { Size = UDim2.new(0, 20, 1, 0), BackgroundTransparency = 1, Text = "~", TextColor3 = Theme.Accent2, Font = FONT, TextSize = 18 }); tilde.Parent = TitleFrame2
    local lbl1 = Create("TextLabel", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1, Text = "VICTORIA ", TextColor3 = Color3.new(1,1,1), Font = FONT, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left }); lbl1.Parent = TitleFrame2
    local lbl2 = Create("TextLabel", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 90, 0, 0), BackgroundTransparency = 1, Text = "SCRIPT", TextColor3 = Color3.new(1,1,1), Font = FONT, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left }); lbl2.Parent = TitleFrame2
    
    -- Gradient Anim
    local grad1 = Create("UIGradient", { Color = ColorSequence.new(Theme.Accent2, Theme.Accent1) }); grad1.Parent = lbl1
    local grad2 = Create("UIGradient", { Color = ColorSequence.new(Theme.Accent1, Theme.Accent2) }); grad2.Parent = lbl2
    RunService.RenderStepped:Connect(function()
        grad1.Rotation = (grad1.Rotation + 2) % 360
        grad2.Rotation = (grad2.Rotation - 2) % 360
    end)

    Create("TextLabel", { Size = UDim2.new(0, 200, 0, 15), Position = UDim2.new(0, 10, 0, 30), BackgroundTransparency = 1, Text = "// BY " .. string.upper(Author), TextColor3 = Theme.SubText, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }).Parent = MainHeader

    local MinimizeBtn = Create("TextButton", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -66, 0, 12), BackgroundColor3 = Theme.Bg, Text = "-", TextColor3 = Theme.Accent1, Font = FONT, TextSize = 20 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Theme.Accent1, Thickness = 1 }) })
    MinimizeBtn.Parent = MainHeader
    local CloseBtn = Create("TextButton", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 12), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "X", TextColor3 = Color3.fromRGB(255, 255, 255), Font = FONT, TextSize = 16 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    CloseBtn.Parent = MainHeader

    MinimizeBtn.MouseButton1Click:Connect(function()
        local tPos = FloatingBtn.Position
        FloatingBtn.Visible = true
        MakeTween(MainFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In}, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(tPos.X.Scale, tPos.X.Offset+22, tPos.Y.Scale, tPos.Y.Offset+22) }).Completed:Wait()
        MainFrame.Visible = false
    end)
    FloatingBtn.MouseButton1Click:Connect(function()
        if not fDrag then
            FloatingBtn.Visible = false
            MainFrame.Visible = true
            MakeTween(MainFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, { Size = UDim2.new(0, 320, 0, 500), Position = UDim2.new(0.5, -160, 0.5, -250) })
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local WindowObj = { GUI = gui }

    local function BuildElements(ParentFrame)
        local Elements = {}
        local function MakeCard(h) return Create("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Theme.Card }, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }), Create("UIStroke", { Color = Color3.fromRGB(35, 35, 45), Thickness = 1 }) }) end

        function Elements:AddSection(Title)
            Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "// " .. string.upper(Title), TextColor3 = Theme.SubText, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }).Parent = ParentFrame
        end

        function Elements:AddInfo(Config)
            local Card = MakeCard(30)
            local DotColor = Config.Color or Theme.Accent1
            Create("Frame", { Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 10, 0.5, -3), BackgroundColor3 = DotColor }, { Create("UICorner", { CornerRadius = UDim.new(1,0) }) }).Parent = Card
            Create("TextLabel", { Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 22, 0, 0), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.SubText, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
            local Val = Create("TextLabel", { Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, -110, 0, 0), BackgroundTransparency = 1, Text = tostring(Config.Value), TextColor3 = DotColor, Font = FONT, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Right })
            Val.Parent = Card; Card.Parent = ParentFrame
            return { Update = function(self, v) Val.Text = tostring(v) end }
        end

        function Elements:AddNumberPicker(Config)
            local Card = MakeCard(40)
            local layout = Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })
            layout.Parent = Card
            
            local currentVal = Config.Default or 1
            local btns = {}
            for i = Config.Min, Config.Max do
                local b = Create("TextButton", { Size = UDim2.new(0, 22, 0, 22), BackgroundTransparency = 1, Text = tostring(i), TextColor3 = (i == currentVal) and Theme.Green or Theme.SubText, Font = FONT, TextSize = 14 })
                b.Parent = Card
                b.MouseButton1Click:Connect(function()
                    currentVal = i
                    for _, btn in pairs(btns) do btn.TextColor3 = Theme.SubText end
                    b.TextColor3 = Theme.Green
                    if Config.Callback then Config.Callback(currentVal) end
                end)
                table.insert(btns, b)
            end
            Card.Parent = ParentFrame
            return { GetValue = function() return currentVal end, SetValue = function(self, v) currentVal = v; for i, btn in ipairs(btns) do btn.TextColor3 = (i == currentVal) and Theme.Green or Theme.SubText end end }
        end

        function Elements:AddToggle(Config)
            local Card = MakeCard(44)
            local State = Config.Default or false
            Create("Frame", { Size = UDim2.new(0, 2, 0, 20), Position = UDim2.new(0, 10, 0.5, -10), BackgroundColor3 = Theme.Orange }).Parent = Card
            Create("TextLabel", { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 18, 0, 4), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
            if Config.Subtitle then Create("TextLabel", { Size = UDim2.new(1, -80, 0, 15), Position = UDim2.new(0, 18, 0, 24), BackgroundTransparency = 1, Text = "// " .. string.upper(Config.Subtitle), TextColor3 = Theme.SubText, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card end
            local ToggleBtn = Create("TextButton", { Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -54, 0.5, -12), BackgroundColor3 = Theme.Bg, Text = State and "ON" or "OFF", TextColor3 = State and Theme.Orange or Theme.SubText, Font = FONT, TextSize = 14 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
            ToggleBtn.Parent = Card
            local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }); Btn.Parent = Card; Card.Parent = ParentFrame
            Btn.MouseButton1Click:Connect(function() State = not State; ToggleBtn.Text = State and "ON" or "OFF"; ToggleBtn.TextColor3 = State and Theme.Orange or Theme.SubText; if Config.Callback then Config.Callback(State) end end)
            return { Update = function(self, v) State = v; ToggleBtn.Text = State and "ON" or "OFF"; ToggleBtn.TextColor3 = State and Theme.Orange or Theme.SubText end }
        end

        function Elements:AddStorageItem(Config)
            local Card = MakeCard(40)
            local Lbl = Create("TextLabel", { Size = UDim2.new(0, 180, 0, 20), Position = UDim2.new(0, 10, 0, 8), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }); Lbl.Parent = Card
            local Val = Create("TextLabel", { Size = UDim2.new(0, 100, 0, 20), Position = UDim2.new(1, -110, 0, 8), BackgroundTransparency = 1, Text = Config.Current .. " / " .. Config.Max, TextColor3 = Theme.Accent1, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right }); Val.Parent = Card
            local BarBg = Create("Frame", { Size = UDim2.new(1, -20, 0, 2), Position = UDim2.new(0, 10, 1, -8), BackgroundColor3 = Theme.Bg }); BarBg.Parent = Card
            local Fill = Create("Frame", { Size = UDim2.new(math.clamp(Config.Current/Config.Max, 0, 1), 0, 1, 0), BackgroundColor3 = Theme.Accent1 }); Fill.Parent = BarBg
            Card.Parent = ParentFrame
            return { Update = function(self, cur, max) Val.Text = cur .. " / " .. max; MakeTween(Fill, {0.2}, { Size = UDim2.new(math.clamp(cur/max, 0, 1), 0, 1, 0) }) end }
        end

        function Elements:AddPanelButton(Config)
            local Card = MakeCard(44)
            Create("Frame", { Size = UDim2.new(0, 2, 0, 20), Position = UDim2.new(0, 10, 0.5, -10), BackgroundColor3 = Theme.Orange }).Parent = Card
            Create("TextLabel", { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 18, 0, 4), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
            Create("TextLabel", { Size = UDim2.new(1, -80, 0, 15), Position = UDim2.new(0, 18, 0, 24), BackgroundTransparency = 1, Text = "// CLICK TO OPEN PANEL", TextColor3 = Theme.SubText, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
            local Ico = Create("TextLabel", { Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -45, 0, 0), BackgroundTransparency = 1, Text = "<<<", TextColor3 = Theme.Orange, Font = FONT, TextSize = 18 }); Ico.Parent = Card
            local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }); Btn.Parent = Card; Card.Parent = ParentFrame
            Btn.MouseButton1Click:Connect(function() if Config.Panel then Config.Panel.Visible = not Config.Panel.Visible; Ico.Text = Config.Panel.Visible and ">>>" or "<<<" end end)
        end

        function Elements:AddShopItem(Config)
            local Card = MakeCard(50)
            local BadgeCol = Config.BadgeColor or Theme.Purple
            local Badge = Create("TextLabel", { Size = UDim2.new(0, 50, 0, 14), Position = UDim2.new(0, 10, 0, 8), BackgroundColor3 = Theme.Bg, Text = string.upper(Config.Badge), TextColor3 = BadgeCol, Font = FONT, TextSize = 10 }, { Create("UICorner", { CornerRadius = UDim.new(0,4) }) }); Badge.Parent = Card
            Create("TextLabel", { Size = UDim2.new(0, 150, 0, 14), Position = UDim2.new(0, 65, 0, 8), BackgroundTransparency = 1, Text = string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
            Create("TextLabel", { Size = UDim2.new(0, 200, 0, 14), Position = UDim2.new(0, 10, 0, 26), BackgroundTransparency = 1, Text = string.upper(Config.Subtitle), TextColor3 = Theme.SubText, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }).Parent = Card
            
            local Stock = Create("TextLabel", { Size = UDim2.new(0, 80, 0, 14), Position = UDim2.new(1, -90, 0, 8), BackgroundTransparency = 1, Text = "STOCK: " .. Config.Stock, TextColor3 = Theme.Green, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right }); Stock.Parent = Card
            local Btn = Create("TextButton", { Size = UDim2.new(0, 50, 0, 18), Position = UDim2.new(1, -60, 0, 24), BackgroundColor3 = Theme.Bg, Text = "OFF", TextColor3 = Theme.SubText, Font = FONT, TextSize = 12 }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) }); Btn.Parent = Card
            Card.Parent = ParentFrame
            
            local State = false
            Btn.MouseButton1Click:Connect(function() State = not State; Btn.Text = State and "ON" or "OFF"; Btn.TextColor3 = State and Theme.Green or Theme.SubText; if Config.Callback then Config.Callback(State) end end)
            return { UpdateStock = function(self, s) Stock.Text = "STOCK: " .. s end }
        end

        function Elements:AddBanner(Config)
            local Card = MakeCard(40)
            Card.BackgroundColor3 = Color3.fromRGB(15, 25, 35)
            local Lbl = Create("TextLabel", { Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = string.upper(Config.Text), TextColor3 = Theme.Accent1, Font = FONT, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }); Lbl.Parent = Card
            if Config.ButtonText then
                local Btn = Create("TextButton", { Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -65, 0.5, -12), BackgroundColor3 = Theme.Accent1, Text = string.upper(Config.ButtonText), TextColor3 = Color3.new(0,0,0), Font = FONT, TextSize = 12 }, { Create("UICorner", { CornerRadius = UDim.new(0, 4) }) }); Btn.Parent = Card
                Btn.MouseButton1Click:Connect(function() if Config.Callback then Config.Callback() end end)
            end
            Card.Parent = ParentFrame
            return { UpdateText = function(self, t) Lbl.Text = string.upper(t) end }
        end

        function Elements:AddLogBox()
            local Card = MakeCard(100)
            local Box = Create("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2 }, { Create("UIListLayout", { Padding = UDim.new(0, 2) }) })
            Box.Parent = Card; Card.Parent = ParentFrame
            return {
                AddLog = function(self, text, color)
                    local l = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = text, TextColor3 = color or Theme.SubText, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left })
                    l.Parent = Box; Box.CanvasSize = UDim2.new(0, 0, 0, #Box:GetChildren() * 17)
                end,
                Clear = function(self) for _, c in ipairs(Box:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end Box.CanvasSize = UDim2.new(0,0,0,0) end
            }
        end

        return Elements
    end

    function WindowObj:MakePanel(Config)
        local Size = Config.Size or UDim2.new(0, 300, 0, 500)
        local Pos = UDim2.new(0.5, 170, 0.5, -250) -- Next to main UI
        local Panel, PHeader, PContent = CreateWindowBase(Config.Name, Size, Pos, false)
        Panel.Parent = gui
        Panel.Visible = false

        local t = Create("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "🛒 " .. string.upper(Config.Name), TextColor3 = Theme.Text, Font = FONT, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left })
        t.Parent = PHeader

        local ClBtn = Create("TextButton", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 12), BackgroundColor3 = Theme.Bg, Text = "X", TextColor3 = Theme.Red, Font = FONT, TextSize = 16 }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }), Create("UIStroke", { Color = Theme.Red, Thickness = 1 }) })
        ClBtn.Parent = PHeader
        ClBtn.MouseButton1Click:Connect(function() Panel.Visible = false end)

        local Elements = BuildElements(PContent)
        Elements.PanelFrame = Panel
        return Elements
    end

    WindowObj.Main = BuildElements(MainContent)
    return WindowObj
end

return VictoriaUI
