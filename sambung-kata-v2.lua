-- =========================================================
-- ULTRA SMART AUTO KATA (RAYFIELD EDITION - CROSS PLATFORM)
-- STABLE + DEBUG SYSTEM + MOBILE SAFE
-- =========================================================

-- ================================
-- CONFIG & DEBUG
-- ================================
local DEBUG_MODE = true  -- Ubah ke false untuk production
local SCRIPT_VERSION = "2.1.0"

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
-- SAFE NOTIFY (Fallback jika Rayfield gagal)
-- ================================
local function safeNotify(title, text, duration)
    duration = duration or 5
    local success, err = pcall(function()
        if _G.RayfieldSafe and type(_G.RayfieldSafe) == "table" and _G.RayfieldSafe.Notify then
            _G.RayfieldSafe:Notify({Title = title, Content = text, Duration = duration})
        else
            -- Fallback ke StarterGui
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "[SambungKata] "..title,
                Text = text,
                Duration = duration
            })
        end
    end)
    if not success then
        logError("Notify failed", err)
    end
end

-- ================================
-- LOAD RAYFIELD DENGAN FALLBACK + ERROR HANDLING
-- ================================
local function loadRayfieldLibrary()
    log("🔄 Loading Rayfield library...")
    
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source",
        "https://raw.githubusercontent.com/infyiff/backup/main/rayfield.lua",
    }
    
    for idx, url in ipairs(urls) do
        url = url:Trim()  -- Hapus spasi!
        log("🔍 Attempt #"..idx..": "..url)
        
        local success, result = pcall(function()
            return game:HttpGet(url, true)  -- true = ignore cache
        end)
        
        if not success then
            log("⚠️ HTTP GET failed: "..tostring(result))
            task.wait(1)
            continue
        end
        
        if not result or #result < 50 then
            log("⚠️ Response too short or empty")
            task.wait(1)
            continue
        end
        
        -- Compile & Execute
        local compileSuccess, chunk = pcall(loadstring, result)
        if not compileSuccess or not chunk then
            log("⚠️ Compile failed: "..tostring(chunk))
            task.wait(1)
            continue
        end
        
        -- Execute: bisa return function atau table
        local execSuccess, lib = pcall(chunk)
        if not execSuccess then
            log("⚠️ Execution failed: "..tostring(lib))
            task.wait(1)
            continue
        end
        
        -- Handle jika lib adalah function (perlu dipanggil lagi)
        if type(lib) == "function" then
            local exec2Success, executed = pcall(lib)
            if exec2Success and executed and type(executed) == "table" then
                log("✅ Rayfield loaded (double-exec) from: "..url)
                return executed
            end
        elseif type(lib) == "table" then
            log("✅ Rayfield loaded from: "..url)
            return lib
        end
        
        log("⚠️ Unknown return type: "..type(lib))
        task.wait(1)
    end
    
    log("❌ All Rayfield URLs failed!")
    return nil
end

