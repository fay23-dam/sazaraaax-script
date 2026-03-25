

local Players     = game:GetService("Players")
local TweenSvc    = game:GetService("TweenService")
local UIS         = game:GetService("UserInputService")
local VIM         = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LP          = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  ANTI-AFK
-- ═══════════════════════════════════════════════════════════
LP.Idled:Connect(function()
    pcall(function() VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
    task.wait(0.1)
    pcall(function() VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
end)
task.spawn(function()
    while task.wait(240) do
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.Jump = true end) end
        end
        pcall(function()
            VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
            task.wait(0.08)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  INSTANT PROXIMITY PROMPT
-- ═══════════════════════════════════════════════════════════
local function applyInstant(pp)
    pcall(function() pp.HoldDuration = 0 end)
end
for _, o in ipairs(workspace:GetDescendants()) do
    if o:IsA("ProximityPrompt") then applyInstant(o) end
end
workspace.DescendantAdded:Connect(function(o)
    if o:IsA("ProximityPrompt") then task.defer(applyInstant, o) end
end)
pcall(function()
    game:GetService("ProximityPromptService").PromptShown:Connect(applyInstant)
end)

-- ═══════════════════════════════════════════════════════════
--  COLORS & CONSTANTS
-- ═══════════════════════════════════════════════════════════
local C = {
    BG      = Color3.fromHex("#0d0f11"),
    SURFACE = Color3.fromHex("#141618"),
    ELEV    = Color3.fromHex("#1c1f22"),
    BORDER  = Color3.fromHex("#262b30"),
    ACCENT  = Color3.fromHex("#34c76d"),
    ACDIM   = Color3.fromHex("#0f2a1a"),
    TEXT    = Color3.fromHex("#dae0da"),
    DIM     = Color3.fromHex("#5f6c66"),
    RED     = Color3.fromHex("#e85555"),
    REDDIM  = Color3.fromHex("#2a0c0c"),
    YELLOW  = Color3.fromHex("#f0c040"),
    YELLOWD = Color3.fromHex("#282008"),
    TAG     = Color3.fromHex("#ffb937"),
    TAGDIM  = Color3.fromHex("#2a1e06"),
}

local RARITY_COLORS = {
    Common    = Color3.fromRGB(180,180,180), Uncommon  = Color3.fromRGB(100,255,100),
    Rare      = Color3.fromRGB(100,100,255), Epic      = Color3.fromRGB(170,0,255),
    Legendary = Color3.fromRGB(255,150,0),  Mythic    = Color3.fromRGB(255,0,0),
    Secret    = Color3.fromRGB(210,210,210), Ancient   = Color3.fromRGB(80,60,255),
    Divine    = Color3.fromRGB(255,215,100),
}
local RANK_COLORS = {
    Normal    = Color3.fromRGB(218,224,218), Golden    = Color3.fromRGB(255,215,0),
    Diamond   = Color3.fromRGB(85,255,255),  Emerald   = Color3.fromRGB(0,255,0),
    Ruby      = Color3.fromRGB(255,60,60),   Rainbow   = Color3.fromRGB(255,120,210),
    Void      = Color3.fromRGB(160,80,255),  Ethereal  = Color3.fromRGB(180,190,230),
    Celestial = Color3.fromRGB(255,175,60),
}
local RARITIES_SORTED = {"Divine","Ancient","Secret","Mythic","Legendary","Epic","Rare","Uncommon","Common"}
local RANKS_SORTED    = {"Celestial","Ethereal","Void","Rainbow","Ruby","Emerald","Diamond","Golden","Normal"}

local RARITY_ORDER, RANK_ORDER = {}, {}
for i, v in ipairs(RARITIES_SORTED) do RARITY_ORDER[v] = i end
for i, v in ipairs(RANKS_SORTED)    do RANK_ORDER[v]   = i end

-- ═══════════════════════════════════════════════════════════
--  UI HELPERS
-- ═══════════════════════════════════════════════════════════
local N = math.round  -- alias pendek

local function mkCorner(p, r)
    local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or N(7)); return c
end
local function mkStroke(p, col, th)
    local s = Instance.new("UIStroke", p); s.Color = col or C.BORDER; s.Thickness = th or 1; return s
end
local function mkLbl(parent, t)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Font           = t.mono and Enum.Font.Code or Enum.Font.GothamBold
    l.TextColor3     = t.color or C.TEXT
    l.TextSize       = N(t.size or 11)
    l.Text           = t.text or ""
    l.Size           = t.sz  or UDim2.new(1,0,1,0)
    l.Position       = t.pos or UDim2.new(0,0,0,0)
    l.TextXAlignment = t.xa  or Enum.TextXAlignment.Left
    l.TextTruncate   = Enum.TextTruncate.AtEnd
    return l
end
local function mkBtn(parent, t)
    local b = Instance.new("TextButton", parent)
    b.BackgroundColor3 = t.bg  or C.ELEV
    b.TextColor3       = t.tc  or C.ACCENT
    b.TextSize         = N(t.size or 11)
    b.Font             = t.mono and Enum.Font.Code or Enum.Font.GothamBold
    b.Text             = t.text or ""
    b.Size             = t.sz  or UDim2.new(1,0,0,N(28))
    b.Position         = t.pos or UDim2.new(0,0,0,0)
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    mkCorner(b, t.r  or N(7))
    mkStroke(b, t.sc or C.BORDER, t.st or 1)
    return b
end
local function mkBox(parent, t)
    local b = Instance.new("TextBox", parent)
    b.BackgroundColor3  = t.bg or C.ELEV
    b.TextColor3        = t.tc or C.TEXT
    b.PlaceholderColor3 = C.DIM
    b.PlaceholderText   = t.ph or ""
    b.Text              = t.text or ""
    b.TextSize          = N(t.size or 11)
    b.Font              = Enum.Font.Code
    b.Size              = t.sz  or UDim2.new(1,0,1,0)
    b.Position          = t.pos or UDim2.new(0,0,0,0)
    b.BorderSizePixel   = 0
    b.ClearTextOnFocus  = false
    mkCorner(b, N(5)); mkStroke(b, C.BORDER, 1); return b
end
local function tw(o, g, dur)
    TweenSvc:Create(o, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quad), g):Play()
end

-- ═══════════════════════════════════════════════════════════
--  SCREENGUI + MAIN FRAME
-- ═══════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name           = "ModelRarityGUI_v3"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() SG.Parent = game:GetService("CoreGui") end) then
    SG.Parent = LP:WaitForChild("PlayerGui")
