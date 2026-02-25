-- =========================================================
-- ULTRA SMART AUTO KATA (RAYFIELD + GITHUB FINAL)
-- + Paragraph Opponent & Start Letter + Tab About
-- =========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then return end

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- LOAD WORDLIST FROM GITHUB
-- =========================================================
local function loadWordlist()
    local url = "https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/Dump_IndonesianWords.lua"

    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not success then
        warn("Gagal download wordlist")
        return nil
    end

    response = response:gsub("return%s*%[", "return {")
    response = response:gsub("%]%s*$", "}")

    local chunk = loadstring(response)
    local result = chunk()

    local filtered = {}
    local blacklist = {dumped=true, by=true}

    for _, word in ipairs(result) do
        local w = tostring(word):lower()
        if #w > 1 and not blacklist[w] then
            table.insert(filtered, w)
        end
    end

    print("Wordlist Loaded:", #filtered)
    return filtered
end

local kataModule = loadWordlist()
if not kataModule then return end

-- =========================================================
-- REMOTES
-- =========================================================
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
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12
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

local function resetUsedWords()
    usedWords = {}
    usedWordsList = {}
    if usedWordsDropdown then
        usedWordsDropdown:Set({})
    end
end

local function getSmartWords(prefix)
    prefix = string.lower(prefix)
    local results = {}

    for _, word in ipairs(kataModule) do
        if word:sub(1, #prefix) == prefix then
            if not isUsed(word) then
                local len = #word
                if len >= config.minLength and len <= config.maxLength then
                    table.insert(results, word)
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
-- AUTO ENGINE (FULL WORKING VERSION)
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
-- UI
-- =========================================================
local Window = Rayfield:CreateWindow({
    Name = "Sambung-kata",
    LoadingTitle = "Loading Gui...",
    LoadingSubtitle = "Full Working Version",
    ConfigurationSaving = {Enabled = false}
})

-- Tab Main
local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
    Name = "Aktifkan Auto",
    CurrentValue = false,
    Callback = function(Value)
        autoEnabled = Value
        if Value then startUltraAI() end
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
    Range = {100, 1000},
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
    Range = {1, 2},
    Increment = 1,
    CurrentValue = config.minLength,
    Callback = function(Value)
        config.minLength = Value
    end
})

MainTab:CreateSlider({
    Name = "Max Word Length",
    Range = {5, 20},
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

-- PARAGRAPHS UNTUK INFORMASI OPPONENT DAN KATA START
local opponentParagraph = MainTab:CreateParagraph({
    Title = "Status Opponent",
    Content = "Menunggu...",
})

local startLetterParagraph = MainTab:CreateParagraph({
    Title = "Kata Start",
    Content = "-",
})

-- Fungsi update paragraph dengan konversi tostring untuk keamanan
local function updateOpponentStatus()
    local content = ""
    if matchActive then
        if isMyTurn then
            content = "Giliran Anda"
        else
            if opponentStreamWord and opponentStreamWord ~= "" then
                content = "Opponent mengetik: " .. tostring(opponentStreamWord)
            else
                content = "Giliran Opponent"
            end
        end
    else
        content = "Match tidak aktif"
    end
    opponentParagraph:Set({
        Title = "Status Opponent",
        Content = tostring(content)
    })
end

local function updateStartLetter()
    local content = ""
    if serverLetter and serverLetter ~= "" then
        content = "Kata Start: " .. tostring(serverLetter)
    else
        content = "Kata Start: -"
    end
    startLetterParagraph:Set({
        Title = "Kata Start",
        Content = tostring(content)
    })
end

-- Tab About
local AboutTab = Window:CreateTab("About")

AboutTab:CreateParagraph({
    Title = "Informasi Script",
    Content = "Auto Kata\nVersi: 2.0\nby sazaraaax\nFitur: Auto play dengan wordlist Indonesia\n\nthanks to danzzy1we for the indonesian dictionary",
})

AboutTab:CreateParagraph({
    Title = "Cara Penggunaan",
    Content = "1. Aktifkan toggle Auto\n2. Atur delay dan agresivitas\n3. Mulai permainan\n4. Script akan otomatis menjawab",
})

AboutTab:CreateParagraph({
    Title = "Catatan",
    Content = "Pastikan koneksi stabil\nJika ada error, coba reload",
})

-- =========================================================
-- REMOTE EVENTS
-- =========================================================
MatchUI.OnClientEvent:Connect(function(cmd, value)

    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        updateOpponentStatus()
        updateStartLetter()

    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        updateOpponentStatus()
        updateStartLetter()

    elseif cmd == "StartTurn" then
        if opponentStreamWord ~= "" then
            addUsedWord(opponentStreamWord)
            opponentStreamWord = ""
        end

        isMyTurn = true
        updateOpponentStatus()
        if autoEnabled then
            startUltraAI()
        end

    elseif cmd == "EndTurn" then
        isMyTurn = false
        updateOpponentStatus()

    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
        updateStartLetter()
    end
end)

BillboardUpdate.OnClientEvent:Connect(function(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
        updateOpponentStatus()
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

-- Inisialisasi paragraph awal
updateOpponentStatus()
updateStartLetter()

print("Script loaded with opponent & start paragraphs and About tab")
