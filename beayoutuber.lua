-- ═══════════════════════════════════════════════════════════════
-- 🎬 Auto Be a YouTuber - WindUI Version (Dropdown Collect/Upload)
-- ✅ PlaceId Check | Auto | Sell | Rebirth | Event | Player
-- ═══════════════════════════════════════════════════════════════

-- ✅ 1. CEK GAME ID
local targetGameId = 120564326011184
if game.PlaceId ~= targetGameId then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚠️ Game Tidak Cocok",
        Text = "Script ini hanya untuk:\nPlaceId: " .. targetGameId .. "\n\nKamu sedang di: " .. game.PlaceId,
        Duration = 7
    })
    task.defer(function()
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character then
            player:Kick("🔒 Script terminated: Wrong game ID")
        end
    end)
    return
end

-- ✅ 2. LOAD WIND UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ✅ 3. CREATE WINDOW
local Window = WindUI:CreateWindow({
    Title = "Auto Be a YouTuber",
    Author = "by Sazaraaax",
    Folder = "BeAYouTuber",
    Size = UDim2.fromOffset(620, 500),
    Theme = "Dark",
    Resizable = true,
    HideSearchBar = true,
})

-- ✅ Set keybind untuk toggle GUI (RightShift)
Window:SetToggleKey(Enum.KeyCode.X)

-- ✅ 4. CREATE TABS
local Tabs = {
    Auto = Window:Tab({ Title = "Auto", Icon = "calendar-sync" }),
    Sell = Window:Tab({ Title = "Sell", Icon = "dollar-sign" }),
    Rebirth = Window:Tab({ Title = "Rebirth", Icon = "refresh-cw" }),
    Event = Window:Tab({ Title = "Event", Icon = "calendar" }),
    Player = Window:Tab({ Title = "Player", Icon = "user" })
}

-- ✅ 5. VARIABEL GLOBAL
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ============================================================
-- 🔓 AKTIFKAN SEMUA GAMEPASS VALUES MILIK PLAYER
-- ============================================================
local success, gamepassFolder = pcall(function()
    return player:FindFirstChild("gamepassValues")
end)

if success and gamepassFolder then
    for _, child in ipairs(gamepassFolder:GetChildren()) do
        pcall(function()
            child.Value = true
        end)
    end
    print("✅ Semua gamepassValues telah diaktifkan")
else
    warn("⚠️ Folder gamepassValues tidak ditemukan")
end

-- ============================================================
-- 🔧 FUNGSI KONVERSI ANGKA
-- ============================================================
local function convertToFullNumber(text)
    if not text or text == "" then return 0 end
    text = string.upper(text)
    text = text:gsub(",", "")
    text = text:gsub("%s+", "")
    text = text:gsub("COST:", "")
    text = text:gsub("REBIRTHS:", "")
    text = text:gsub("COUNT:", "")
    text = text:gsub("X", "")

    local number, suffix = text:match("([%d%.]+)([KMBT]?)")
    number = tonumber(number)

    if not number then return 0 end

    if suffix == "K" then
        return math.floor(number * 1e3)
    elseif suffix == "M" then
        return math.floor(number * 1e6)
    elseif suffix == "B" then
        return math.floor(number * 1e9)
    elseif suffix == "T" then
        return math.floor(number * 1e12)
    else
        return math.floor(number)
    end
end

local function formatNumber(num)
    if num >= 1e12 then
        return string.format("%.2fT", num/1e12)
    elseif num >= 1e9 then
        return string.format("%.2fB", num/1e9)
    elseif num >= 1e6 then
        return string.format("%.2fM", num/1e6)
    elseif num >= 1e3 then
        return string.format("%.2fK", num/1e3)
    else
        return tostring(num)
    end
end

-- ============================================================
-- 📊 REBIRTH INFO
-- ============================================================
local rebirthFullNumber = 0
local rebirthInfoParagraph = nil

