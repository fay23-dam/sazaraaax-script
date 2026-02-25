-- =========================================================
-- ULTRA SMART AUTO KATA (OPTIMIZED MOBILE & 80K WORDS)
-- =========================================================

local DEBUG_MODE = true
local SCRIPT_VERSION = "2.3.0"

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ================================
-- LOADING SCREEN (STAYS UNTIL UI READY)
-- ================================
local loadingGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
loadingGui.Name = "SK_Loading"
loadingGui.IgnoreGuiInset = true

local textLabel = Instance.new("TextLabel", loadingGui)
textLabel.Size = UDim2.new(1,0,1,0)
textLabel.BackgroundTransparency = 0.5
textLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
textLabel.TextColor3 = Color3.fromRGB(255,255,255)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextScaled = true
textLabel.Text = "Initializing Sambung-Kata..."

local function removeLoading()
    if loadingGui then loadingGui:Destroy() end
end

-- ================================
-- UTIL & LOGIC
-- ================================
local kataModule = nil
local usedWords = {}
local matchActive, isMyTurn = false, false
local serverLetter = ""
local autoEnabled, autoRunning = false, false

local config = {
    minDelay = 35, maxDelay = 150,
    aggression = 50, minLength = 3, maxLength = 20
}

-- Fungsi Pencarian Cepat (Recursive)
local function fastFind(parent, name)
    return parent:FindFirstChild(name, true)
end

-- Optimasi Pencarian 80k Kata (Anti-Lag)
local function getSmartWords(prefix)
    if not kataModule then return {} end
    local results = {}
    prefix = prefix:lower()

    for _, word in ipairs(kataModule) do
        local w = tostring(word):lower()
        if w:sub(1, #prefix) == prefix then
            if not usedWords[w] and #w >= config.minLength and #w <= config.maxLength then
                table.insert(results, w)
            end
        end
        -- Batasi iterasi agar HP tidak freeze (ambil 100 kandidat saja)
        if #results >= 100 then break end
    end
    
    table.sort(results, function(a,b) return #a > #b end)
    return results
end

-- ================================
-- MAIN EXECUTION
-- ================================
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    -- 1. LOAD RAYFIELD DULU (Agar UI muncul instan)
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "Sambung-Kata v"..SCRIPT_VERSION,
        LoadingTitle = "Mobile Stable",
        LoadingSubtitle = "by Gemini",
        ConfigurationSaving = {Enabled = false}
    })

    local MainTab = Window:CreateTab("Main")

    -- 2. BACKGROUND LOADING (Data & Remotes)
    task.spawn(function()
        textLabel.Text = "Searching WordList (80k words)..."
        local mod = fastFind(RS, "IndonesianWords")
        if mod then
            local success, res = pcall(require, mod)
            if success then 
                kataModule = res 
                Rayfield:Notify({Title = "Database Ready", Content = #kataModule.." words loaded!", Duration = 5})
            end
        end
        removeLoading()
    end)

    -- UI Elements (Logika Asli Anda)
    MainTab:CreateToggle({
        Name = "Aktifkan Auto",
        CurrentValue = false,
        Callback = function(v) autoEnabled = v end
    })

    MainTab:CreateSlider({Name = "Aggression %", Range = {0,100}, Increment = 5, CurrentValue = config.aggression, Callback = function(v) config.aggression = v end})
    MainTab:CreateSlider({Name = "Min Length", Range = {2,30}, Increment = 1, CurrentValue = config.minLength, Callback = function(v) config.minLength = v end})
    MainTab:CreateSlider({Name = "Max Length", Range = {3,50}, Increment = 1, CurrentValue = config.maxLength, Callback = function(v) config.maxLength = v end})
    MainTab:CreateSlider({Name = "Min Delay (ms)", Range = {10,500}, Increment = 5, CurrentValue = config.minDelay, Callback = function(v) config.minDelay = v end})

    -- 3. REMOTE HANDLERS
    local remotes = fastFind(RS, "Remotes")
    if remotes then
        local SubmitWord = remotes:FindFirstChild("SubmitWord")
        local MatchUI = remotes:FindFirstChild("MatchUI")
        local BillboardUpdate = remotes:FindFirstChild("BillboardUpdate")
        local BillboardEnd = remotes:FindFirstChild("BillboardEnd")
        local TypeSound = remotes:FindFirstChild("TypeSound")

        local function startUltraAI()
            if autoRunning or not autoEnabled or not matchActive or not isMyTurn or serverLetter == "" then return end
            autoRunning = true

            task.spawn(function()
                task.wait(math.random(config.minDelay, config.maxDelay)/1000)
                local words = getSmartWords(serverLetter)
                if #words == 0 then autoRunning = false return end

                local selectedWord = (config.aggression >= 80) and words[1] or words[math.random(1, #words)]
                local currentWord = serverLetter

                for i = #serverLetter + 1, #selectedWord do
                    if not matchActive or not isMyTurn then break end
                    currentWord = selectedWord:sub(1, i)
                    if TypeSound then TypeSound:FireServer() end
                    if BillboardUpdate then BillboardUpdate:FireServer(currentWord) end
                    task.wait(0.05) -- Human typing speed
                end

                if isMyTurn then
                    SubmitWord:FireServer(selectedWord)
                    usedWords[selectedWord:lower()] = true
                end
                autoRunning = false
            end)
        end

        -- Listeners
        MatchUI.OnClientEvent:Connect(function(data)
            if data and data.Letter then
                serverLetter = data.Letter
                matchActive = true
                isMyTurn = (data.TurnPlayer == LocalPlayer.Name)
                if isMyTurn then startUltraAI() end
            end
        end)

        BillboardEnd.OnClientEvent:Connect(function()
            matchActive = false
            isMyTurn = false
            usedWords = {}
        end)
    end
end)
                
                if isMyTurn then startAI() end
            else
                matchActive = false
            end
        end)
        
        -- Reset kata yang terpakai jika match berakhir
        remotes:FindFirstChild("BillboardEnd").OnClientEvent:Connect(function()
            usedWords = {}
            matchActive = false
        end)
    end
end)
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
