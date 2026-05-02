-- ============================================================
-- Victoria Script - Intro Popup v7.0
-- LocalScript → StarterPlayerScripts
-- Tampil saat game load: tombol WA Channel, Discord, dan close X
-- ============================================================

local Players    = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
-- KONFIGURASI LINK
-- ════════════════════════════════════════════════════════════
local LINKS = {
    whatsapp = "https://whatsapp.com/channel/0029VbCBSBOCRs1pRNYpPN0r",
    discord  = "https://discord.gg/HB9gqZGMnT",
}

-- ════════════════════════════════════════════════════════════
-- WARNA TEMA (Victoria dark-green)
-- ════════════════════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(10,  13,  15),
    PANEL       = Color3.fromRGB(17,  23,  20),
    HEADER      = Color3.fromRGB(13,  20,  15),
    BORDER      = Color3.fromRGB(30,  42,  32),
    GREEN       = Color3.fromRGB(52,  199, 109),
    GREEN_DIM   = Color3.fromRGB(13,  50,  25),
    GREEN_DARK  = Color3.fromRGB(10,  30,  18),
    BLUE        = Color3.fromRGB(91,  141, 230),
    BLUE_DIM    = Color3.fromRGB(14,  25,  55),
    BLUE_DARK   = Color3.fromRGB(13,  18,  48),
    RED         = Color3.fromRGB(220, 70,  70),
    RED_DIM     = Color3.fromRGB(50,  14,  14),
    TEXT        = Color3.fromRGB(200, 220, 205),
    MUTED       = Color3.fromRGB(90,  120, 100),
    MUTED2      = Color3.fromRGB(50,  70,  55),
    WHITE       = Color3.fromRGB(255, 255, 255),
    SCAN        = Color3.fromRGB(52,  199, 109),
    OVERLAY     = Color3.fromRGB(5,   8,   10),
}

-- ════════════════════════════════════════════════════════════
-- HELPERS
-- ════════════════════════════════════════════════════════════
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or C.BORDER
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