local function parseRebirthInfo()
    local costVal = "N/A"
    local countVal = "0"
    
    local success, result = pcall(function()
        local rebirthMenu = player:FindFirstChild("PlayerGui") 
            and player.PlayerGui:FindFirstChild("ScreenGui") 
            and player.PlayerGui.ScreenGui:FindFirstChild("menus") 
            and player.PlayerGui.ScreenGui.menus:FindFirstChild("rebirthMenu")
        
        if rebirthMenu then
            local infRebirthsButton = rebirthMenu:FindFirstChild("infRebirthsButton")
            if infRebirthsButton then
                local costFrame = infRebirthsButton:FindFirstChild("cost")
                if costFrame and costFrame:IsA("TextLabel") then
                    costVal = costFrame.Text
                elseif costFrame and costFrame:FindFirstChildOfClass("TextLabel") then
                    costVal = costFrame:FindFirstChildOfClass("TextLabel").Text
                end
                
                local rebirthsFrame = infRebirthsButton:FindFirstChild("rebirths")
                if rebirthsFrame and rebirthsFrame:IsA("TextLabel") then
                    countVal = rebirthsFrame.Text
                elseif rebirthsFrame and rebirthsFrame:FindFirstChildOfClass("TextLabel") then
                    countVal = rebirthsFrame:FindFirstChildOfClass("TextLabel").Text
                end
            end
        end
    end)
    
    if not success then
        costVal = "Error"
        countVal = "N/A"
    end
    
    local costFull = convertToFullNumber(costVal)
    rebirthFullNumber = convertToFullNumber(countVal)
    
    local content = string.format("💰 Cost: %s (%s)\n🔄 Rebirths: %s\n🔢 Nilai dikirim: %s", 
        costVal, formatNumber(costFull), countVal, formatNumber(rebirthFullNumber))
    
    if rebirthInfoParagraph then
        rebirthInfoParagraph:SetDesc(content)
    end
    
    return costVal, countVal, rebirthFullNumber
end

-- ============================================================
-- 🔄 TAB: AUTO (DROPDOWN UNTUK COLLECT/UPLOAD)
-- ============================================================
local events = ReplicatedStorage:FindFirstChild("events")
local toggleAutoEvent = events and events:FindFirstChild("toggleAuto")
local claimAllEvent = events and events:FindFirstChild("claimAll")

if not toggleAutoEvent or not claimAllEvent then
    warn("⚠️ Events 'toggleAuto' atau 'claimAll' tidak ditemukan")
end

-- Variabel kontrol
local autoCollectState = false
local autoUploadState = false
local autoClaimEnabled = false
local claimInterval = 30
local claimLoopRunning = false

-- Fungsi untuk mengirim toggle ke server
local function setAutoCollect(state)
    if toggleAutoEvent then
        toggleAutoEvent:FireServer("autoCollect", state)
        autoCollectState = state
    end
end

local function setAutoUpload(state)
    if toggleAutoEvent then
        toggleAutoEvent:FireServer("autoUpload", state)
        autoUploadState = state
    end
end

-- Handler dropdown
local function handleDropdownChange(selection)
    if selection == "None" then
        setAutoCollect(false)
        setAutoUpload(false)
    elseif selection == "Auto Collect Only" then
        setAutoCollect(true)
        setAutoUpload(false)
    elseif selection == "Auto Upload Only" then
        setAutoCollect(false)
        setAutoUpload(true)
    elseif selection == "Both" then
        setAutoCollect(true)
        setAutoUpload(true)
    end
end

-- Dropdown mode
local modeDropdown = Tabs.Auto:Dropdown({
    Title = "Auto Collect & Upload",
    Desc = "Pilih fitur yang ingin diaktifkan",
    Values = {"None", "Auto Collect Only", "Auto Upload Only", "Both"},
    Value = "None",
    Callback = function(selected)
        handleDropdownChange(selected)
        WindUI:Notify({
            Title = "Auto Mode",
            Content = "Mode berubah: " .. selected,
            Duration = 2,
        })
    end,
})

-- Toggle Auto Claim + Slider Interval
local ClaimToggle = Tabs.Auto:Toggle({
    Title = "Auto Claim",
    Desc = "Klaim otomatis setiap interval",
    Value = false,
    Callback = function(v)
        autoClaimEnabled = v
        if v then
            if not claimLoopRunning then
                claimLoopRunning = true
                task.spawn(function()
                    while autoClaimEnabled do
                        if claimAllEvent then
                            claimAllEvent:FireServer()
                        end
                        local start = tick()
                        while autoClaimEnabled and (tick() - start < claimInterval) do
                            task.wait(0.5)
                        end
                    end
                    claimLoopRunning = false
                end)
            end
            WindUI:Notify({ Title = "Auto Claim", Content = "Dimulai • Interval: " .. claimInterval .. "s", Duration = 3 })
        else
            WindUI:Notify({ Title = "Auto Claim", Content = "Dihentikan", Duration = 3 })
        end
    end
})

local ClaimSlider = Tabs.Auto:Slider({
    Title = "Interval Claim (detik)",
    Value = { Min = 60, Max = 120, Default = 60 },
    Callback = function(v)
        claimInterval = v
    end
})

