-- =========================================================
-- ULTRA SMART AUTO KATA (ANTI LUAOBFUSCATOR V2 BUILD FULL)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end
if _G.DestroySazaraaaxRunner then
    pcall(function()
        _G.DestroySazaraaaxRunner()
    end)
end
if math.random() < 1 then
    pcall(function()
    
    loadstring(game:HttpGet("https://raw.githubusercontent.com/danzzy1we/gokil2/refs/heads/main/copylinkgithub.lua"))()
    
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fay23-dam/sazaraaax-script/refs/heads/main/testing-button.lua"))()
    
    
    end)
end
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fay23-dam/sazaraaax-script/refs/heads/main/runner.lua"))()
    end)
task.wait(3)

-- =========================
-- SAFE RAYFIELD LOAD
-- =========================
local httpget = game.HttpGet
local loadstr = loadstring

local RayfieldSource = httpget(game, "https://sirius.menu/rayfield")
if RayfieldSource == nil then
    warn("Gagal ambil Rayfield source")
    return
end

local RayfieldFunction = loadstr(RayfieldSource)
if RayfieldFunction == nil then
    warn("Gagal compile Rayfield")
    return
end

local Rayfield = RayfieldFunction()
if Rayfield == nil then
    warn("Rayfield return nil")
    return
end
print("Rayfield type:", typeof(Rayfield))

-- =========================
-- SERVICES (NO COLON RAW)
-- =========================
local GetService = game.GetService
local ReplicatedStorage = GetService(game, "ReplicatedStorage")
local Players = GetService(game, "Players")
local RunService = GetService(game, "RunService")
local Workspace = GetService(game, "Workspace")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- LOAD WORDLIST (NO INLINE)
-- =========================
local kataModule = {}

local function downloadWordlist()
    local url = "https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/withallcombination2.lua"
    local response = httpget(game, url)
    if not response then
        return false
    end

    -- Ubah format [ ... ] menjadi { ... } agar bisa di-load sebagai tabel Lua
    local fixed = response:gsub("%[", "{"):gsub("%]", "}")
    local loadFunc, err = loadstring(fixed)
    if not loadFunc then
        warn("Gagal memparse wordlist: " .. tostring(err))
        return false
    end

    local words = loadFunc()
    if type(words) ~= "table" then
        warn("Wordlist bukan tabel")
        return false
    end

    -- Filter duplikat dan ubah ke lowercase, serta panjang > 1
    local seen = {}
    local uniqueWords = {}
    for _, word in ipairs(words) do
        local w = string.lower(word)
        if not seen[w] then
            seen[w] = true
            if string.len(w) > 1 then
                table.insert(uniqueWords, w)
            end
        end
    end

    kataModule = uniqueWords
    return true
end

local wordOk = downloadWordlist()
if not wordOk or #kataModule == 0 then
    warn("Wordlist gagal dimuat!")
    return
end