local function label(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font          = props.font or Enum.Font.Code
    l.TextSize      = props.size or 12
    l.TextColor3    = props.color or C.TEXT
    l.Text          = props.text or ""
    l.TextXAlignment = props.xalign or Enum.TextXAlignment.Left
    l.TextYAlignment = props.yalign or Enum.TextYAlignment.Center
    l.Size          = props.sz or UDim2.new(1, 0, 0, 20)
    l.Position      = props.pos or UDim2.new(0, 0, 0, 0)
    l.TextWrapped   = props.wrap or false
    l.ZIndex        = props.z or 5
    l.Parent        = parent
    return l
end

local function frame(parent, props)
    local f = Instance.new("Frame")
    f.BackgroundColor3   = props.bg or C.BG
    f.BackgroundTransparency = props.trans or 0
    f.BorderSizePixel    = 0
    f.Size               = props.sz or UDim2.new(1, 0, 0, 40)
    f.Position           = props.pos or UDim2.new(0, 0, 0, 0)
    f.ZIndex             = props.z or 4
    f.ClipsDescendants   = props.clip or false
    f.Parent             = parent
    return f
end

local function btn(parent, props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = props.bg or C.GREEN_DIM
    b.BorderSizePixel  = 0
    b.Size             = props.sz or UDim2.new(1, 0, 0, 40)
    b.Position         = props.pos or UDim2.new(0, 0, 0, 0)
    b.Text             = ""
    b.ZIndex           = props.z or 6
    b.AutoButtonColor  = false
    b.Parent           = parent
    corner(b, props.radius or 9)
    if props.border then stroke(b, props.border, 1) end
    return b
end

local function openUrl(url)
    -- Roblox tidak bisa buka URL langsung dari LocalScript secara default.
    -- Gunakan pendekatan yang umum dipakai di executor/exploit environment:
    -- Jika script dijalankan via executor (Synapse, KRNL, dll), gunakan:
    pcall(function()
        if setclipboard then
            setclipboard(url)
            -- Beri tahu user URL sudah di-copy
        end
    end)
    -- Alternatif jika ada HttpService atau custom executor function:
    pcall(function()
        if syn and syn.request then
            -- hanya untuk referensi, tidak membuka browser langsung
        end
    end)
end

-- ════════════════════════════════════════════════════════════
-- BUAT GUI
-- ════════════════════════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "VictoriaIntroPopup"
screenGui.ResetOnSpawn   = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder   = 999
screenGui.Parent         = player.PlayerGui

-- Overlay gelap (backdrop)
local overlay = frame(screenGui, {
    bg    = C.OVERLAY,
    trans = 0.25,
    sz    = UDim2.new(1, 0, 1, 0),
    pos   = UDim2.new(0, 0, 0, 0),
    z     = 1,
})
overlay.ClipsDescendants = false

-- Popup utama (tengah layar)
local POPUP_W = 340
local POPUP_H = 420

local popup = frame(overlay, {
    bg   = C.BG,
    sz   = UDim2.new(0, POPUP_W, 0, POPUP_H),
    pos  = UDim2.new(0.5, -POPUP_W/2, 0.5, -POPUP_H/2),
    clip = true,
    z    = 2,
})
corner(popup, 14)
stroke(popup, C.BORDER, 1)

-- ────────────────────────────────────────────────────────────
-- HEADER
-- ────────────────────────────────────────────────────────────
local headerH = 120
local headerFrame = frame(popup, {
    bg   = C.HEADER,
    sz   = UDim2.new(1, 0, 0, headerH),
    pos  = UDim2.new(0, 0, 0, 0),
    z    = 3,
    clip = true,
})

-- Scanline animasi
local scanLine = frame(headerFrame, {
    bg  = C.SCAN,
    sz  = UDim2.new(1, 0, 0, 2),
    pos = UDim2.new(0, 0, 0, -2),
    z   = 4,
})
scanLine.BackgroundTransparency = 0.75

local function animateScan()
    while popup.Parent do
        local t1 = TweenService:Create(scanLine,
            TweenInfo.new(2.5, Enum.EasingStyle.Linear),
            { Position = UDim2.new(0, 0, 1, 2) }
        )
        t1:Play()
        t1.Completed:Wait()
        scanLine.Position = UDim2.new(0, 0, 0, -2)
    end
end
task.spawn(animateScan)

-- Border bottom header
local headerBorder = frame(headerFrame, {
    bg  = C.BORDER,
    sz  = UDim2.new(1, 0, 0, 1),
    pos = UDim2.new(0, 0, 1, -1),
    z   = 4,
})

-- Dot indicators
local dotRow = frame(headerFrame, {
    bg   = C.HEADER,
    trans= 1,
    sz   = UDim2.new(0, 60, 0, 10),
    pos  = UDim2.new(0, 14, 0, 14),
    z    = 4,
})

local DOT_COLORS = { C.GREEN, C.BLUE, Color3.fromRGB(100, 110, 105) }
for i = 1, 3 do
    local d = frame(dotRow, {
        bg  = DOT_COLORS[i],
        sz  = UDim2.new(0, 7, 0, 7),
        pos = UDim2.new(0, (i-1) * 14, 0, 0),
        z   = 5,
    })
    corner(d, 99)

    -- Pulse animasi dot 1 & 2
    if i <= 2 then
        task.spawn(function()
            local delay = (i - 1) * 0.4
            task.wait(delay)
            while popup.Parent do
                TweenService:Create(d, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    BackgroundTransparency = 0.6
                }):Play()
                task.wait(2.5)
            end
        end)
    end
end

-- Logo icon (tilde ~ hijau tebal)
local iconBg = frame(headerFrame, {
    bg  = C.GREEN_DARK,
    sz  = UDim2.new(0, 38, 0, 38),
    pos = UDim2.new(0, 14, 0, 34),
    z   = 4,
})
corner(iconBg, 9)
stroke(iconBg, C.BORDER, 1)

-- Icon tilde hijau tebal
label(iconBg, {
    text   = "~",
    font   = Enum.Font.GothamBold,
    size   = 28,
    color  = C.GREEN,
    sz     = UDim2.new(1, 0, 1, 0),
    pos    = UDim2.new(0, 0, 0, 0),
    xalign = Enum.TextXAlignment.Center,
    yalign = Enum.TextYAlignment.Center,
    z      = 5,
})

-- Title teks (bold white)
label(headerFrame, {
    text   = "VICTORIA SCRIPT",
    font   = Enum.Font.GothamBold,
    size   = 20,
    color  = C.WHITE,
    sz     = UDim2.new(0, 180, 0, 24),
    pos    = UDim2.new(0, 62, 0, 34),
    z      = 5,
})
label(headerFrame, {
    text   = "Connect with us",
    font   = Enum.Font.Code,
    size   = 10,
    color  = C.MUTED,
    sz     = UDim2.new(0, 180, 0, 16),
    pos    = UDim2.new(0, 62, 0, 58),
    z      = 5,
})
label(headerFrame, {
    text   = "// · roblox script community",
    font   = Enum.Font.Code,
    size   = 10,
    color  = C.MUTED2,
    sz     = UDim2.new(1, -14, 0, 16),
    pos    = UDim2.new(0, 14, 0, 96),
    z      = 5,
})

-- ────────────────────────────────────────────────────────────
-- CLOSE BUTTON (X)
-- ────────────────────────────────────────────────────────────
local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 28, 0, 28)
closeBtn.Position         = UDim2.new(1, -38, 0, 10)
closeBtn.BackgroundColor3 = C.RED_DIM
closeBtn.BorderSizePixel  = 0
closeBtn.Text             = "✕"
closeBtn.TextColor3       = C.RED
closeBtn.TextSize         = 13
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.ZIndex           = 10
closeBtn.AutoButtonColor  = false
closeBtn.Parent           = popup
corner(closeBtn, 7)
stroke(closeBtn, Color3.fromRGB(80, 25, 25), 1)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(80, 20, 20) }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.RED_DIM }):Play()
end)