end

local W      = N(300)
local HDR_H  = N(44)
local FULL_H = N(520)
local PAD    = N(10)
local TAB_H  = N(28)
local PAGE_Y = PAD + TAB_H + PAD
local PAGE_H = FULL_H - HDR_H - PAGE_Y - PAD

local Main = Instance.new("Frame", SG)
Main.Name             = "Main"
Main.Size             = UDim2.new(0, W, 0, FULL_H)
Main.Position         = UDim2.new(0, N(16), 0.5, -FULL_H/2)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel  = 0
Main.Active           = true
Main.Draggable        = not UIS.TouchEnabled
Main.ClipsDescendants = true
mkCorner(Main, N(12)); mkStroke(Main, C.BORDER, 1)

-- ───── Header ─────────────────────────────────────────────
local Header = Instance.new("Frame", Main)
Header.Size                  = UDim2.new(1,0,0,HDR_H)
Header.BackgroundTransparency= 1
Header.ZIndex                = 5

local function mkDot(col, xOff, fn)
    local d = Instance.new("TextButton", Header)
    d.Size = UDim2.new(0,N(9),0,N(9)); d.Position = UDim2.new(0,N(xOff),0.5,-N(4))
    d.BackgroundColor3 = col; d.Text = ""; d.BorderSizePixel = 0
    d.AutoButtonColor = false; d.ZIndex = 6
    mkCorner(d, N(99))
    d.MouseButton1Click:Connect(fn); d.TouchTap:Connect(fn)
end

mkDot(Color3.fromRGB(255,95,87),  12, function() SG:Destroy() end)
local minimized = false
mkDot(Color3.fromRGB(255,189,46), 25, function()
    minimized = not minimized
    tw(Main, {Size = minimized and UDim2.new(0,W,0,HDR_H) or UDim2.new(0,W,0,FULL_H)}, 0.2)
end)
mkDot(Color3.fromRGB(52,199,109), 38, function() end)

mkLbl(Header,{text="~", size=16, color=C.ACCENT, mono=true,
    sz=UDim2.new(0,N(14),0,N(22)), pos=UDim2.new(0,N(58),0.5,-N(11))})
mkLbl(Header,{text="Model Rarity", size=13, color=C.TEXT,
    sz=UDim2.new(0,N(110),0,N(16)), pos=UDim2.new(0,N(76),0.5,-N(8))})

local TagBg = Instance.new("Frame", Header)
TagBg.Size = UDim2.new(0,N(90),0,N(16)); TagBg.Position = UDim2.new(1,-N(152),0.5,-N(8))
TagBg.BackgroundColor3 = C.TAGDIM; TagBg.BorderSizePixel = 0; TagBg.ZIndex = 6
mkCorner(TagBg, N(3))
mkLbl(TagBg,{text="by custom", size=8, color=C.TAG, xa=Enum.TextXAlignment.Center})

-- Base button (header) — simpan posisi base
local BaseBtn = mkBtn(Header,{
    text="⌂ base", mono=true,
    sz=UDim2.new(0,N(52),0,N(20)), pos=UDim2.new(1,-N(58),0.5,-N(10)),
    bg=C.YELLOWD, tc=C.YELLOW, size=9, r=N(5), sc=C.YELLOW, st=1
})
BaseBtn.ZIndex = 7

local HDiv = Instance.new("Frame", Header)
HDiv.Size = UDim2.new(1,0,0,1); HDiv.Position = UDim2.new(0,0,1,-1)
HDiv.BackgroundColor3 = C.BORDER

-- ───── Content + Tabs ─────────────────────────────────────
local ContentWrap = Instance.new("Frame", Main)
ContentWrap.Size             = UDim2.new(1,0,1,-HDR_H)
ContentWrap.Position         = UDim2.new(0,0,0,HDR_H)
ContentWrap.BackgroundTransparency = 1

local TabRow = Instance.new("Frame", ContentWrap)
TabRow.Size             = UDim2.new(1,-PAD*2,0,TAB_H)
TabRow.Position         = UDim2.new(0,PAD,0,PAD)
TabRow.BackgroundTransparency = 1

