-- =========================================================
-- ULTRA SMART AUTO KATA (ANDROID SAFE EDITION)
-- =========================================================

-- ================================
-- MOBILE FIX DETECTION
-- ================================
local UIS = game:GetService("UserInputService")
if UIS.TouchEnabled then
    getgenv().OrionTouchFix = true
end

-- ================================
-- LOAD ORION (OFFICIAL VERSION)
-- ================================
local OrionLib = loadstring(game:HttpGet(
"https://raw.githubusercontent.com/shlexware/Orion/main/source"
))()

if not OrionLib then
    warn("Orion gagal dimuat")
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
    OrionLib:MakeNotification({
        Name = "Error",
        Content = "WordList tidak ditemukan!",
        Time = 5
    })
    return
end

local kataModule = require(wordList:WaitForChild("IndonesianWords"))

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
-- STATE & KONFIG
-- =========================================================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

local usedWords = {}
local usedWordsList = {}
local opponentStreamWord = ""
local lastSubmittedWord = nil

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

        if usedWordsDropdown and usedWordsDropdown.Refresh then
            usedWordsDropdown:Refresh(usedWordsList, true)
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

        lastSubmittedWord = selectedWord
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
local Window = OrionLib:MakeWindow({
    Name = "Sambung-kata by Sazaraaax",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998"
})

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

Tab:AddSlider({
    Name = "Aggression",
    Min = 0,
    Max = 100,
    Default = config.aggression,
    Increment = 5,
    Callback = function(v)
        config.aggression = v
    end
})

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

usedWordsDropdown = Tab:AddDropdown({
    Name = "Used Words",
    Default = "",
    Options = usedWordsList,
    Callback = function() end
})

local statusLabel = Tab:AddLabel("Status: Idle")

-- =========================================================
-- REMOTE HANDLERS
-- =========================================================
MatchUI.OnClientEvent:Connect(function(cmd, value)

    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        usedWords = {}
        usedWordsList = {}
        usedWordsDropdown:Refresh(usedWordsList, true)

    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        usedWords = {}
        usedWordsList = {}
        usedWordsDropdown:Refresh(usedWordsList, true)

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

    statusLabel:Set(
        "Match: "..tostring(matchActive)..
        " | Turn: "..(isMyTurn and "You" or "Opponent")..
        " | Start: "..serverLetter
    )
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

OrionLib:Init()

-- ================================
-- ANDROID FRAME FORCE ACTIVE FIX
-- ================================
if UIS.TouchEnabled then
    for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
        if v:IsA("Frame") then
            v.Active = true
        end
    end
end