-- ────────────────────────────────────────────────────────────
-- BODY
-- ────────────────────────────────────────────────────────────
local bodyY = headerH + 4
local PAD   = 16

-- Deskripsi
local descBg = frame(popup, {
    bg  = C.GREEN_DARK,
    sz  = UDim2.new(1, -PAD*2, 0, 52),
    pos = UDim2.new(0, PAD, 0, bodyY + 10),
    z   = 3,
})
corner(descBg, 8)

-- Garis aksen kiri
local accentLine = frame(descBg, {
    bg  = C.GREEN,
    sz  = UDim2.new(0, 2, 1, -12),
    pos = UDim2.new(0, 0, 0, 6),
    z   = 4,
})

label(descBg, {
    text   = "Script aktif. Bergabung ke komunitas untuk\nupdate terbaru, bug report & diskusi fitur.",
    font   = Enum.Font.Code,
    size   = 11,
    color  = C.MUTED,
    sz     = UDim2.new(1, -16, 1, 0),
    pos    = UDim2.new(0, 12, 0, 0),
    wrap   = true,
    z      = 5,
})

local BTN_Y_START = bodyY + 78
local BTN_GAP     = 12
local BTN_H       = 54

-- ────────────────────────────────────────────────────────────
-- TOMBOL WHATSAPP
-- ────────────────────────────────────────────────────────────
local waBtn = btn(popup, {
    bg     = C.GREEN_DARK,
    sz     = UDim2.new(1, -PAD*2, 0, BTN_H),
    pos    = UDim2.new(0, PAD, 0, BTN_Y_START),
    border = Color3.fromRGB(26, 60, 34),
    radius = 10,
    z      = 5,
})

-- Icon WA
local waIconBg = frame(waBtn, {
    bg  = C.GREEN_DIM,
    sz  = UDim2.new(0, 34, 0, 34),
    pos = UDim2.new(0, 10, 0.5, -17),
    z   = 6,
})
corner(waIconBg, 8)
label(waIconBg, {
    text   = "WA",
    font   = Enum.Font.GothamBold,
    size   = 11,
    color  = C.GREEN,
    sz     = UDim2.new(1, 0, 1, 0),
    xalign = Enum.TextXAlignment.Center,
    z      = 7,
})

