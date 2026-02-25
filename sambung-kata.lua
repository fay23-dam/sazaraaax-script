loadstring(game:HttpGet('https://raw.githubusercontent.com/fay23-dam/sazaraaax-script/refs/heads/main/sambung-kata.lua'))()

-- =========================================================
-- ULTRA SMART AUTO KATA (RAYFIELD EDITION - MOBILE SAFE)
-- DENGAN PENANGANAN ERROR DAN FALLBACK URL
-- =========================================================

-- ================================
-- FUNGSI UNTUK LOAD RAYFIELD DENGAN FALLBACK
-- ================================
local Rayfield = nil
local function loadRayfield()
    -- Daftar URL cadangan (fallback)
    local urls = {
        'https://sirius.menu/rayfield',  -- URL utama
        'https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source', -- Fallback ke raw GitHub
    }

    for i, url in ipairs(urls) do
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)

        if success and result then
            local loadSuccess, lib = pcall(loadstring, result)
            if loadSuccess and lib then
                Rayfield = lib
                print("✅ Rayfield berhasil dimuat dari: " .. url)
                return true
            else
                warn("⚠️ Gagal mengkompilasi Rayfield dari: " .. url)
            end
        else
            warn("⚠️ Gagal mengunduh Rayfield dari: " .. url)
        end
        task.wait(1) -- Jeda sebentar sebelum coba URL berikutnya
    end
    return false
end

-- Panggil fungsi untuk memuat Rayfield
if not loadRayfield() then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fatal Error",
        Text = "Tidak dapat memuat library Rayfield. Periksa koneksi internet Anda.",
        Duration = 10
    })
    return
end

-- ================================
-- SERVICES
-- ================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ================================
-- LOAD MODULE
-- ================================
local wordList = ReplicatedStorage:FindFirstChild("WordList")
if not wordList then
    Rayfield:Notify({
        Title = "Error",
        Content = "WordList tidak ditemukan!",
        Duration = 5
    })
    return
end

-- Gunakan pcall untuk menghindari error jika IndonesianWords tidak ada
local kataModule
local success, module = pcall(function()
    return require(wordList:WaitForChild("IndonesianWords"))
end)

if not success or not module then
    Rayfield:Notify({
        Title = "Error",
        Content = "Gagal memuat modul IndonesianWords!",
        Duration = 5
    })
    return
end
kataModule = module

-- ================================
-- REMOTES
-- ================================
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- =========================================================
-- STATE
-- =========================================================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

local usedWords = {}
local usedWordsList = {}
local opponentStreamWord = ""

local autoEnabled = false
local autoRunning = false

local config = {
    minDelay = 35,
    maxDelay = 150,
    aggression = 50,
    minLength = 3,
    maxLength = 20
}

-- =========================================================
-- HELPERS
-- =========================================================
local function isUsed(word)
    return usedWords[string.lower(word)] == true
end

local usedWordsDropdown

local function addUsedWord(word)
    local w = string.lower(word)
    if not usedWords[w] then
        usedWords[w] = true
        table.insert(usedWordsList, word)

        if usedWordsDropdown then
            usedWordsDropdown:Set(usedWordsList)
        end
    end
end