-- Tombol manual claim
Tabs.Auto:Button({
    Title = "Claim Sekarang",
    Desc = "Jalankan claim satu kali",
    Callback = function()
        if claimAllEvent then
            claimAllEvent:FireServer()
            WindUI:Notify({ Title = "Claim", Content = "Perintah dikirim", Duration = 2 })
        else
            WindUI:Notify({ Title = "Error", Content = "Event claimAll tidak ditemukan", Duration = 5 })
        end
    end
})

-- ============================================================
-- 💰 TAB: SELL
-- ============================================================
local youtuberData = player:FindFirstChild("youtuberData")
local gearsData = player:FindFirstChild("gearsData")

Tabs.Sell:Paragraph({
    Title = "📺 Jual Youtuber",
    Desc = "Jual youtuber yang dimiliki untuk mendapatkan koin."
})

-- Dapatkan daftar youtuber
local youtuberList = {}
if youtuberData and youtuberData:FindFirstChild("youtubers") then
    for _, youtuber in ipairs(youtuberData.youtubers:GetChildren()) do
        table.insert(youtuberList, youtuber.Name)
    end
end
if #youtuberList == 0 then
    table.insert(youtuberList, "Tidak ada youtuber")
end

local YoutuberDropdown = Tabs.Sell:Dropdown({
    Title = "Pilih Youtuber",
    Desc = "Pilih youtuber yang akan dijual",
    Values = youtuberList,
    Value = youtuberList[1],
})

Tabs.Sell:Button({
    Title = "💰 Jual Youtuber Terpilih",
    Desc = "Jual youtuber yang dipilih",
    Callback = function()
        local selected = YoutuberDropdown.Value
        if selected and selected ~= "Tidak ada youtuber" then
            local sellEvent = events and events:FindFirstChild("sellYoutuber")
            if sellEvent then
                sellEvent:FireServer(selected)
                WindUI:Notify({ Title = "Jual Youtuber", Content = selected .. " berhasil dijual!", Duration = 3 })
                
                -- Refresh dropdown setelah jual
                task.wait(0.5)
                local newList = {}
                if youtuberData and youtuberData:FindFirstChild("youtubers") then
                    for _, youtuber in ipairs(youtuberData.youtubers:GetChildren()) do
                        table.insert(newList, youtuber.Name)
                    end
                end
                if #newList == 0 then
                    table.insert(newList, "Tidak ada youtuber")
                end
                YoutuberDropdown:Refresh(newList)
                YoutuberDropdown:Set(newList[1])
            else
                WindUI:Notify({ Title = "Error", Content = "Event 'sellYoutuber' tidak ditemukan!", Duration = 5 })
            end
        else
            WindUI:Notify({ Title = "Peringatan", Content = "Pilih youtuber terlebih dahulu!", Duration = 3 })
        end
    end
})

Tabs.Sell:Button({
    Title = "🔥 Jual Semua Youtuber",
    Desc = "Jual semua youtuber sekaligus",
    Callback = function()
        local sellAllEvent = events and events:FindFirstChild("sellAll")
        if sellAllEvent then
            sellAllEvent:FireServer(false)  -- false untuk youtuber
            WindUI:Notify({ Title = "Jual Semua", Content = "Semua youtuber terjual!", Duration = 3 })
            
            task.wait(0.5)
            local newList = {}
            if youtuberData and youtuberData:FindFirstChild("youtubers") then
                for _, youtuber in ipairs(youtuberData.youtubers:GetChildren()) do
                    table.insert(newList, youtuber.Name)
                end
            end
            if #newList == 0 then
                table.insert(newList, "Tidak ada youtuber")
            end
            YoutuberDropdown:Refresh(newList)
            YoutuberDropdown:Set(newList[1])
        else
            WindUI:Notify({ Title = "Error", Content = "Event 'sellAll' tidak ditemukan!", Duration = 5 })
        end
    end
})

Tabs.Sell:Paragraph({
    Title = "⚙️ Jual Gear",
    Desc = "Jual gear yang dimiliki."
})

-- Daftar gear
local gearList = {}
if gearsData and gearsData:FindFirstChild("gears") then
    for _, gear in ipairs(gearsData.gears:GetChildren()) do
        table.insert(gearList, gear.Name)
    end
end
if #gearList == 0 then
    table.insert(gearList, "Tidak ada gear")
end