label(waBtn, {
    text   = "WhatsApp Channel",
    font   = Enum.Font.GothamBold,
    size   = 12,
    color  = C.GREEN,
    sz     = UDim2.new(1, -100, 0, 20),
    pos    = UDim2.new(0, 54, 0, 8),
    z      = 6,
})
label(waBtn, {
    text   = "update · pengumuman · tips",
    font   = Enum.Font.Code,
    size   = 10,
    color  = C.MUTED2,
    sz     = UDim2.new(1, -100, 0, 16),
    pos    = UDim2.new(0, 54, 0, 28),
    z      = 6,
})
label(waBtn, {
    text   = "›",
    font   = Enum.Font.GothamBold,
    size   = 20,
    color  = C.GREEN,
    sz     = UDim2.new(0, 20, 1, 0),
    pos    = UDim2.new(1, -28, 0, 0),
    xalign = Enum.TextXAlignment.Center,
    z      = 6,
})

waBtn.MouseEnter:Connect(function()
    TweenService:Create(waBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(17, 37, 24) }):Play()
    stroke(waBtn, C.GREEN, 1)
end)
waBtn.MouseLeave:Connect(function()
    TweenService:Create(waBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.GREEN_DARK }):Play()
end)

-- ────────────────────────────────────────────────────────────
-- TOMBOL DISCORD
-- ────────────────────────────────────────────────────────────
local dcBtn = btn(popup, {
    bg     = C.BLUE_DARK,
    sz     = UDim2.new(1, -PAD*2, 0, BTN_H),
    pos    = UDim2.new(0, PAD, 0, BTN_Y_START + BTN_H + BTN_GAP),
    border = Color3.fromRGB(26, 38, 80),
    radius = 10,
    z      = 5,
})

local dcIconBg = frame(dcBtn, {
    bg  = C.BLUE_DIM,
    sz  = UDim2.new(0, 34, 0, 34),
    pos = UDim2.new(0, 10, 0.5, -17),
    z   = 6,
})
corner(dcIconBg, 8)
label(dcIconBg, {
    text   = "DC",
    font   = Enum.Font.GothamBold,
    size   = 11,
    color  = C.BLUE,
    sz     = UDim2.new(1, 0, 1, 0),
    xalign = Enum.TextXAlignment.Center,
    z      = 7,
})

label(dcBtn, {
    text   = "Discord Server",
    font   = Enum.Font.GothamBold,
    size   = 12,
    color  = C.BLUE,
    sz     = UDim2.new(1, -100, 0, 20),
    pos    = UDim2.new(0, 54, 0, 8),
    z      = 6,
})
label(dcBtn, {
    text   = "komunitas · support · diskusi",
    font   = Enum.Font.Code,
    size   = 10,
    color  = Color3.fromRGB(50, 68, 120),
    sz     = UDim2.new(1, -100, 0, 16),
    pos    = UDim2.new(0, 54, 0, 28),
    z      = 6,
})
label(dcBtn, {
    text   = "›",
    font   = Enum.Font.GothamBold,
    size   = 20,
    color  = C.BLUE,
    sz     = UDim2.new(0, 20, 1, 0),
    pos    = UDim2.new(1, -28, 0, 0),
    xalign = Enum.TextXAlignment.Center,
    z      = 6,
})

dcBtn.MouseEnter:Connect(function()
    TweenService:Create(dcBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(18, 25, 58) }):Play()
    stroke(dcBtn, C.BLUE, 1)
end)
dcBtn.MouseLeave:Connect(function()
    TweenService:Create(dcBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.BLUE_DARK }):Play()
end)

-- ────────────────────────────────────────────────────────────
-- DIVIDER + FOOTER
-- ────────────────────────────────────────────────────────────
local divY = BTN_Y_START + BTN_H * 2 + BTN_GAP + 16
local divider = frame(popup, {
    bg  = C.BORDER,
    sz  = UDim2.new(1, -PAD*2, 0, 1),
    pos = UDim2.new(0, PAD, 0, divY),
    z   = 3,
})

label(popup, {
    text   = "[ tekan  X  untuk menutup ]",
    font   = Enum.Font.Code,
    size   = 10,
    color  = C.MUTED2,
    sz     = UDim2.new(1, 0, 0, 20),
    pos    = UDim2.new(0, 0, 0, divY + 8),
    xalign = Enum.TextXAlignment.Center,
    z      = 4,
})