local function mkTabBtn(label, xPct, wPct, active)
    return mkBtn(TabRow,{
        text=label, mono=true,
        sz=UDim2.new(wPct,-N(3),1,0), pos=UDim2.new(xPct,N(2),0,0),
        bg=active and C.ELEV or C.BG, tc=active and C.ACCENT or C.DIM,
        size=9, r=N(6), sc=active and C.ACCENT or C.BORDER, st=1,
    })
end

local function mkPage()
    local p = Instance.new("Frame", ContentWrap)
    p.Size = UDim2.new(1,0,0,PAGE_H)
    p.Position = UDim2.new(0,0,0,PAGE_Y)
    p.BackgroundTransparency = 1
    return p
end

local PageMon  = mkPage()
local PageAuto = mkPage(); PageAuto.Visible = false

local TabMonBtn  = mkTabBtn("MONITOR", 0,   0.5, true)
local TabAutoBtn = mkTabBtn("AUTO",    0.5, 0.5, false)

local function showTab(t)
    PageMon.Visible  = (t == "monitor")
    PageAuto.Visible = (t == "auto")
    for _, info in ipairs({{TabMonBtn,"monitor"},{TabAutoBtn,"auto"}}) do
        local b, key = info[1], info[2]
        local on = (t == key)
        b.BackgroundColor3 = on and C.ELEV or C.BG
        b.TextColor3       = on and C.ACCENT or C.DIM
        local st = b:FindFirstChildOfClass("UIStroke")
        if st then st.Color = on and C.ACCENT or C.BORDER end
    end
end
TabMonBtn.MouseButton1Click:Connect(function()  showTab("monitor") end)
TabAutoBtn.MouseButton1Click:Connect(function() showTab("auto")    end)

-- ═══════════════════════════════════════════════════════════
--  DATA HELPERS
-- ═══════════════════════════════════════════════════════════
local EntitiesFolder = workspace:FindFirstChild("EntitiesFolder")
local infoCache = {}   -- [model] = {name, mutation, rarity}