local GearDropdown = Tabs.Sell:Dropdown({
    Title = "Pilih Gear",
    Desc = "Pilih gear yang akan dijual",
    Values = gearList,
    Value = gearList[1],
})

Tabs.Sell:Button({
    Title = "💰 Jual Gear Terpilih",
    Desc = "Jual gear yang dipilih",
    Callback = function()
        local selected = GearDropdown.Value
        if selected and selected ~= "Tidak ada gear" then
            local sellEvent = events and events:FindFirstChild("sellYoutuber")
            if sellEvent then
                sellEvent:FireServer(selected, true)  -- true untuk gear
                WindUI:Notify({ Title = "Jual Gear", Content = selected .. " berhasil dijual!", Duration = 3 })
                
                task.wait(0.5)
                local newList = {}
                if gearsData and gearsData:FindFirstChild("gears") then
                    for _, gear in ipairs(gearsData.gears:GetChildren()) do
                        table.insert(newList, gear.Name)
                    end
                end
                if #newList == 0 then
                    table.insert(newList, "Tidak ada gear")
                end
                GearDropdown:Refresh(newList)
                GearDropdown:Set(newList[1])
            else
                WindUI:Notify({ Title = "Error", Content = "Event 'sellYoutuber' tidak ditemukan!", Duration = 5 })
            end
        else
            WindUI:Notify({ Title = "Peringatan", Content = "Pilih gear terlebih dahulu!", Duration = 3 })
        end
    end
})

Tabs.Sell:Button({
    Title = "🔥 Jual Semua Gear",
    Desc = "Jual semua gear sekaligus",
    Callback = function()
        local sellAllEvent = events and events:FindFirstChild("sellAll")
        if sellAllEvent then
            sellAllEvent:FireServer(true)  -- true untuk gear
            WindUI:Notify({ Title = "Jual Semua Gear", Content = "Semua gear terjual!", Duration = 3 })
            
            task.wait(0.5)
            local newList = {}
            if gearsData and gearsData:FindFirstChild("gears") then
                for _, gear in ipairs(gearsData.gears:GetChildren()) do
                    table.insert(newList, gear.Name)
                end
            end
            if #newList == 0 then
                table.insert(newList, "Tidak ada gear")
            end
            GearDropdown:Refresh(newList)
            GearDropdown:Set(newList[1])
        else
            WindUI:Notify({ Title = "Error", Content = "Event 'sellAll' tidak ditemukan!", Duration = 5 })
        end
    end
})

Tabs.Sell:Button({
    Title = "🔄 Refresh Daftar",
    Desc = "Perbarui dropdown youtuber dan gear",
    Callback = function()
        -- Refresh youtuber
        local newYList = {}
        if youtuberData and youtuberData:FindFirstChild("youtubers") then
            for _, youtuber in ipairs(youtuberData.youtubers:GetChildren()) do
                table.insert(newYList, youtuber.Name)
            end
        end
        if #newYList == 0 then table.insert(newYList, "Tidak ada youtuber") end
        YoutuberDropdown:Refresh(newYList)
        YoutuberDropdown:Set(newYList[1])

        -- Refresh gear
        local newGList = {}
        if gearsData and gearsData:FindFirstChild("gears") then
            for _, gear in ipairs(gearsData.gears:GetChildren()) do
                table.insert(newGList, gear.Name)
            end
        end
        if #newGList == 0 then table.insert(newGList, "Tidak ada gear") end
        GearDropdown:Refresh(newGList)
        GearDropdown:Set(newGList[1])

        WindUI:Notify({ Title = "Refresh", Content = "Daftar berhasil diperbarui!", Duration = 2 })
    end
})

-- ============================================================
-- 🔄 TAB: REBIRTH
-- ============================================================
Tabs.Rebirth:Paragraph({
    Title = "Informasi Rebirth",
    Desc = "Data akan diperbarui otomatis setiap detik.\nCek konsol (F9) untuk nilai detail."
})

-- Buat paragraph untuk info (akan diupdate)
rebirthInfoParagraph = Tabs.Rebirth:Paragraph({
    Title = "Info Terkini",
    Desc = "Mengambil data..."
})