local function getSmartWords(prefix)
    prefix = string.lower(prefix)
    local results = {}

    for _, word in ipairs(kataModule) do
        local w = tostring(word)
        if string.sub(string.lower(w), 1, #prefix) == prefix then
            if not isUsed(w) then
                local len = #w
                if len >= config.minLength and len <= config.maxLength then
                    table.insert(results, w)
                end
            end
        end
    end

    table.sort(results, function(a, b)
        return #a > #b
    end)

    return results
end

local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then min = max end
    task.wait(math.random(min, max) / 1000)
end

-- =========================================================
-- SMART AUTO ENGINE
-- =========================================================
local function startUltraAI()
    if autoRunning then return end
    if not autoEnabled then return end
    if not matchActive or not isMyTurn then return end
    if serverLetter == "" then return end

    autoRunning = true

    task.spawn(function()
        humanDelay()

        local words = getSmartWords(serverLetter)
        if #words == 0 then
            autoRunning = false
            return
        end

        local selectedWord

        if config.aggression >= 100 then
            selectedWord = words[1]
        elseif config.aggression <= 0 then
            selectedWord = words[math.random(1, #words)]
        else
            local topN = math.max(1, math.floor(#words * (1 - config.aggression/100)))
            topN = math.min(topN, #words)
            selectedWord = words[math.random(1, topN)]
        end

        if not selectedWord then
            autoRunning = false
            return
        end

        local currentWord = serverLetter
        local remain = selectedWord:sub(#serverLetter + 1)

        for i = 1, #remain do
            if not matchActive or not isMyTurn then
                autoRunning = false
                return
            end

            currentWord = currentWord .. remain:sub(i, i)

            TypeSound:FireServer()
            BillboardUpdate:FireServer(currentWord)

            humanDelay()
        end

        humanDelay()

        SubmitWord:FireServer(selectedWord)
        addUsedWord(selectedWord)

        humanDelay()
        BillboardEnd:FireServer()

        autoRunning = false
    end)
end

-- =========================================================
-- UI RAYFIELD
-- =========================================================
local Window = Rayfield:CreateWindow({
    Name = "Sambung-kata by Sazaraaax",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Rayfield Edition (Stable)",
    ConfigurationSaving = {
        Enabled = false
    }
})

local MainTab = Window:CreateTab("Main", 4483345998)

MainTab:CreateToggle({
    Name = "Aktifkan Auto",
    CurrentValue = false,
    Callback = function(Value)
        autoEnabled = Value
        if Value then
            startUltraAI()
        end
    end
})

MainTab:CreateSlider({
    Name = "Min Delay (ms)",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = config.minDelay,
    Callback = function(Value)
        config.minDelay = Value
    end
})

MainTab:CreateSlider({
    Name = "Max Delay (ms)",
    Range = {20, 1000},
    Increment = 5,
    CurrentValue = config.maxDelay,
    Callback = function(Value)
        config.maxDelay = Value
    end
})

MainTab:CreateSlider({
    Name = "Aggression",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = config.aggression,
    Callback = function(Value)
        config.aggression = Value
    end
})

MainTab:CreateSlider({
    Name = "Min Word Length",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = config.minLength,
    Callback = function(Value)
        config.minLength = Value
    end
})

MainTab:CreateSlider({
    Name = "Max Word Length",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = config.maxLength,
    Callback = function(Value)
        config.maxLength = Value
    end
})

usedWordsDropdown = MainTab:CreateDropdown({
    Name = "Used Words",
    Options = usedWordsList,
    CurrentOption = "",
    Callback = function() end
})

local statusParagraph = MainTab:CreateParagraph({
    Title = "Status",
    Content = "Idle"
})

-- =========================================================
-- REMOTE EVENTS
-- =========================================================
MatchUI.OnClientEvent:Connect(function(cmd, value)

    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        usedWords = {}
        usedWordsList = {}
        usedWordsDropdown:Set({})

    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        usedWords = {}
        usedWordsList = {}
        usedWordsDropdown:Set({})

    elseif cmd == "StartTurn" then
        if opponentStreamWord ~= "" then
            addUsedWord(opponentStreamWord)
            opponentStreamWord = ""
        end

        isMyTurn = true
        if autoEnabled then
            startUltraAI()
        end

    elseif cmd == "EndTurn" then
        isMyTurn = false

    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
    end

    statusParagraph:Set({
        Title = "Status",
        Content = "Match: "..tostring(matchActive)..
        " | Turn: "..(isMyTurn and "You" or "Opponent")..
        " | Start: "..serverLetter
    })
end)

BillboardUpdate.OnClientEvent:Connect(function(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
    end
end)

UsedWordWarn.OnClientEvent:Connect(function(word)
    if word then
        addUsedWord(word)

        if autoEnabled and matchActive and isMyTurn then
            humanDelay()
            startUltraAI()
        end
    end
end)

-- Notifikasi sukses
Rayfield:Notify({
    Title = "Sukses",
    Content = "Script siap digunakan! 🚀",
    Duration = 3
})