local function bfsLabel(root, name)
    local q = {root}; local h = 1
    while h <= #q do
        local node = q[h]; h += 1
        if node:IsA("TextLabel") and node.Name == name then return node.Text end
        for _, c in ipairs(node:GetChildren()) do q[#q+1] = c end
    end
    return nil
end

local function getInfo(model)
    if infoCache[model] then return infoCache[model] end
    local info = {
        name     = bfsLabel(model, "NameLabel")     or "?",
        mutation = bfsLabel(model, "MutationLabel") or "?",
        rarity   = bfsLabel(model, "RarityLabel")   or "?",
    }
    infoCache[model] = info
    return info
end

local function invalidate(model) infoCache[model] = nil end

local function getPos(model)
    if model.PrimaryPart then return model.PrimaryPart.Position end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then return p.Position end
    end
    return nil
end

-- Base position (shared antara monitor & auto)
local basePos = nil

local function saveBase()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then basePos = hrp.CFrame end
end

local function returnToBase()
    if not basePos then return end
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = basePos + Vector3.new(0, 3, 0) end
end

local function teleport(model)
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local pos  = getPos(model)
    if hrp and pos then hrp.CFrame = CFrame.new(pos); return true end
    return false
end

local function interact(model)
    local function findPP(inst)
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("ProximityPrompt") then return d end
        end
    end
    local pp = findPP(model) or (model.Parent and findPP(model.Parent))
    if pp then
        pcall(function() fireproximityprompt(pp) end)
    else
        pcall(function()
            VIM:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════
--  MONITOR PAGE
-- ═══════════════════════════════════════════════════════════
do
    local MonPad = Instance.new("UIPadding", PageMon)
    MonPad.PaddingLeft = UDim.new(0,PAD); MonPad.PaddingRight = UDim.new(0,PAD)

    local MonLL = Instance.new("UIListLayout", PageMon)
    MonLL.SortOrder = Enum.SortOrder.LayoutOrder
    MonLL.Padding   = UDim.new(0, N(5))

    -- info bar
    local CountRow = Instance.new("Frame", PageMon)
    CountRow.Size = UDim2.new(1,0,0,N(26)); CountRow.BackgroundColor3 = C.ELEV
    CountRow.BorderSizePixel = 0; CountRow.LayoutOrder = 1
    mkCorner(CountRow, N(6))
    mkLbl(CountRow,{text="models:", size=10, color=C.DIM, mono=true,
        sz=UDim2.new(0.4,0,1,0), pos=UDim2.new(0,N(10),0,0)})
    local CountLbl = mkLbl(CountRow,{text="0", size=10, color=C.ACCENT,
        sz=UDim2.new(0.6,-N(10),1,0), pos=UDim2.new(0.4,0,0,0), xa=Enum.TextXAlignment.Right})

    -- filter bar
    local FRow = Instance.new("Frame", PageMon)
    FRow.Size = UDim2.new(1,0,0,N(26)); FRow.BackgroundColor3 = C.SURFACE
    FRow.BorderSizePixel = 0; FRow.LayoutOrder = 2
    mkCorner(FRow, N(6)); mkStroke(FRow, C.BORDER, 1)

    local SearchBox = mkBox(FRow,{ph="cari nama / mutation / rarity", size=9,
        sz=UDim2.new(0.5,-N(4),1,0), pos=UDim2.new(0,N(2),0,0), bg=C.ELEV})

    local SortModes = {"Name↑","Rarity","Rank"}
    local sortIdx   = 1
    local SortBtn = mkBtn(FRow,{text="Name↑", mono=true,
        sz=UDim2.new(0.25,-N(2),1,0), pos=UDim2.new(0.5,N(2),0,0),
        bg=C.SURFACE, tc=C.DIM, size=9, r=N(5), sc=C.BORDER})
    local RefBtn = mkBtn(FRow,{text="refresh", mono=true,
        sz=UDim2.new(0.25,-N(2),1,0), pos=UDim2.new(0.75,N(2),0,0),
        bg=C.SURFACE, tc=C.DIM, size=9, r=N(5), sc=C.BORDER})

    -- scroll list
    local Scroll = Instance.new("ScrollingFrame", PageMon)
    Scroll.Size                 = UDim2.new(1,0,0, PAGE_H - N(26+5+26+5+5))
    Scroll.BackgroundColor3     = C.SURFACE
    Scroll.BorderSizePixel      = 0
    Scroll.ScrollBarThickness   = N(3)
    Scroll.ScrollBarImageColor3 = C.ACCENT
    Scroll.CanvasSize           = UDim2.new(0,0,0,0)
    Scroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    Scroll.LayoutOrder          = 3
    mkCorner(Scroll, N(7)); mkStroke(Scroll, C.BORDER, 1)

    local SLL = Instance.new("UIListLayout", Scroll)
    SLL.SortOrder = Enum.SortOrder.LayoutOrder
    SLL.Padding   = UDim.new(0, N(4))

    local SLP = Instance.new("UIPadding", Scroll)
    SLP.PaddingTop = UDim.new(0,N(5)); SLP.PaddingLeft  = UDim.new(0,N(5))
    SLP.PaddingRight = UDim.new(0,N(5)); SLP.PaddingBottom = UDim.new(0,N(5))

    local labelConns  = {}
    local monBtns     = {}

    local SORTERS = {
        ["Name↑"] = function(a,b) return getInfo(a).name < getInfo(b).name end,
        ["Rarity"] = function(a,b)
            local ra = RARITY_ORDER[getInfo(a).rarity] or 99
            local rb = RARITY_ORDER[getInfo(b).rarity] or 99
            if ra ~= rb then return ra < rb end
            return getInfo(a).name < getInfo(b).name
        end,
        ["Rank"] = function(a,b)
            local ra = RANK_ORDER[getInfo(a).mutation] or 99
            local rb = RANK_ORDER[getInfo(b).mutation] or 99
            if ra ~= rb then return ra < rb end
            return getInfo(a).name < getInfo(b).name
        end,
    }

    local function clearMon()
        for _, b in ipairs(monBtns) do b:Destroy() end; monBtns = {}
        for lbl, c in pairs(labelConns) do c:Disconnect() end; labelConns = {}
    end

    local function updateMon()
        clearMon()
        if not EntitiesFolder then CountLbl.Text = "0"; return end

        local search   = SearchBox.Text:lower()
        local filtered = {}
        for _, child in ipairs(EntitiesFolder:GetChildren()) do
            if child:IsA("Model") then
                local info = getInfo(child)
                if search == ""
                    or info.name:lower():find(search,1,true)
                    or info.rarity:lower():find(search,1,true)
                    or info.mutation:lower():find(search,1,true)
                then
                    filtered[#filtered+1] = child
                end
            end
        end

        local sorter = SORTERS[SortModes[sortIdx]]
        if sorter then table.sort(filtered, sorter) end

        local total = 0
        for _, c in ipairs(EntitiesFolder:GetChildren()) do
            if c:IsA("Model") then total += 1 end
        end
        CountLbl.Text = #filtered .. " / " .. total

        for idx, model in ipairs(filtered) do
            local info = getInfo(model)
            local rcol = RARITY_COLORS[info.rarity] or C.DIM
            local dimBg= rcol:Lerp(C.BG, 0.82)

            local btn = Instance.new("TextButton", Scroll)
            btn.LayoutOrder      = idx
            btn.Size             = UDim2.new(1,0,0,N(44))
            btn.BackgroundColor3 = dimBg
            btn.Text             = ""
            btn.AutoButtonColor  = false
            btn.BorderSizePixel  = 0
            mkCorner(btn, N(6))
            mkStroke(btn, rcol:Lerp(C.BORDER,0.5), 1)

            -- nama baris atas
            local nLbl = mkLbl(btn,{text=info.name, size=10, color=C.TEXT,
                sz=UDim2.new(1,-N(10),0,N(16)), pos=UDim2.new(0,N(8),0,N(4))})
            -- rarity + mutation baris bawah
            local rLbl = mkLbl(btn,{
                text="["..info.rarity.."]  "..info.mutation,
                size=8, color=rcol, mono=true,
                sz=UDim2.new(1,-N(10),0,N(13)), pos=UDim2.new(0,N(8),0,N(22))})

            -- tombol TP & tombol TP+Base di kanan
            local tpBtn = mkBtn(btn,{
                text="TP", mono=true,
                sz=UDim2.new(0,N(26),0,N(16)), pos=UDim2.new(1,-N(56),0.5,-N(8)),
                bg=C.ACDIM, tc=C.ACCENT, size=8, r=N(4), sc=C.ACCENT, st=1})
            local baseColBtn = mkBtn(btn,{
                text="⌂", mono=true,
                sz=UDim2.new(0,N(20),0,N(16)), pos=UDim2.new(1,-N(26),0.5,-N(8)),
                bg=C.YELLOWD, tc=C.YELLOW, size=9, r=N(4), sc=C.YELLOW, st=1})

            btn.MouseEnter:Connect(function()  tw(btn,{BackgroundColor3=rcol},0.1) end)
            btn.MouseLeave:Connect(function()  tw(btn,{BackgroundColor3=dimBg},0.1) end)

            -- TP saja (lalu interact)
            tpBtn.MouseButton1Click:Connect(function()
                if teleport(model) then
                    task.wait(0.25)
                    interact(model)
                end
            end)

            -- TP + interact + kembali ke base
            baseColBtn.MouseButton1Click:Connect(function()
                if teleport(model) then
                    task.wait(0.25)
                    interact(model)
                    task.wait(0.4)
                    returnToBase()
                end
            end)

            monBtns[#monBtns+1] = btn

            -- real-time label listener
            local function onLabelChanged()
                invalidate(model)
                local ni = getInfo(model)
                nLbl.Text = ni.name
                rLbl.Text = "["..ni.rarity.."]  "..ni.mutation
                local nc  = RARITY_COLORS[ni.rarity] or C.DIM
                btn.BackgroundColor3 = nc:Lerp(C.BG, 0.82)
                rLbl.TextColor3 = nc
            end
            local function attachLabels(inst)
                local nm = inst.Name
                if inst:IsA("TextLabel") and
                   (nm=="NameLabel" or nm=="MutationLabel" or nm=="RarityLabel")
                   and not labelConns[inst] then
                    labelConns[inst] = inst:GetPropertyChangedSignal("Text"):Connect(onLabelChanged)
                end
                for _, c in ipairs(inst:GetChildren()) do attachLabels(c) end
            end
            attachLabels(model)
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(updateMon)
    SortBtn.MouseButton1Click:Connect(function()
        sortIdx = sortIdx % #SortModes + 1
        SortBtn.Text = SortModes[sortIdx]:lower()
        updateMon()
    end)
    RefBtn.MouseButton1Click:Connect(function()
        RefBtn.Text = "..."; infoCache = {}; updateMon()
        task.delay(0.5, function() if RefBtn.Parent then RefBtn.Text = "refresh" end end)
    end)

    local function connectFolder()
        if not EntitiesFolder then return end
        EntitiesFolder.ChildAdded:Connect(function(c)
            if c:IsA("Model") then updateMon() end
        end)
        EntitiesFolder.ChildRemoved:Connect(function(c)
            infoCache[c] = nil; updateMon()
        end)
    end
    connectFolder()
    workspace.ChildAdded:Connect(function(c)
        if c.Name == "EntitiesFolder" then
            EntitiesFolder = c; connectFolder(); updateMon()
        end
    end)

    -- periodic fallback
    task.spawn(function()
        while SG and SG.Parent do
            task.wait(8)
            if PageMon.Visible then infoCache={}; updateMon() end
        end
    end)

    -- expose updateMon untuk auto page
    _G._MRG_updateMon = updateMon

    task.spawn(function() task.wait(1); updateMon() end)
end  -- end Monitor block

-- ═══════════════════════════════════════════════════════════
--  AUTO PAGE
-- ═══════════════════════════════════════════════════════════
do
    local AutoPad = Instance.new("UIPadding", PageAuto)
    AutoPad.PaddingLeft = UDim.new(0,PAD); AutoPad.PaddingRight = UDim.new(0,PAD)

    local AutoLL = Instance.new("UIListLayout", PageAuto)
    AutoLL.SortOrder = Enum.SortOrder.LayoutOrder
    AutoLL.Padding   = UDim.new(0, N(6))

    -- ─── FILTER PANEL ─────────────────────────────────────
    local CPanel = Instance.new("Frame", PageAuto)
    CPanel.Size             = UDim2.new(1,0,0,0)
    CPanel.AutomaticSize    = Enum.AutomaticSize.Y
    CPanel.BackgroundColor3 = C.SURFACE
    CPanel.BorderSizePixel  = 0
    CPanel.LayoutOrder      = 1
    mkCorner(CPanel, N(10)); mkStroke(CPanel, C.ACCENT, 1)

    local CPTop = Instance.new("Frame", CPanel)
    CPTop.Size = UDim2.new(1,0,0,N(30)); CPTop.BackgroundColor3 = C.ELEV
    CPTop.BorderSizePixel = 0
    mkCorner(CPTop, N(10))
    mkLbl(CPTop,{text="⚙ filter criteria", size=10, color=C.TEXT,
        sz=UDim2.new(0.6,0,1,0), pos=UDim2.new(0,N(10),0,0)})
    mkLbl(CPTop,{text="// OR logic", size=8, color=C.ACCENT, mono=true,
        sz=UDim2.new(0.35,0,1,0), pos=UDim2.new(0.65,0,0,0),
        xa=Enum.TextXAlignment.Right})

    local CBody = Instance.new("Frame", CPanel)
    CBody.Size = UDim2.new(1,0,0,0); CBody.AutomaticSize = Enum.AutomaticSize.Y
    CBody.Position = UDim2.new(0,0,0,N(30)); CBody.BackgroundTransparency = 1
    local CLL = Instance.new("UIListLayout", CBody)
    CLL.SortOrder = Enum.SortOrder.LayoutOrder; CLL.Padding = UDim.new(0,N(4))
    local CPad = Instance.new("UIPadding", CBody)
    CPad.PaddingTop=UDim.new(0,N(6)); CPad.PaddingBottom=UDim.new(0,N(8))
    CPad.PaddingLeft=UDim.new(0,N(8)); CPad.PaddingRight=UDim.new(0,N(8))

    -- State multi-select
    local raritySet = {}   -- [rarity_name] = true
    local rankSet   = {}   -- [rank_name]   = true
    local rarityFilterOn = true
    local rankFilterOn   = true

    -- ── Checklist widget builder ───────────────────────────
    -- Membuat grid tombol toggle langsung di dalam CBody
    local function makeFilterSection(parent, label, items, colorMap, set, layoutOrder)
        -- Header row dengan toggle on/off
        local hRow = Instance.new("Frame", parent)
        hRow.Size = UDim2.new(1,0,0,N(24)); hRow.BackgroundTransparency = 1
        hRow.LayoutOrder = layoutOrder

        mkLbl(hRow,{text=label, size=10, color=C.TEXT,
            sz=UDim2.new(0.45,0,1,0), pos=UDim2.new(0,0,0,0)})

        -- Tombol toggle aktif/nonaktif filter
        local isOn  = true
        local togBtn = mkBtn(hRow,{text="ON", mono=true,
            sz=UDim2.new(0,N(28),0,N(18)), pos=UDim2.new(1,-N(64),0.5,-N(9)),
            bg=C.ACDIM, tc=C.ACCENT, size=8, r=N(4), sc=C.ACCENT, st=1})
        -- All / Clear
        local allBtn = mkBtn(hRow,{text="all", mono=true,
            sz=UDim2.new(0,N(24),0,N(18)), pos=UDim2.new(1,-N(32),0.5,-N(9)),
            bg=C.ELEV, tc=C.DIM, size=8, r=N(4), sc=C.BORDER})
        -- (clear tidak perlu tombol tersendiri, klik ulang all)

        -- Grid tombol item
        local grid = Instance.new("Frame", parent)
        grid.Size = UDim2.new(1,0,0,0); grid.AutomaticSize = Enum.AutomaticSize.Y
        grid.BackgroundTransparency = 1; grid.LayoutOrder = layoutOrder + 1

        local gridLayout = Instance.new("UIGridLayout", grid)
        gridLayout.CellSize    = UDim2.new(0, N(72), 0, N(20))
        gridLayout.CellPadding = UDim2.new(0, N(4),  0, N(4))
        gridLayout.SortOrder   = Enum.SortOrder.LayoutOrder

        local gridPad = Instance.new("UIPadding", grid)
        gridPad.PaddingBottom = UDim.new(0,N(4))

        local itemBtns = {}

        local function refreshGrid()
            for name, btn in pairs(itemBtns) do
                local on = set[name] == true
                local rc = colorMap[name] or C.TEXT
                btn.BackgroundColor3 = on and rc:Lerp(C.BG,0.7) or C.ELEV
                btn.TextColor3       = on and rc or C.DIM
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then st.Color = on and rc or C.BORDER end
                btn.Text = (on and "✓ " or "") .. name
            end
        end

        for ord, name in ipairs(items) do
            local btn = Instance.new("TextButton", grid)
            btn.LayoutOrder      = ord
            btn.Size             = UDim2.new(0,N(72),0,N(20))   -- diatur UIGridLayout
            btn.BackgroundColor3 = C.ELEV
            btn.BorderSizePixel  = 0
            btn.TextColor3       = C.DIM
            btn.TextSize         = N(8)
            btn.Font             = Enum.Font.Code
            btn.Text             = name
            btn.AutoButtonColor  = false
            btn.TextTruncate     = Enum.TextTruncate.AtEnd
            mkCorner(btn, N(4)); mkStroke(btn, C.BORDER, 0.8)

            btn.MouseButton1Click:Connect(function()
                set[name] = set[name] and nil or true
                refreshGrid()
            end)
            itemBtns[name] = btn
        end

        allBtn.MouseButton1Click:Connect(function()
            local allSelected = true
            for _, nm in ipairs(items) do if not set[nm] then allSelected=false; break end end
            if allSelected then
                for k in pairs(set) do set[k] = nil end  -- clear semua
                allBtn.Text = "all"; allBtn.TextColor3 = C.DIM
            else
                for _, nm in ipairs(items) do set[nm] = true end  -- pilih semua
                allBtn.Text = "clr"; allBtn.TextColor3 = C.RED
            end
            refreshGrid()
        end)

        togBtn.MouseButton1Click:Connect(function()
            isOn = not isOn
            togBtn.Text             = isOn and "ON" or "OFF"
            togBtn.TextColor3       = isOn and C.ACCENT or C.DIM
            togBtn.BackgroundColor3 = isOn and C.ACDIM  or C.ELEV
            local st = togBtn:FindFirstChildOfClass("UIStroke")
            if st then st.Color = isOn and C.ACCENT or C.BORDER end
            grid.Visible = isOn
        end)

        refreshGrid()

        -- Return fungsi cek status
        return function() return isOn end, function() return set end
    end

    -- Rarity section
    local getRarityOn, _ = makeFilterSection(CBody, "◆ rarity filter", RARITIES_SORTED, RARITY_COLORS, raritySet, 10)
    -- Rank/Mutation section  
    local getRankOn, _   = makeFilterSection(CBody, "◈ mutation filter", RANKS_SORTED, RANK_COLORS, rankSet, 20)

    -- Divider
    local div = Instance.new("Frame", CBody)
    div.Size = UDim2.new(1,0,0,1); div.BackgroundColor3 = C.BORDER
    div.BorderSizePixel = 0; div.LayoutOrder = 29

    -- Delay row
    local delRow = Instance.new("Frame", CBody)
    delRow.Size = UDim2.new(1,0,0,N(24)); delRow.BackgroundTransparency = 1
    delRow.LayoutOrder = 30
    mkLbl(delRow,{text="tp delay (s)", size=9, color=C.DIM, mono=true,
        sz=UDim2.new(0.5,0,1,0), pos=UDim2.new(0,0,0,0)})
    local delayBox = mkBox(delRow,{ph="0.5",text="0.5",size=10,
        sz=UDim2.new(0.45,-N(4),0,N(20)), pos=UDim2.new(0.55,0,0.5,-N(10)), bg=C.ELEV})

    local intRow = Instance.new("Frame", CBody)
    intRow.Size = UDim2.new(1,0,0,N(24)); intRow.BackgroundTransparency = 1
    intRow.LayoutOrder = 31
    mkLbl(intRow,{text="interact delay (s)", size=9, color=C.DIM, mono=true,
        sz=UDim2.new(0.5,0,1,0), pos=UDim2.new(0,0,0,0)})
    local interactBox = mkBox(intRow,{ph="0.3",text="0.3",size=10,
        sz=UDim2.new(0.45,-N(4),0,N(20)), pos=UDim2.new(0.55,0,0.5,-N(10)), bg=C.ELEV})

    local orNote = Instance.new("Frame", CBody)
    orNote.Size = UDim2.new(1,0,0,N(18)); orNote.BackgroundColor3 = C.ACDIM
    orNote.BorderSizePixel = 0; orNote.LayoutOrder = 32
    mkCorner(orNote, N(4)); mkStroke(orNote, C.ACCENT, 0.5)
    mkLbl(orNote,{text="// OR: cukup 1 filter aktif yg terpenuhi",
        size=8, color=C.ACCENT, mono=true,
        sz=UDim2.new(1,0,1,0), pos=UDim2.new(0,N(8),0,0)})

    -- ─── LOG BOX (dibuat SEBELUM toggle button agar logScroll tersedia) ───
    local LogOuter = Instance.new("Frame", PageAuto)
    LogOuter.Size             = UDim2.new(1,0,0,N(80))
    LogOuter.BackgroundColor3 = C.SURFACE
    LogOuter.BorderSizePixel  = 0
    LogOuter.LayoutOrder      = 3
    mkCorner(LogOuter, N(8)); mkStroke(LogOuter, C.BORDER, 1)

    local LogTop = Instance.new("Frame", LogOuter)
    LogTop.Size = UDim2.new(1,0,0,N(22)); LogTop.BackgroundColor3 = C.ELEV
    LogTop.BorderSizePixel = 0; mkCorner(LogTop, N(8))
    mkLbl(LogTop,{text="// activity log", size=9, color=C.DIM, mono=true,
        sz=UDim2.new(1,0,1,0), pos=UDim2.new(0,N(10),0,0)})

    local LogScroll = Instance.new("ScrollingFrame", LogOuter)
    LogScroll.Size                 = UDim2.new(1,-N(6),1,-N(24))
    LogScroll.Position             = UDim2.new(0,N(3),0,N(24))
    LogScroll.BackgroundTransparency = 1
    LogScroll.ScrollBarThickness   = N(2)
    LogScroll.ScrollBarImageColor3 = C.ACCENT
    LogScroll.CanvasSize           = UDim2.new(0,0,0,0)
    LogScroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    local LogLL = Instance.new("UIListLayout", LogScroll)
    LogLL.Padding = UDim.new(0,1)

    -- Log helper (referensi langsung, bukan FindFirstChild)
    local function addLog(msg, col)
        local l = Instance.new("TextLabel", LogScroll)
        l.Text = msg; l.Size = UDim2.new(1,0,0,N(12))
        l.BackgroundTransparency = 1
        l.TextColor3 = col or C.DIM
        l.TextSize = N(9); l.Font = Enum.Font.Code
        l.TextXAlignment = Enum.TextXAlignment.Left
        local kids = LogScroll:GetChildren()
        if #kids > 65 then
            for _, c in ipairs(kids) do
                if c:IsA("TextLabel") then c:Destroy(); break end
            end
        end
        task.defer(function()
            if LogScroll.Parent then
                LogScroll.CanvasPosition = Vector2.new(0,math.huge)
            end
        end)
    end

    -- ─── CRITERIA CHECK ───────────────────────────────────
    local function matchesCriteria(model)
        local ro = getRarityOn()
        local rko= getRankOn()
        if not ro and not rko then return true end
        local info = getInfo(model)
        if ro  and raritySet[info.rarity]   then return true end
        if rko and rankSet[info.mutation]   then return true end
        return false
    end

    -- ─── AUTO COLLECT LOGIC ───────────────────────────────
    local autoRunning = false

    local function startAuto()
        if autoRunning then return end
        saveBase()
        autoRunning = true
        addLog("// auto collect started", C.ACCENT)
        task.spawn(function()
            while autoRunning do
                if not EntitiesFolder then task.wait(1); continue end
                local found = false
                for _, model in ipairs(EntitiesFolder:GetChildren()) do
                    if not autoRunning then break end
                    if model:IsA("Model") and matchesCriteria(model) then
                        local info = getInfo(model)
                        addLog(string.format("→ %s | %s | %s",
                            info.name, info.mutation, info.rarity),
                            RARITY_COLORS[info.rarity] or C.DIM)

                        if teleport(model) then
                            local id = tonumber(interactBox.Text) or 0.3
                            task.wait(id)
                            interact(model)
                            local td = tonumber(delayBox.Text) or 0.5
                            task.wait(td)
                            returnToBase()
                            addLog("  ⌂ kembali ke base", C.YELLOW)
                        else
                            addLog("  ! teleport gagal", C.RED)
                        end
                        found = true
                        task.wait(tonumber(delayBox.Text) or 0.5)
                        break
                    end
                end
                if not found then
                    addLog("// tidak ada model yang cocok", C.DIM)
                    task.wait(2)
                end
            end
        end)
    end

    local function stopAuto()
        autoRunning = false
        addLog("// auto collect dihentikan", C.RED)
    end

    -- ─── TOGGLE BUTTON (LayoutOrder=2, setelah CPanel=1) ──
    local TogOuter = Instance.new("Frame", PageAuto)
    TogOuter.Size             = UDim2.new(1,0,0,N(42))
    TogOuter.BackgroundColor3 = C.ELEV
    TogOuter.BorderSizePixel  = 0
    TogOuter.LayoutOrder      = 2
    mkCorner(TogOuter, N(9))
    local togStroke = mkStroke(TogOuter, C.BORDER, 1)
    local togBar    = Instance.new("Frame", TogOuter)
    togBar.Size = UDim2.new(0,N(3),0,N(24)); togBar.Position = UDim2.new(0,N(8),0.5,-N(12))
    togBar.BackgroundColor3 = C.DIM; togBar.BorderSizePixel = 0; mkCorner(togBar, N(99))

    local TogBtn = Instance.new("TextButton", TogOuter)
    TogBtn.Size = UDim2.new(1,0,1,0); TogBtn.BackgroundTransparency = 1; TogBtn.Text = ""

    mkLbl(TogOuter,{text="AUTO COLLECT", size=12, color=C.TEXT,
        sz=UDim2.new(1,-N(70),0,N(16)), pos=UDim2.new(0,N(18),0,N(6))})
    local TogSub = mkLbl(TogOuter,{text="// tekan untuk mengaktifkan",
        size=9, color=C.DIM, mono=true,
        sz=UDim2.new(1,-N(70),0,N(13)), pos=UDim2.new(0,N(18),0,N(24))})

    local TogBadge = Instance.new("TextLabel", TogOuter)
    TogBadge.Size = UDim2.new(0,N(36),0,N(18)); TogBadge.Position = UDim2.new(1,-N(44),0.5,-N(9))
    TogBadge.BackgroundColor3 = C.ELEV; TogBadge.BorderSizePixel = 0
    TogBadge.Text = "OFF"; TogBadge.Font = Enum.Font.Code
    TogBadge.TextSize = N(10); TogBadge.TextColor3 = C.DIM
    mkCorner(TogBadge, N(5))

    TogBtn.MouseButton1Click:Connect(function()
        if autoRunning then
            stopAuto()
            TogBadge.Text = "OFF"; TogBadge.TextColor3 = C.DIM
            TogBadge.BackgroundColor3 = C.ELEV
            tw(togStroke,{Color=C.BORDER},0.2); tw(togBar,{BackgroundColor3=C.DIM},0.2)
            TogSub.Text = "// tekan untuk mengaktifkan"
        else
            startAuto()
            TogBadge.Text = "ON"; TogBadge.TextColor3 = C.ACCENT
            TogBadge.BackgroundColor3 = C.ACDIM
            tw(togStroke,{Color=C.ACCENT},0.2); tw(togBar,{BackgroundColor3=C.ACCENT},0.2)
            TogSub.Text = "// klik lagi untuk menghentikan"
        end
    end)

end  -- end Auto block

-- ═══════════════════════════════════════════════════════════
--  BASE BUTTON (header)
-- ═══════════════════════════════════════════════════════════
BaseBtn.MouseButton1Click:Connect(function()
    saveBase()
    BaseBtn.Text = "saved!"; BaseBtn.TextColor3 = C.ACCENT
    task.delay(1.5, function()
        if BaseBtn.Parent then
            BaseBtn.Text = "⌂ base"; BaseBtn.TextColor3 = C.YELLOW
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════
--  ENTRANCE ANIMATION
-- ═══════════════════════════════════════════════════════════
Main.Position = UDim2.new(-0.35, 0, 0.5, -FULL_H/2)
TweenSvc:Create(Main,
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Position = UDim2.new(0, N(16), 0.5, -FULL_H/2)}
):Play()

print("[ModelRarityGUI v3] ✓ Loaded")