-- ================================
-- MAIN EXECUTION (Deferred untuk timing aman)
-- ================================
task.defer(function()
    log("🚀 Script v"..SCRIPT_VERSION.." started | Platform: "..(game:GetPlatform() or "Unknown"))
    log("⏱️ Time: "..os.date("%H:%M:%S"))
    
    -- 1. Load Rayfield
    local Rayfield = loadRayfieldLibrary()
    if not Rayfield then
        logError("Fatal: Cannot load Rayfield")
        safeNotify("Fatal Error", "Gagal load UI library. Cek koneksi/executor.", 10)
        return
    end
    _G.RayfieldSafe = Rayfield  -- Simpan untuk safeNotify
    
    -- 2. Tunggu Player & Character ready (PENTING untuk mobile)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        logError("LocalPlayer is nil!")
        return
    end
    
    -- Tunggu character jika belum ada
    if not LocalPlayer.Character then
        log("⏳ Waiting for character...")
        local success, char = pcall(function()
            return LocalPlayer.CharacterAdded:Wait()
        end)
        if not success or not char then
            logError("CharacterAdded timeout")
            return
        end
    end
    
    -- Tunggu HumanoidRootPart (indikator character fully loaded)
    local hrpSuccess, hrp = pcall(function()
        return LocalPlayer.Character:WaitForChild("HumanoidRootPart", 15)
    end)
    if not hrpSuccess or not hrp then
        logError("HumanoidRootPart not found - game mungkin belum ready")
        safeNotify("Warning", "Character belum fully loaded. Coba execute ulang.", 7)
        return
    end
    
    -- Delay kecil tambahan untuk mobile executor
    if game:GetPlatform() == "Android" or game:GetPlatform() == "IOS" then
        log("📱 Mobile detected, adding extra delay...")
        task.wait(2)
    end
    
    log("✅ Player & Character ready")
    
    -- 3. Load Services
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    if not ReplicatedStorage:IsLoaded() then
        log("⏳ Waiting for ReplicatedStorage...")
        ReplicatedStorage.Loaded:Wait()
    end
    
    -- 4. Load WordList Module
    log("🔍 Searching WordList...")
    local wordList = ReplicatedStorage:WaitForChild("WordList", 20)
    if not wordList then
        logError("WordList not found after 20s")
        safeNotify("Error", "WordList tidak ditemukan. Join ulang game.", 8)
        return
    end
    log("✅ WordList found")
    
    local kataModule, moduleErr = pcall(function()
        local mod = wordList:WaitForChild("IndonesianWords", 15)
        if not mod then error("IndonesianWords timeout") end
        return require(mod)
    end)
    
    if not kataModule or not moduleErr then
        logError("Failed to require IndonesianWords: "..tostring(moduleErr))
        safeNotify("Error", "Gagal load kamus kata!", 7)
        return
    end
    log("✅ IndonesianWords loaded | Total: "..#kataModule.." words")
    
    -- 5. Load Remotes dengan timeout
    log("🔗 Loading remotes...")
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
    if not remotes then
        logError("Remotes not found!")
        safeNotify("Error", "Remotes tidak ditemukan!", 6)
        return
    end
    
    local function getRemote(name, timeout)
        timeout = timeout or 10
        local remote = remotes:WaitForChild(name, timeout)
        if not remote then
            logError("Remote timeout: "..name)
            return nil
        end
        log("✅ Remote: "..name)
        return remote
    end
    
    local MatchUI = getRemote("MatchUI")
    local SubmitWord = getRemote("SubmitWord")
    local BillboardUpdate = getRemote("BillboardUpdate")
    local BillboardEnd = getRemote("BillboardEnd")
    local TypeSound = getRemote("TypeSound")
    local UsedWordWarn = getRemote("UsedWordWarn")
    
    if not MatchUI or not SubmitWord then
        logError("Critical remotes missing!")
        safeNotify("Error", "Remote penting tidak ditemukan!", 8)
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
    log("⚙️ Config loaded")
    
    -- ================================
    -- HELPERS
    -- ================================
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
            log("📝 Used: "..word.." (Total: "..#usedWordsList..")")
            if usedWordsDropdown then
                pcall(function() usedWordsDropdown:Set(usedWordsList) end)
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
        table.sort(results, function(a, b) return #a > #b end)
        return results
    end
    
    local function humanDelay()
        local min = math.max(10, config.minDelay)
        local max = math.max(min, config.maxDelay)
        task.wait(math.random(min, max) / 1000)
    end
    
    -- ================================
    -- AI ENGINE
    -- ================================
    local function startUltraAI()
        if autoRunning or not autoEnabled or not matchActive or not isMyTurn or serverLetter == "" then
            return
        end
        autoRunning = true
        log("🤖 AI started | Letter: '"..serverLetter.."'")
        
        task.spawn(function()
            humanDelay()
            local words = getSmartWords(serverLetter)
            
            if #words == 0 then
                log("⚠️ No words found for: "..serverLetter)
                safeNotify("Info", "Tidak ada kata untuk '"..serverLetter.."'", 3)
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
            
            if not selectedWord then autoRunning = false; return end
            log("✅ Selected: "..selectedWord)
            
            local currentWord = serverLetter
            local remain = selectedWord:sub(#serverLetter + 1)
            
            for i = 1, #remain do
                if not matchActive or not isMyTurn then autoRunning = false; return end
                currentWord = currentWord .. remain:sub(i, i)
                pcall(function() TypeSound:FireServer() end)
                pcall(function() BillboardUpdate:FireServer(currentWord) end)
                humanDelay()
            end
            
            humanDelay()
            local submitSuccess, submitErr = pcall(function()
                SubmitWord:FireServer(selectedWord)
            end)
            
            if submitSuccess then
                addUsedWord(selectedWord)
                log("✅ Word submitted")
            else
                logError("Submit failed", submitErr)
                safeNotify("Error", "Gagal submit kata", 4)
            end
            
            humanDelay()
            pcall(function() BillboardEnd:FireServer() end)
            autoRunning = false
            log("🏁 Turn complete")
        end)
    end
    
    -- ================================
    -- RAYFIELD UI (Dengan Error Handling)
    -- ================================
    log("🎨 Creating UI...")
    local Window, uiErr = pcall(function()
        return Rayfield:CreateWindow({
            Name = "Sambung-kata v"..SCRIPT_VERSION,
            LoadingTitle = "Loading...",
            LoadingSubtitle = "Cross-Platform Edition",
            ConfigurationSaving = {Enabled = false}
        })
    end)
    
    if not uiErr or not Window then
        logError("UI creation failed", uiErr)
        safeNotify("UI Error", "Gagal buat menu. Script tetap jalan!", 10)
        -- Script tetap jalan tanpa UI
    else
        log("✅ UI created")
        local MainTab = Window:CreateTab("Main", 4483345998)
        
        MainTab:CreateToggle({
            Name = "Aktifkan Auto",
            CurrentValue = false,
            Callback = function(v)
                autoEnabled = v
                log("🔘 Auto: "..tostring(v))
                if v then startUltraAI() end
            end
        })
        
        MainTab:CreateSlider({Name = "Min Delay (ms)", Range = {10, 500}, Increment = 5, CurrentValue = config.minDelay, Callback = function(v) config.minDelay = v end})
        MainTab:CreateSlider({Name = "Max Delay (ms)", Range = {20, 1000}, Increment = 5, CurrentValue = config.maxDelay, Callback = function(v) config.maxDelay = v end})
        MainTab:CreateSlider({Name = "Aggression %", Range = {0, 100}, Increment = 5, CurrentValue = config.aggression, Callback = function(v) config.aggression = v end})
        MainTab:CreateSlider({Name = "Min Length", Range = {1, 10}, Increment = 1, CurrentValue = config.minLength, Callback = function(v) config.minLength = v end})
        MainTab:CreateSlider({Name = "Max Length", Range = {5, 30}, Increment = 1, CurrentValue = config.maxLength, Callback = function(v) config.maxLength = v end})
        
        usedWordsDropdown = MainTab:CreateDropdown({Name = "Used Words", Options = {}, CurrentOption = "", Callback = function() end})
        statusParagraph = MainTab:CreateParagraph({Title = "Status", Content = "Idle"})
    end
    
    -- ================================
    -- REMOTE EVENTS
    -- ================================
    if MatchUI then
        MatchUI.OnClientEvent:Connect(function(cmd, value)
            log("📨 Event: "..cmd, value)
            
            if cmd == "ShowMatchUI" then
                matchActive, isMyTurn = true, false
                usedWords, usedWordsList = {}, {}
                if usedWordsDropdown then pcall(function() usedWordsDropdown:Set({}) end) end
                log("🎮 Match started")
                
            elseif cmd == "HideMatchUI" then
                matchActive, isMyTurn, serverLetter = false, false, ""
                usedWords, usedWordsList = {}, {}
                if usedWordsDropdown then pcall(function() usedWordsDropdown:Set({}) end) end
                log("🔚 Match ended")
                
            elseif cmd == "StartTurn" then
                if opponentStreamWord ~= "" then addUsedWord(opponentStreamWord); opponentStreamWord = "" end
                isMyTurn = true
                log("🔄 Your turn")
                if autoEnabled then startUltraAI() end
                
            elseif cmd == "EndTurn" then
                isMyTurn = false
                log("⏸️ Opponent turn")
                
            elseif cmd == "UpdateServerLetter" then
                serverLetter = value or ""
                log("🔤 Letter: '"..serverLetter.."'")
            end
            
            if statusParagraph then
                pcall(function()
                    statusParagraph:Set({
                        Title = "Status",
                        Content = string.format("Match: %s | Turn: %s | Letter: %s",
                            matchActive and "ON" or "OFF",
                            isMyTurn and "YOU" or "OPP",
                            serverLetter ~= "" and serverLetter or "-")
                    })
                end)
            end
        end)
    end
    
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
                log("⚠️ Used: "..word)
                addUsedWord(word)
                if autoEnabled and matchActive and isMyTurn then
                    task.wait(0.5)
                    startUltraAI()
                end
            end
        end)
    end
    
    -- ================================
    -- FINAL NOTIFICATION
    -- ================================
    log("✨ Initialization complete!")
    safeNotify("✅ Ready", "Sambung-Kata Auto v"..SCRIPT_VERSION.." loaded!", 4)
    
    -- Console summary
    print([[
╔══════════════════════════════════╗
║  Sambung-Kata Auto by Sazaraaax  ║
║  Version: ]]..SCRIPT_VERSION..[[                   ║
║  Platform: ]]..(game:GetPlatform() or "Unknown")..[[
║  Words: ]]..string.format("%04d", #kataModule)..[[                   ║
║  Debug: ]]..(DEBUG_MODE and "ON" or "OFF")..[[                        ║
║  Status: ✅ ACTIVE              ║
╚══════════════════════════════════╝
    ]])
end)
