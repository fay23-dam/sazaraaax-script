-- =========================================================
-- ULTRA SMART AUTO KATA (RAYFIELD EDITION - MOBILE FIXED)
-- =========================================================

local DEBUG_MODE = true
local SCRIPT_VERSION = "2.2.0"

-- ================================
-- LOADING SCREEN (CENTER TEXT)
-- ================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "SK_Loading"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1,0,1,0)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = Color3.fromRGB(255,255,255)
textLabel.Font = Enum.Font.GothamBold
textLabel.Text = "Loading Sambung-Kata..."
textLabel.Parent = loadingGui

loadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function removeLoading()
    if loadingGui then
        loadingGui:Destroy()
    end
end

-- ================================
-- UTIL
-- ================================
local function trim(str)
    if not str or type(str) ~= "string" then return "" end
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

local function log(...)
    if DEBUG_MODE then
        local parts = {"[SambungKata]"}
        for _, v in ipairs({...}) do
            table.insert(parts, tostring(v))
        end
        print(table.concat(parts, " "))
    end
end

local function logError(msg, err)
    warn("[SambungKata] ❌ "..tostring(msg))
    if err then warn("[SambungKata] Details:", err) end
end

-- ================================
-- SAFE WAIT FUNCTION (MOBILE FIX)
-- ================================
local function waitForReplicatedChild(parent, name, timeout)
    timeout = timeout or 60
    local start = tick()

    while tick() - start < timeout do
        local obj = parent:FindFirstChild(name)
        if obj then
            return obj
        end
        task.wait(1)
    end

    return nil
end

-- ================================
-- START
-- ================================
task.defer(function()

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    task.wait(2) -- mobile safety delay

    local UIS = game:GetService("UserInputService")
    local RS = game:GetService("ReplicatedStorage")

    -- ================================
    -- LOAD RAYFIELD
    -- ================================
    local function loadRayfield()
        local urls = {
            "https://sirius.menu/rayfield",
            "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source"
        }

        for _, url in ipairs(urls) do
            local success, result = pcall(function()
                return game:HttpGet(trim(url), true)
            end)

            if success and result and #result > 100 then
                local compileSuccess, chunk = pcall(loadstring, result)
                if compileSuccess and chunk then
                    local execSuccess, lib = pcall(chunk)
                    if execSuccess and type(lib) == "table" then
                        return lib
                    end
                end
            end
        end
        return nil
    end

    local Rayfield = loadRayfield()
    if not Rayfield then
        logError("Failed load Rayfield")
        removeLoading()
        return
    end

    -- ================================
    -- SAFE WORDLIST LOAD
    -- ================================
    textLabel.Text = "Loading WordList..."

    local wordList = waitForReplicatedChild(RS, "WordList", 60)
    if not wordList then
        logError("WordList not found")
        textLabel.Text = "WordList not found!\nRejoin game."
        task.wait(5)
        removeLoading()
        return
    end

    local kataModule
    do
        local success, result = pcall(function()
            local mod = waitForReplicatedChild(wordList, "IndonesianWords", 30)
            if mod then
                return require(mod)
            end
        end)

        if success and type(result) == "table" then
            kataModule = result
        else
            logError("Failed require IndonesianWords")
            removeLoading()
            return
        end
    end

    -- ================================
    -- REMOTES
    -- ================================
    textLabel.Text = "Loading Remotes..."

    local remotes = waitForReplicatedChild(RS, "Remotes", 60)
    if not remotes then
        logError("Remotes not found")
        removeLoading()
        return
    end

    local function getRemote(name)
        return remotes:FindFirstChild(name)
    end

    local MatchUI = getRemote("MatchUI")
    local SubmitWord = getRemote("SubmitWord")
    local BillboardUpdate = getRemote("BillboardUpdate")
    local BillboardEnd = getRemote("BillboardEnd")
    local TypeSound = getRemote("TypeSound")
    local UsedWordWarn = getRemote("UsedWordWarn")

    -- ================================
    -- STATE
    -- ================================
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

    local function isUsed(word)
        return usedWords[string.lower(word)] == true
    end

    local function addUsedWord(word)
        local w = string.lower(word)
        if not usedWords[w] then
            usedWords[w] = true
            table.insert(usedWordsList, word)
        end
    end

    local function getSmartWords(prefix)
        local results = {}
        prefix = string.lower(prefix)

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

        table.sort(results, function(a,b)
            return #a > #b
        end)

        return results
    end

    local function humanDelay()
        task.wait(math.random(config.minDelay, config.maxDelay)/1000)
    end

    local function startUltraAI()
        if autoRunning or not autoEnabled or not matchActive or not isMyTurn or serverLetter == "" then
            return
        end

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
                selectedWord = words[math.random(1,#words)]
            else
                local topN = math.max(1, math.floor(#words * (1 - config.aggression/100)))
                selectedWord = words[math.random(1, math.min(topN,#words))]
            end

            local currentWord = serverLetter
            local remain = selectedWord:sub(#serverLetter + 1)

            for i=1,#remain do
                if not matchActive or not isMyTurn then
                    autoRunning = false
                    return
                end

                currentWord = currentWord .. remain:sub(i,i)

                if TypeSound then
                    pcall(function() TypeSound:FireServer() end)
                end

                if BillboardUpdate then
                    pcall(function()
                        BillboardUpdate:FireServer(currentWord)
                    end)
                end

                humanDelay()
            end

            pcall(function()
                SubmitWord:FireServer(selectedWord)
            end)

            addUsedWord(selectedWord)

            if BillboardEnd then
                pcall(function()
                    BillboardEnd:FireServer()
                end)
            end

            autoRunning = false
        end)
    end

    -- ================================
    -- UI
    -- ================================
    textLabel.Text = "Creating UI..."

    local Window = Rayfield:CreateWindow({
        Name = "Sambung-Kata v"..SCRIPT_VERSION,
        LoadingTitle = "Loading...",
        LoadingSubtitle = "Mobile Stable",
        ConfigurationSaving = {Enabled = false}
    })

    local MainTab = Window:CreateTab("Main")

    MainTab:CreateToggle({
        Name = "Aktifkan Auto",
        CurrentValue = false,
        Callback = function(v)
            autoEnabled = v
            if v then startUltraAI() end
        end
    })

    MainTab:CreateSlider({
        Name = "Min Word Length",
        Range = {2,30},
        Increment = 1,
        CurrentValue = config.minLength,
        Callback = function(v) config.minLength = v end
    })

    MainTab:CreateSlider({
        Name = "Max Word Length",
        Range = {3,50},
        Increment = 1,
        CurrentValue = config.maxLength,
        Callback = function(v) config.maxLength = v end
    })

    MainTab:CreateSlider({
        Name = "Aggression %",
        Range = {0,100},
        Increment = 5,
        CurrentValue = config.aggression,
        Callback = function(v) config.aggression = v end
    })

    MainTab:CreateSlider({
        Name = "Min Delay (ms)",
        Range = {10,500},
        Increment = 5,
        CurrentValue = config.minDelay,
        Callback = function(v) config.minDelay = v end
    })

    MainTab:CreateSlider({
        Name = "Max Delay (ms)",
        Range = {20,1000},
        Increment = 5,
        CurrentValue = config.maxDelay,
        Callback = function(v) config.maxDelay = v end
    })

    removeLoading()

    log("Initialization complete")

end)
