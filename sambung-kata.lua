-- =========================================================
-- ULTRA SMART AUTO KATA (HUMANIZED EDITION) - FIXED VERSION
-- =========================================================

-- Load Orion Library dengan penanganan error yang lebih baik
local OrionLib = (function()
    local url = "https://raw.githubusercontent.com/jensonhirst/Orion/main/source"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then
        return result
    else
        warn("Gagal memuat Orion Library:", result)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Gagal memuat Orion Library.\nCek koneksi atau URL.",
            Duration = 5
        })
        return nil
    end
end)()

-- Jika gagal, hentikan eksekusi
if not OrionLib then
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Pastikan WordList dan IndonesianWords ada
local wordList = ReplicatedStorage:FindFirstChild("WordList")
if not wordList then
    OrionLib:MakeNotification({
        Name = "Error",
        Content = "WordList tidak ditemukan!",
        Time = 5
    })
    return
end

local kataModule = require(wordList:WaitForChild("IndonesianWords"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")

local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- =========================================================
-- STATE & KONFIGURASI
-- =========================================================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

local usedWords = {}          -- set untuk pengecekan cepat
local usedWordsList = {}      -- array untuk dropdown (agar terurut)
local opponentStreamWord = ""
local lastSubmittedWord = nil

local autoEnabled = false
local autoRunning = false

-- Konfigurasi user (default)
local config = {
    minDelay = 35,        -- ms
    maxDelay = 150,       -- ms
    aggression = 50,      -- 0 = acak, 100 = selalu terpanjang
    minLength = 3,
    maxLength = 20
}

-- =========================================================
-- PERFORMANCE HELPERS
-- =========================================================

local function isUsed(word)
    return usedWords[string.lower(word)] == true
end

-- Menambahkan kata ke daftar used (untuk dropdown)
local function addUsedWord(word)
    local w = string.lower(word)
    if not usedWords[w] then
        usedWords[w] = true
        table.insert(usedWordsList, word)
        -- Update dropdown jika sudah dibuat
        if usedWordsDropdown then
            usedWordsDropdown:Refresh(usedWordsList, true) -- true = pilih default kosong
        end
    end
end

-- ⚡ Pencarian kata dengan filter panjang
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

    -- Urutkan berdasarkan panjang (terpanjang dulu)
    table.sort(results, function(a, b)
        return #a > #b
    end)

    return results
end

-- 🕒 Delay manusia berdasarkan slider
local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then min = max end
    task.wait(math.random(min, max) / 1000)
end

-- =========================================================
-- SMART AUTO ENGINE (dengan aggression & bluff)
-- =========================================================
local function startUltraAI()
    if autoRunning then return end
    if not autoEnabled then return end
    if not matchActive or not isMyTurn then return end
    if serverLetter == "" then return end

    autoRunning = true

    task.spawn(function()
        humanDelay() -- reaksi awal

        local words = getSmartWords(serverLetter)
        if #words == 0 then
            autoRunning = false
            return
        end

        -- 🎲 Pilih kata berdasarkan aggression
        local selectedWord
        if config.aggression >= 100 then
            selectedWord = words[1]  -- terpanjang
        elseif config.aggression <= 0 then
            selectedWord = words[math.random(1, #words)]  -- acak total
        else
            -- Hitung top N: makin tinggi aggression, makin sedikit opsi
            local topN = math.max(1, math.floor(#words * (1 - config.aggression/100)))
            topN = math.min(topN, #words)
            selectedWord = words[math.random(1, topN)]
        end

        if not selectedWord or isUsed(selectedWord) then
            autoRunning = false
            return
        end

        -- Simulasi mengetik huruf per huruf
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

            humanDelay() -- jeda antar huruf
        end

        -- Validasi akhir
        if not isUsed(selectedWord) then
            humanDelay() -- jeda sebelum submit

            lastSubmittedWord = selectedWord
            SubmitWord:FireServer(selectedWord)

            addUsedWord(selectedWord) -- masukkan ke daftar used

            humanDelay()
            BillboardEnd:FireServer()
        end

        autoRunning = false
    end)
end

-- =========================================================
-- UI (Orion)
-- =========================================================
local Window = OrionLib:MakeWindow({
    Name = "Sambung-kata by Sazaraaax",
    SaveConfig = false,
    IntroText = "by sazaraaax"
})

local Tab = Window:MakeTab({ Name = "Main" })

-- Toggle utama
Tab:AddToggle({
    Name = "Aktifkan Auto",
    Default = false,
    Callback = function(v)
        autoEnabled = v
        if v then
            startUltraAI()
        end
    end
})

-- Slider min delay
Tab:AddSlider({
    Name = "Min Delay (ms)",
    Min = 10,
    Max = 500,
    Default = config.minDelay,
    Increment = 5,
    Callback = function(v)
        config.minDelay = v
    end
})

-- Slider max delay
Tab:AddSlider({
    Name = "Max Delay (ms)",
    Min = 20,
    Max = 1000,
    Default = config.maxDelay,
    Increment = 5,
    Callback = function(v)
        config.maxDelay = v
    end
})

-- Slider aggression (0 = acak, 100 = selalu terpanjang)
Tab:AddSlider({
    Name = "Aggression (0 = random, 100 = longest)",
    Min = 0,
    Max = 100,
    Default = config.aggression,
    Increment = 5,
    Callback = function(v)
        config.aggression = v
    end
})

-- Slider min panjang kata
Tab:AddSlider({
    Name = "Min Word Length",
    Min = 1,
    Max = 10,
    Default = config.minLength,
    Increment = 1,
    Callback = function(v)
        config.minLength = v
    end
})

-- Slider max panjang kata
Tab:AddSlider({
    Name = "Max Word Length",
    Min = 5,
    Max = 30,
    Default = config.maxLength,
    Increment = 1,
    Callback = function(v)
        config.maxLength = v
    end
})

-- Dropdown kata yang telah digunakan
local usedWordsDropdown = Tab:AddDropdown({
    Name = "Used Words",
    Options = usedWordsList,
    Default = "",
    Callback = function() end -- tidak perlu aksi
})

-- Label status
local statusLabel = Tab:AddLabel("Status: Idle")

-- =========================================================
-- REMOTE EVENT HANDLERS
-- =========================================================
MatchUI.OnClientEvent:Connect(function(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        usedWords = {}
        usedWordsList = {}
        if usedWordsDropdown then
            usedWordsDropdown:Refresh(usedWordsList, true)
        end

    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        usedWords = {}
        usedWordsList = {}
        if usedWordsDropdown then
            usedWordsDropdown:Refresh(usedWordsList, true)
        end

    elseif cmd == "StartTurn" then
        -- Simpan kata lawan saat turn pindah
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

    statusLabel:Set(
        "Match: " .. tostring(matchActive) ..
        " | Turn: " .. (isMyTurn and "You" or "Opponent") ..
        " | Start: " .. serverLetter
    )
end)

-- Stream tulisan lawan (untuk mendeteksi kata yang sedang diketik)
BillboardUpdate.OnClientEvent:Connect(function(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
    end
end)

-- Jika server menolak kata (kata sudah dipakai)
UsedWordWarn.OnClientEvent:Connect(function(word)
    if word then
        addUsedWord(word)

        -- Coba cari kata lain jika masih giliran kita
        if autoEnabled and matchActive and isMyTurn then
            humanDelay()
            startUltraAI()
        end
    end
end)

-- Kata yang kita submit sendiri juga masuk used (untung jaga-jaga)
-- sebenarnya sudah ditambahkan di startUltraAI, tapi jika ada remote lain yang memicu, kita tangkap
-- (tidak ada event khusus, jadi kita andalkan dari UsedWordWarn dan internal)

OrionLib:Init()