-- Tombol Rebirth Now
Tabs.Rebirth:Button({
    Title = "🔄 Rebirth Sekarang",
    Desc = "Lakukan rebirth dengan jumlah rebirth saat ini (nilai penuh)",
    Callback = function()
        parseRebirthInfo()
        if rebirthFullNumber and rebirthFullNumber > 0 then
            local rebirthEvent = events and events:FindFirstChild("rebirth")
            if rebirthEvent then
                rebirthEvent:FireServer(rebirthFullNumber)
                WindUI:Notify({ 
                    Title = "Rebirth", 
                    Content = "Rebirth " .. formatNumber(rebirthFullNumber) .. " dikirim!", 
                    Duration = 3 
                })
                task.wait(1)
                parseRebirthInfo()
            else
                WindUI:Notify({ Title = "Error", Content = "Event 'rebirth' tidak ditemukan!", Duration = 5 })
            end
        else
            WindUI:Notify({ 
                Title = "Peringatan", 
                Content = "Tidak dapat menentukan jumlah rebirth. Periksa menu rebirth.", 
                Duration = 3 
            })
        end
    end
})

Tabs.Rebirth:Button({
    Title = "🔄 Refresh Info",
    Desc = "Perbarui data biaya dan jumlah rebirth",
    Callback = function()
        parseRebirthInfo()
        WindUI:Notify({ Title = "Refresh", Content = "Info rebirth diperbarui!", Duration = 2 })
    end
})

-- Loop update otomatis
task.spawn(function()
    while true do
        task.wait(1)
        parseRebirthInfo()
    end
end)

-- ============================================================
-- 🎁 TAB: EVENT
-- ============================================================
Tabs.Event:Paragraph({
    Title = "Auto Submit",
    Desc = "Jalankan submit all secara otomatis untuk event."
})

local autoSubmitEnabled = false
local submitInterval = 10
local submitLoopRunning = false

local function submitAll()
    local submitEvent = events and events:FindFirstChild("submitAll")
    if not submitEvent then
        WindUI:Notify({ Title = "Error", Content = "Event 'submitAll' tidak ditemukan!", Duration = 5 })
        return false
    end
    submitEvent:FireServer()
    return true
end

local SubmitToggle = Tabs.Event:Toggle({
    Title = "Auto Submit All",
    Desc = "Kirim submit all otomatis",
    Value = false,
    Callback = function(v)
        autoSubmitEnabled = v
        if v then
            if not submitLoopRunning then
                submitLoopRunning = true
                task.spawn(function()
                    while autoSubmitEnabled do
                        submitAll()
                        local start = tick()
                        while autoSubmitEnabled and (tick() - start < submitInterval) do
                            task.wait(0.5)
                        end
                    end
                    submitLoopRunning = false
                end)
            end
            WindUI:Notify({ Title = "Auto Submit", Content = "Dimulai • Interval: " .. submitInterval .. "s", Duration = 3 })
        else
            WindUI:Notify({ Title = "Auto Submit", Content = "Dihentikan", Duration = 3 })
        end
    end
})

local SubmitSlider = Tabs.Event:Slider({
    Title = "Interval Submit (detik)",
    Value = { Min = 1, Max = 60, Default = 10 },
    Callback = function(v)
        submitInterval = v
    end
})

Tabs.Event:Button({
    Title = "Submit Sekarang",
    Desc = "Jalankan submit all satu kali",
    Callback = function()
        if submitAll() then
            WindUI:Notify({ Title = "Submit", Content = "Perintah submitAll dikirim", Duration = 2 })
        end
    end
})

Tabs.Event:Button({
    Title = "Buka Event Egg",
    Desc = "Buka telur event",
    Callback = function()
        local openEvent = events and events:FindFirstChild("openEventEgg")
        if openEvent then
            openEvent:FireServer(true)
            WindUI:Notify({ Title = "Event Egg", Content = "Dibuka! 🥚", Duration = 3 })
        else
            WindUI:Notify({ Title = "Error", Content = "Event 'openEventEgg' tidak ditemukan", Duration = 5 })
        end
    end
})

-- ============================================================
-- 👤 TAB: PLAYER
-- ============================================================
local flyEnabled = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

local FlyToggle = Tabs.Player:Toggle({
    Title = "Fly Mode",
    Desc = "WASD + Space/Shift untuk kontrol.",
    Value = false,
    Callback = function(v)
        flyEnabled = v
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        if flyEnabled then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Parent = rootPart

            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
            bodyGyro.Parent = rootPart

            local uis = game:GetService("UserInputService")
            local camera = workspace.CurrentCamera

            flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not flyEnabled or not character or not rootPart or not bodyVelocity or not bodyGyro then return end

                local moveDirection = Vector3.new(0,0,0)
                
                if uis:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection + Vector3.new(0,-1,0) end

                if moveDirection.Magnitude > 0 then moveDirection = moveDirection.Unit end
                bodyVelocity.Velocity = moveDirection * 50
                bodyGyro.CFrame = camera.CFrame
            end)

            humanoid.PlatformStand = true
        else
            if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
            if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
            if humanoid then humanoid.PlatformStand = false end
        end
    end
})

