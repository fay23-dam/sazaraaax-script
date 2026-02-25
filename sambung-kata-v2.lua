-- =========================================================
-- ULTRA SMART AUTO KATA (RAYFIELD EDITION - FIXED STABLE)
-- =========================================================

local DEBUG_MODE = true
local SCRIPT_VERSION = "2.1.4"

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
    warn("[SambungKata] ❌ ERROR: "..tostring(msg))
    if err then warn("[SambungKata] Details: "..tostring(err)) end
end

-- ================================
-- PLATFORM
-- ================================
local UIS = game:GetService("UserInputService")
local function getPlatformName()
    local success, platform = pcall(function()
        return UIS:GetPlatform()
    end)
    if success then
        return tostring(platform)
    end
    return "PC"
end

local CURRENT_PLATFORM = getPlatformName()
log("Platform:", CURRENT_PLATFORM)

-- ================================
-- SAFE NOTIFY
-- ================================
local function safeNotify(title, text, duration)
    duration = duration or 5
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "[SambungKata] "..title,
            Text = text,
            Duration = duration
        })
    end)
end

-- ================================
-- LOAD RAYFIELD
-- ================================
local function loadRayfieldLibrary()
    log("Loading Rayfield...")

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
                    log("Rayfield loaded from:", url)
                    return lib
                end
            end
        end
    end

    return nil
end

-- ================================
-- MAIN
-- ================================
task.defer(function()

    log("Script v"..SCRIPT_VERSION.." started")

    local Rayfield = loadRayfieldLibrary()
    if not Rayfield then
        logError("Failed load Rayfield")
        return
    end

    -- PLAYER
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return end

    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end

    LocalPlayer.Character:WaitForChild("HumanoidRootPart", 15)

    -- SERVICES
    local RS = game:GetService("ReplicatedStorage")

    -- WORDLIST
    local wordList = RS:WaitForChild("WordList", 20)
    if not wordList then
        logError("WordList not found")
        return
    end

    local kataModule
    do
        local success, result = pcall(function()
            local mod = wordList:WaitForChild("IndonesianWords", 15)
            return require(mod)
        end)

        if success and type(result) == "table" then
            kataModule = result
        else
            logError("Failed require IndonesianWords", result)
            return
        end
    end

    log("Words loaded:", #kataModule)

    -- REMOTES
    local remotes = RS:WaitForChild("Remotes", 15)
    if not remotes then
        logError("Remotes missing")
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

    if not MatchUI or not SubmitWord then
        logError("Critical remotes missing")
        return
    end

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

    local usedWordsDropdown
    local statusParagraph

    local function addUsedWord(word)
        local w = string.lower(word)
        if not usedWords[w] then
            usedWords[w] = true
            table.insert(usedWordsList, word)
            if usedWordsDropdown then
                pcall(function()
                    usedWordsDropdown:Set(usedWordsList)
                end)
            end
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

        table.sort(results, function(a, b)
            return #a > #b
        end)

        return results
    end

    local function humanDelay()
        task.wait(math.random(config.minDelay, config.maxDelay) / 1000)
    end

    -- ================================
    -- AI
    -- ================================
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
                selectedWord = words[math.random(1, #words)]
            else
                local topN = math.max(1, math.floor(#words * (1 - config.aggression/100)))
                selectedWord = words[math.random(1, math.min(topN, #words))]
            end

            local currentWord = serverLetter
            local remain = selectedWord:sub(#serverLetter + 1)

            for i = 1, #remain do
                if not matchActive or not isMyTurn then
                    autoRunning = false
                    return
                end

                currentWord = currentWord .. remain:sub(i, i)

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
    -- UI (FIXED)
    -- ================================
    log("Creating UI...")

    local Window
    local success, result = pcall(function()
        return Rayfield:CreateWindow({
            Name = "Sambung-Kata v"..SCRIPT_VERSION,
            LoadingTitle = "Loading...",
            LoadingSubtitle = "Stable Edition",
            ConfigurationSaving = {Enabled = false}
        })
    end)

    if success and result then
        Window = result
    else
        logError("UI creation failed", result)
        return
    end

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
        Name = "Min Delay (ms)",
        Range = {10, 500},
        Increment = 5,
        CurrentValue = config.minDelay,
        Callback = function(v) config.minDelay = v end
    })

    MainTab:CreateSlider({
        Name = "Max Delay (ms)",
        Range = {20, 1000},
        Increment = 5,
        CurrentValue = config.maxDelay,
        Callback = function(v) config.maxDelay = v end
    })

    MainTab:CreateSlider({
        Name = "Aggression %",
        Range = {0, 100},
        Increment = 5,
        CurrentValue = config.aggression,
        Callback = function(v) config.aggression = v end
    })
        MainTab:CreateSlider({
        Name = "Min Word Length",
        Range = {2, 30},
        Increment = 1,
        CurrentValue = config.minLength,
        Callback = function(v)
            config.minLength = v
        end
    })

    MainTab:CreateSlider({
        Name = "Max Word Length",
        Range = {3, 50},
        Increment = 1,
        CurrentValue = config.maxLength,
        Callback = function(v)
            config.maxLength = v
        end
    })

    usedWordsDropdown = MainTab:CreateDropdown({
        Name = "Used Words",
        Options = {},
        CurrentOption = "",
        Callback = function() end
    })

    statusParagraph = MainTab:CreateParagraph({
        Title = "Status",
        Content = "Idle"
    })

    -- ================================
    -- REMOTE EVENTS
    -- ================================
    MatchUI.OnClientEvent:Connect(function(cmd, value)

        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
            usedWords = {}
            usedWordsList = {}
            if usedWordsDropdown then
                usedWordsDropdown:Set({})
            end

        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
            serverLetter = ""
            usedWords = {}
            usedWordsList = {}
            if usedWordsDropdown then
                usedWordsDropdown:Set({})
            end

        elseif cmd == "StartTurn" then
            if opponentStreamWord ~= "" then
                addUsedWord(opponentStreamWord)
                opponentStreamWord = ""
            end
            isMyTurn = true
            if autoEnabled then startUltraAI() end

        elseif cmd == "EndTurn" then
            isMyTurn = false

        elseif cmd == "UpdateServerLetter" then
            serverLetter = value or ""
        end

        if statusParagraph then
            statusParagraph:Set({
                Title = "Status",
                Content = "Match: "..(matchActive and "ON" or "OFF")..
                    " | Turn: "..(isMyTurn and "YOU" or "OPP")..
                    " | Letter: "..(serverLetter ~= "" and serverLetter or "-")
            })
        end
    end)

    if BillboardUpdate then
        BillboardUpdate.OnClientEvent:Connect(function(word)
            if matchActive and not isMyTurn then
                opponentStreamWord = word or ""
            end
        end)
    end

    if UsedWordWarn then
        UsedWordWarn.OnClientEvent:Connect(function(word)
            if word then
                addUsedWord(word)
                if autoEnabled and matchActive and isMyTurn then
                    task.wait(0.5)
                    startUltraAI()
                end
            end
        end)
    end

    log("Initialization complete")
    safeNotify("Ready", "Sambung-Kata Auto Loaded", 4)

end)