-- ════════════════════════════════════════════════════════════
-- FUNGSI CLOSE (fade out + destroy)
-- ════════════════════════════════════════════════════════════
local function closePopup()
    local tweenPopup = TweenService:Create(popup,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -POPUP_W/2, 0.5, -POPUP_H/2 + 20) }
    )
    local tweenOverlay = TweenService:Create(overlay,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        { BackgroundTransparency = 1 }
    )
    tweenPopup:Play()
    tweenOverlay:Play()
    task.wait(0.3)
    screenGui:Destroy()
end

-- ════════════════════════════════════════════════════════════
-- FUNGSI BUKA LINK
-- Karena Roblox tidak bisa buka browser dari LocalScript biasa,
-- URL di-copy ke clipboard (jika executor mendukung setclipboard).
-- Di Roblox Studio / game normal: tampilkan notif saja.
-- ════════════════════════════════════════════════════════════
local function handleLink(url, displayName)
    -- Coba copy ke clipboard via executor
    local copied = false
    pcall(function()
        if setclipboard then
            setclipboard(url)
            copied = true
        end
    end)

    -- Tampilkan notif kecil
    local notif = frame(popup, {
        bg  = copied and C.GREEN_DIM or C.BLUE_DIM,
        sz  = UDim2.new(1, -PAD*2, 0, 30),
        pos = UDim2.new(0, PAD, 1, 10),
        z   = 10,
    })
    corner(notif, 8)
    stroke(notif, copied and C.BORDER or Color3.fromRGB(26, 38, 80), 1)

    local notifText = copied
        and ("✓  Link " .. displayName .. " disalin ke clipboard!")
        or  ("→  " .. url)

    label(notif, {
        text   = notifText,
        font   = Enum.Font.Code,
        size   = 10,
        color  = copied and C.GREEN or C.BLUE,
        sz     = UDim2.new(1, -12, 1, 0),
        pos    = UDim2.new(0, 8, 0, 0),
        z      = 11,
    })

    TweenService:Create(notif, TweenInfo.new(0.2), {
        Position = UDim2.new(0, PAD, 1, -40)
    }):Play()

    task.wait(2.5)

    TweenService:Create(notif, TweenInfo.new(0.2), {
        Position = UDim2.new(0, PAD, 1, 10)
    }):Play()
    task.wait(0.25)
    notif:Destroy()
end

-- ════════════════════════════════════════════════════════════
-- ANIMASI MASUK
-- ════════════════════════════════════════════════════════════
popup.Position = UDim2.new(0.5, -POPUP_W/2, 0.5, -POPUP_H/2 + 30)
popup.BackgroundTransparency = 1
overlay.BackgroundTransparency = 1

TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.25 }):Play()

task.wait(0.1)

TweenService:Create(popup, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position             = UDim2.new(0.5, -POPUP_W/2, 0.5, -POPUP_H/2),
    BackgroundTransparency = 0,
}):Play()

-- ════════════════════════════════════════════════════════════
-- KLIK EVENTS
-- ════════════════════════════════════════════════════════════
closeBtn.MouseButton1Click:Connect(closePopup)

waBtn.MouseButton1Click:Connect(function()
    task.spawn(handleLink, LINKS.whatsapp, "WhatsApp")
end)

dcBtn.MouseButton1Click:Connect(function()
    task.spawn(handleLink, LINKS.discord, "Discord")
end)

-- Tutup juga kalau klik overlay (luar popup)
overlay.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Hitung apakah klik di luar popup
        local mp = game:GetService("UserInputService"):GetMouseLocation()
        local px = popup.AbsolutePosition
        local ps = popup.AbsoluteSize
        local inPopup = mp.X >= px.X and mp.X <= px.X + ps.X
                    and mp.Y >= px.Y and mp.Y <= px.Y + ps.Y
        if not inPopup then
            closePopup()
        end
    end
end)

print("[Victoria] Intro Popup aktif.")
print("  WA  : " .. LINKS.whatsapp)
print("  DC  : " .. LINKS.discord)