-- Handle respawn
player.CharacterAdded:Connect(function(character)
    if flyEnabled then
        task.wait(0.5)
        -- Re-activate fly
        flyEnabled = false
        FlyToggle:Set(false)
        FlyToggle:Set(true) -- trigger callback
    end
end)

local WalkSpeedSlider = Tabs.Player:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 100, Default = 16 },
    Callback = function(v)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = v end
        end
    end
})

-- Terapkan saat respawn
player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = WalkSpeedSlider.Value
    end
end)

local JumpPowerSlider = Tabs.Player:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 200, Default = 50 },
    Callback = function(v)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = v
            end
        end
    end
})

player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = JumpPowerSlider.Value
    end
end)

Tabs.Player:Button({
    Title = "⛔ Matikan Semua Auto",
    Desc = "Nonaktifkan semua fitur auto (mode, claim, submit)",
    Callback = function()
        -- Set dropdown ke None
        if modeDropdown then
            modeDropdown:Set("None")
        end
        -- Matikan auto claim
        autoClaimEnabled = false
        ClaimToggle:Set(false)
        -- Matikan auto submit
        autoSubmitEnabled = false
        SubmitToggle:Set(false)
        WindUI:Notify({ Title = "Info", Content = "Semua fitur auto dimatikan", Duration = 3 })
    end
})

Tabs.Player:Paragraph({
    Title = "👨‍💻 Credits",
    Desc = "Script by Sazaraaax\nFitur: Auto, Sell, Rebirth, Event, Player\nDimigrasi ke WindUI"
})

-- ============================================================
-- 💾 SAVE/LOAD CONFIG (SEDERHANA)
-- ============================================================
local CONFIG_FILE = "autoyoutuber_config.json"
local CAN_SAVE = pcall(function() readfile("test.txt") end) and true or false

local function saveConfig()
    if not CAN_SAVE then
        WindUI:Notify({ Title = "Save Config", Content = "File I/O tidak didukung", Duration = 3 })
        return
    end
    local data = {
        mode = modeDropdown.Value,
        claimInterval = claimInterval,
        autoClaim = autoClaimEnabled,
        submitInterval = submitInterval,
        autoSubmit = autoSubmitEnabled,
        walkSpeed = WalkSpeedSlider.Value,
        jumpPower = JumpPowerSlider.Value,
        fly = flyEnabled,
    }
    local json = HttpService:JSONEncode(data)
    pcall(function() writefile(CONFIG_FILE, json) end)
    WindUI:Notify({ Title = "Config", Content = "Pengaturan disimpan", Duration = 2 })
end

local function loadConfig()
    if not CAN_SAVE then return end
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or not raw then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end

    if data.mode then modeDropdown:Set(data.mode) end
    if data.claimInterval then 
        claimInterval = data.claimInterval
        ClaimSlider:Set(data.claimInterval)
    end
    if data.autoClaim ~= nil then ClaimToggle:Set(data.autoClaim) end
    if data.submitInterval then
        submitInterval = data.submitInterval
        SubmitSlider:Set(data.submitInterval)
    end
    if data.autoSubmit ~= nil then SubmitToggle:Set(data.autoSubmit) end
    if data.walkSpeed then WalkSpeedSlider:Set(data.walkSpeed) end
    if data.jumpPower then JumpPowerSlider:Set(data.jumpPower) end
    if data.fly then FlyToggle:Set(data.fly) end

    WindUI:Notify({ Title = "Config", Content = "Pengaturan dimuat", Duration = 2 })
end

-- Tombol save/load di tab Player (opsional)
Tabs.Player:Button({
    Title = "💾 Simpan Pengaturan",
    Desc = "Simpan konfigurasi ke file (jika support)",
    Callback = saveConfig
})

Tabs.Player:Button({
    Title = "📂 Muat Pengaturan",
    Desc = "Muat konfigurasi dari file",
    Callback = loadConfig
})

-- ============================================================
-- 🚀 FINAL INIT
-- ============================================================
task.spawn(function()
    task.wait(1)
    loadConfig()
    parseRebirthInfo()
    WindUI:Notify({
        Title = "✅ Siap",
        Content = "Script siap digunakan!",
        Duration = 5
    })
end)