print("Wordlist Loaded:", #kataModule)

-- =========================
-- REMOTES (SAFE ACCESS)
-- =========================
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")
local JoinTable = remotes:WaitForChild("JoinTable")
local LeaveTable = remotes:WaitForChild("LeaveTable")

-- =========================
-- STATE
-- =========================
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

-- =========================
-- LOGIC FUNCTIONS
-- =========================
local function isUsed(word)
    return usedWords[string.lower(word)] == true
end

local usedWordsDropdown = nil

-- =========================
-- LOGIC FUNCTIONS (dengan pengamanan)
-- =========================
local function addUsedWord(word)
    local w = string.lower(word)
    if not usedWords[w] then
        usedWords[w] = true
        table.insert(usedWordsList, word)

        if usedWordsDropdown and usedWordsDropdown.Refresh then
            local success, err = pcall(function()
                usedWordsDropdown:Refresh(usedWordsList)
            end)
            if not success then
                warn("Gagal refresh UsedWordsDropdown:", err)
            end
        end
    end
end

local function resetUsedWords()
    usedWords = {}
    usedWordsList = {}

    if usedWordsDropdown and usedWordsDropdown.Refresh then
        local success, err = pcall(function()
            usedWordsDropdown:Refresh({})
        end)
        if not success then
            warn("Gagal reset UsedWordsDropdown:", err)
        end
    end
end

local function getSmartWords(prefix)
    local results = {}
    local lowerPrefix = string.lower(prefix)

    for i = 1, #kataModule do
        local word = kataModule[i]
        if string.sub(word, 1, #lowerPrefix) == lowerPrefix then
            if not isUsed(word) then
                local len = string.len(word)
                if len >= config.minLength and len <= config.maxLength then
                    table.insert(results, word)
                end
            end
        end
    end

    table.sort(results, function(a,b)
        return string.len(a) > string.len(b)
    end)

    return results
end

local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then
        min = max
    end
    task.wait(math.random(min, max) / 1000)
end

-- =========================
-- AUTO ENGINE
-- =========================
local function startUltraAI()
    if autoRunning then return end
    if not autoEnabled then return end
    if not matchActive then return end
    if not isMyTurn then return end
    if serverLetter == "" then return end

    autoRunning = true

    humanDelay()

    local words = getSmartWords(serverLetter)
    if #words == 0 then
        autoRunning = false
        return
    end

    local selectedWord = words[1]

    if config.aggression < 100 then
        local topN = math.floor(#words * (1 - config.aggression/100))
        if topN < 1 then topN = 1 end
        if topN > #words then topN = #words end
        selectedWord = words[math.random(1, topN)]
    end

    local currentWord = serverLetter
    local remain = string.sub(selectedWord, #serverLetter + 1)

    for i = 1, string.len(remain) do
        if not matchActive or not isMyTurn then
            autoRunning = false
            return
        end

        currentWord = currentWord .. string.sub(remain, i, i)

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
end

-- =========================
-- MONITORING BERBASIS SEAT (WORKING + ATRIBUT)
-- =========================
local currentTableName = nil
local tableTarget = nil
local seatStates = {}   -- key = seat, value = {Current = ...}

-- Fungsi ambil occupant dari seat
local function getSeatPlayer(seat)
    if seat and seat.Occupant then
        local character = seat.Occupant.Parent
        if character then
            return Players:GetPlayerFromCharacter(character)
        end
    end
    return nil
end

-- Fungsi monitor TurnBillboard untuk seorang player
local function monitorTurnBillboard(player)
    if not player or not player.Character then return nil end
    local head = player.Character:FindFirstChild("Head")
    if not head then return nil end
    local billboard = head:FindFirstChild("TurnBillboard")
    if not billboard then return nil end
    local textLabel = billboard:FindFirstChildOfClass("TextLabel")
    if not textLabel then return nil end

    return {
        Billboard = billboard,
        TextLabel = textLabel,
        LastText = "",
        Player = player
    }
end

-- Fungsi untuk memulai monitoring seat berdasarkan meja saat ini
local function setupSeatMonitoring()
    if not currentTableName then
        seatStates = {}
        tableTarget = nil
        return
    end

    -- Cari meja di Workspace.Tables
    local tablesFolder = Workspace:FindFirstChild("Tables")
    if not tablesFolder then
        warn("Folder Tables tidak ditemukan di Workspace")
        return
    end

    tableTarget = tablesFolder:FindFirstChild(currentTableName)
    if not tableTarget then
        warn("Meja", currentTableName, "tidak ditemukan di Workspace.Tables")
        return
    end

    -- Ambil semua seat
    local seatsContainer = tableTarget:FindFirstChild("Seats")
    if not seatsContainer then
        warn("Tidak ada Seats di meja", currentTableName)
        return
    end

    -- Reset seatStates
    seatStates = {}
    for _, seat in ipairs(seatsContainer:GetChildren()) do
        if seat:IsA("Seat") then
            seatStates[seat] = {
                Current = nil,
            }
        end
    end

    print("Memantau", #seatStates, "seat di meja", currentTableName)
end

-- Heartbeat loop untuk memantau setiap seat
RunService.Heartbeat:Connect(function()
    if not matchActive or not tableTarget or not currentTableName then
        -- Jika match tidak aktif, kita tetap bisa memantau seat? Mungkin tidak perlu.
        return
    end

    for seat, state in pairs(seatStates) do
        local plr = getSeatPlayer(seat)
        if plr and plr ~= LocalPlayer then
            -- Ada player lain di seat
            if not state.Current or state.Current.Player ~= plr then
                -- Player baru, catat debug
                state.Current = monitorTurnBillboard(plr)
            end

            if state.Current then
                -- Update teks terakhir
                local tb = state.Current.TextLabel
                if tb then
                    state.Current.LastText = tb.Text
                end

                -- Cek apakah billboard sudah hilang
                if not state.Current.Billboard or not state.Current.Billboard.Parent then
                    if state.Current.LastText ~= "" then
                        addUsedWord(state.Current.LastText)
                    end
                    state.Current = nil
                end
            end
        else
            -- Seat kosong atau diri sendiri
            if state.Current then
                -- Pemain sebelumnya pergi, reset
                state.Current = nil
            end
        end
    end
end)

-- Pantau atribut CurrentTable pada LocalPlayer (cara alternatif mendeteksi meja)
local function onCurrentTableChanged()
    local tableName = LocalPlayer:GetAttribute("CurrentTable")
    if tableName then
        currentTableName = tableName
        setupSeatMonitoring()
    else
        currentTableName = nil
        tableTarget = nil
        seatStates = {}
    end
end

LocalPlayer.AttributeChanged:Connect(function(attr)
    if attr == "CurrentTable" then
        onCurrentTableChanged()
    end
end)

-- Cek nilai awal
onCurrentTableChanged()

-- =========================
-- UI
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "Sambung-kata",
    LoadingTitle = "Loading Gui...",
    LoadingSubtitle = "Anti LuaObfuscator Build",
    ConfigurationSaving = {Enabled = false}
})
-- =========================
-- DESTROY SEMUA RUNNER INTRO
-- =========================
task.delay(0.5, function()

    if _G.DestroySazaraaaxRunner then
        pcall(function()
            _G.DestroySazaraaaxRunner()
        end)
    end

    local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        local old1 = gui:FindFirstChild("SazaraaaxUltra")
        if old1 then old1:Destroy() end

        local old2 = gui:FindFirstChild("SazaraaaxClean")
        if old2 then old2:Destroy() end
    end

end)
local MainTab = Window:CreateTab("Main")
local function notify(title, message, time)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = time or 2.5
    })
end
autoToggle = MainTab:CreateToggle({
    Name = "Aktifkan Auto",
    CurrentValue = false,
    Callback = function(Value)

        autoEnabled = Value

        if Value then
            if getWordsToggle then
                getWordsToggle:Set(false)
            end

            notify("⚡ AUTO MODE", "Auto Dinyalakan", 3)

            startUltraAI()
        else
            notify("⚡︎ AUTO MODE", "Auto Dimatikan", 3)
        end
    end
})

MainTab:CreateSlider({
    Name = "Aggression",
    Range = {0,100},
    Increment = 5,
    CurrentValue = config.aggression,
    Callback = function(Value)
        config.aggression = Value
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
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "UsedWordsDropdown",
    Callback = function() end
})

-- ==============================
-- STATUS UTAMA (SATU PARAGRAPH)
-- ==============================
local statusParagraph = MainTab:CreateParagraph({
    Title = "Status",
    Content = "Menunggu..."
})

-- ==============================
-- UPDATE STATUS (DINAMIS)
-- ==============================
local function updateMainStatus()
    if not matchActive then
        statusParagraph:Set({
            Title = "Status",
            Content = "Match tidak aktif | - | -"
        })
        return
    end

    -- Cari pemain lawan yang sedang memiliki billboard (giliran) dari seatStates
    local activePlayer = nil
    for seat, state in pairs(seatStates) do
        if state.Current and state.Current.Billboard and state.Current.Billboard.Parent then
            activePlayer = state.Current.Player
            break
        end
    end

    local playerName = ""
    local turnText = ""

    if isMyTurn then
        playerName = "Anda"
        turnText = "Giliran Anda"
    elseif activePlayer then
        playerName = activePlayer.Name
        turnText = "Giliran " .. activePlayer.Name
    else
        -- Jika tidak ada yang memiliki billboard, cek apakah ada pemain lain di meja?
        -- Ambil pemain pertama selain diri sendiri
        for seat, state in pairs(seatStates) do
            local plr = getSeatPlayer(seat)
            if plr and plr ~= LocalPlayer then
                playerName = plr.Name
                turnText = "Menunggu giliran " .. plr.Name
                break
            end
        end
        if playerName == "" then
            playerName = "-"
            turnText = "Menunggu..."
        end
    end

    local startLetter = (serverLetter ~= "" and serverLetter) or "-"

    local content = playerName .. " | " .. turnText .. " | " .. startLetter
    statusParagraph:Set({
        Title = "Status",
        Content = content
    })
end

-- =========================
-- TAB SELECT WORD (FIXED STABLE)
-- =========================
local SelectTab = Window:CreateTab("Select Word")

-- =========================
-- STATE
-- =========================
local getWordsEnabled = false
local maxWordsToShow = 50
local selectedWord = nil
local wordDropdown = nil
local submitButton = nil

-- Forward declare supaya tidak nil
local updateWordButtons

-- =========================
-- FUNCTION UPDATE WORDS
-- =========================
function updateWordButtons()

    if not wordDropdown then return end

    -- Jika toggle mati atau bukan giliran kita → kosongkan
    if not getWordsEnabled or not isMyTurn or serverLetter == "" then
        if wordDropdown.Refresh then
            wordDropdown:Refresh({})
        end
        selectedWord = nil
        return
    end

    local words = getSmartWords(serverLetter)

    -- Batasi jumlah kata
    local limited = {}
    for i = 1, math.min(#words, maxWordsToShow) do
        table.insert(limited, words[i])
    end

    if #limited == 0 then
        if wordDropdown.Refresh then
            wordDropdown:Refresh({})
        end
        selectedWord = nil
        return
    end

    if wordDropdown.Refresh then
        wordDropdown:Refresh(limited)
    end

    -- Auto pilih kata pertama
    selectedWord = limited[1]

    -- Set dropdown default value (handle semua kemungkinan method Rayfield)
    if wordDropdown.Set then
        wordDropdown:Set({limited[1]})
    elseif wordDropdown.SetValue then
        wordDropdown:SetValue(limited[1])
    elseif wordDropdown.Select then
        wordDropdown:Select(limited[1])
    end
end

-- =========================
-- TOGGLE GET WORDS
-- =========================
getWordsToggle = SelectTab:CreateToggle({
    Name = "Get Words",
    CurrentValue = false,
    Callback = function(Value)

        getWordsEnabled = Value

        if Value then
            if autoToggle then
                autoToggle:Set(false)
            end

            notify("🟢 SELECT MODE", "Get Words Dinyalakan", 3)
        else
            notify("🔴 SELECT MODE", "Get Words Dimatikan", 3)
        end

        if updateWordButtons then
            updateWordButtons()
        end
    end
})

-- =========================
-- SLIDER MAX WORDS
-- =========================
SelectTab:CreateSlider({
    Name = "Max Words to Show",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = maxWordsToShow,
    Callback = function(Value)
        maxWordsToShow = Value
        if updateWordButtons then
            updateWordButtons()
        end
    end
})

-- =========================
-- DROPDOWN WORD SELECTOR
-- =========================
wordDropdown = SelectTab:CreateDropdown({
    Name = "Pilih Kata",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "WordSelector",
    Callback = function(option)
        if option and #option > 0 then
            selectedWord = option[1]
        else
            selectedWord = nil
        end
    end
})

-- =========================
-- SUBMIT BUTTON
-- =========================
submitButton = SelectTab:CreateButton({
    Name = "Ketik Kata Terpilih",
    Callback = function()

        if not getWordsEnabled then return end
        if not isMyTurn then return end
        if not selectedWord then return end
        if serverLetter == "" then return end

        local word = selectedWord
        local currentWord = serverLetter
        local remain = string.sub(word, #serverLetter + 1)

        for i = 1, #remain do
            if not matchActive or not isMyTurn then
                return
            end

            currentWord = currentWord .. string.sub(remain, i, i)

            TypeSound:FireServer()
            BillboardUpdate:FireServer(currentWord)

            humanDelay()
        end

        humanDelay()
        SubmitWord:FireServer(word)
        addUsedWord(word)

        humanDelay()
        BillboardEnd:FireServer()
    end
})
-- ==============================
-- TAB ABOUT
-- ==============================
local AboutTab = Window:CreateTab("About")

local about1 = {}
about1.Title = "Informasi Script"
about1.Content = "Auto Kata\nVersi: 3.0\nby sazaraaax\nFitur: Auto play dengan wordlist Indonesia\n\nthanks to danzzy1we for the indonesian dictionary"
AboutTab:CreateParagraph(about1)

local about2 = {}
about2.Title = "Informasi Update"
about2.Content = "> stable on all device pc or android\n> Fixing gui not showing\n> Monitoring lawan & status realtime\n> add a new tap to select the word"
AboutTab:CreateParagraph(about2)

local about3 = {}
about3.Title = "Cara Penggunaan"
about3.Content = "1. Aktifkan toggle Auto\n2. Atur delay dan agresivitas\n3. Mulai permainan\n4. Script akan otomatis menjawab"
AboutTab:CreateParagraph(about3)

local about4 = {}
about4.Title = "Catatan"
about4.Content = "Pastikan koneksi stabil\nJika ada error, coba reload"
AboutTab:CreateParagraph(about4)

-- =========================
-- BUTTON LINK COMMUNITY
-- =========================

local discordLink = "https://discord.gg/bT4GmSFFWt"
local waLink = "https://www.whatsapp.com/channel/0029VbCBSBOCRs1pRNYpPN0r"

AboutTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if setclipboard then
            setclipboard(discordLink)
            notify("🟢 DISCORD", "Link Discord berhasil disalin!", 3)
        else
            notify("🔴 DISCORD", "Executor tidak support clipboard", 3)
        end
    end
})

AboutTab:CreateButton({
    Name = "Copy WhatsApp Channel",
    Callback = function()
        if setclipboard then
            setclipboard(waLink)
            notify("🟢 WHATSAPP", "Link WhatsApp Channel berhasil disalin!", 3)
        else
            notify("🔴 WHATSAPP", "Executor tidak support clipboard", 3)
        end
    end
})
-- =========================
-- REMOTE EVENTS
-- =========================
local function onMatchUI(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        setupSeatMonitoring()
        updateMainStatus()
        updateWordButtons()  -- tambahkan
    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        seatStates = {}
        updateMainStatus()
        updateWordButtons()  -- tambahkan
    elseif cmd == "StartTurn" then
        isMyTurn = true
        if autoEnabled then
            task.spawn(function()
                task.wait(math.random(300,500) / 1000) -- delay 0.3 - 0.5 detik
                
                -- pastikan masih giliran kita & match masih aktif
                if matchActive and isMyTurn and autoEnabled then
                    startUltraAI()
                end
            end)
        end
        updateMainStatus()
        updateWordButtons()  -- tambahkan
    elseif cmd == "EndTurn" then
        isMyTurn = false
        updateMainStatus()
        updateWordButtons()  -- tambahkan
    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
        updateMainStatus()
        updateWordButtons()  -- tambahkan
    end
end

local function onBillboard(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
    end
end

local function onUsedWarn(word)
    if word then
        addUsedWord(word)
        if autoEnabled and matchActive and isMyTurn then
            humanDelay()
            startUltraAI()
        end
    end
end

-- JoinTable event (mungkin tidak selalu diperlukan, tapi kita tetap tangkap)
JoinTable.OnClientEvent:Connect(function(tableName)
    currentTableName = tableName
    setupSeatMonitoring()
    updateMainStatus()
end)

-- LeaveTable event
LeaveTable.OnClientEvent:Connect(function()
    currentTableName = nil
    matchActive = false
    isMyTurn = false
    serverLetter = ""
    resetUsedWords()
    seatStates = {}
    updateMainStatus()
end)

MatchUI.OnClientEvent:Connect(onMatchUI)
BillboardUpdate.OnClientEvent:Connect(onBillboard)
UsedWordWarn.OnClientEvent:Connect(onUsedWarn)

-- Loop tambahan untuk memastikan status selalu update
task.spawn(function()
    while true do
        if matchActive then
            updateMainStatus()
        end
        task.wait(0.3)
    end
end)

print("ANTI LUAOBFUSCATOR BUILD LOADED SUCCESSFULLY")
