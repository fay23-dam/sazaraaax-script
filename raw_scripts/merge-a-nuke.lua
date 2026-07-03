-- Kode Pelacak (Execution Tracker)
task.spawn(function()
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if req then
        req({
            Url = "https://victoriascript.vercel.app/api/track",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({
                gameId = 128784467030899,
                player = game:GetService("Players").LocalPlayer.Name,
                executor = identifyexecutor and identifyexecutor() or "Unknown"
            })
        })
    end
end)

-- Tulis kode Lua Anda di sini...
--[[
    nuke.lua — Auto Merge, Auto Nuke, Auto Upgrades
    Optimized | Dynamic Tycoon | Hit & Run
]]
-- ============================================================
-- SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player.PlayerGui
local camera    = workspace.CurrentCamera

local character = player.Character or player.CharacterAdded:Wait()
local hrp       = character:WaitForChild("HumanoidRootPart")
player.CharacterAdded:Connect(function(c) character = c; hrp = c:WaitForChild("HumanoidRootPart") end)

-- ============================================================
-- STATE & LOGIC
-- ============================================================
local state = (function()
return {
    isScriptRunning = true,
    autoMergeEnabled = false,
    autoLockBase = false,
    waktuTungguPickup = 1.0,
    waktuTungguMerge = 0.3,
    forceMergeOnce = false,
    
    autoUpgradeTier = false,
    autoUpgradeRate = false,
    autoUpgradeLock = false,
    autoUpgradeMax = false,
    autoRebirth = false,
    
    disableLaunchCamera = false,
    
    autoNukeEnabled = false,
    brutalAttackEnabled = false,
    forceManualAttack = false,
    autoNukeTarget = nil,
    autoNukeTier = 8,
    
    autoAttackCity = false,
    cityEventActive = false,
    cityTargetPosition = Vector3.new(0, 0, 0),
    
    autoAttackCommander = false,
    commanderTargetName = nil,
    commanderTargetParentName = nil,
    
    autoCounterAttack = false,
    counterAttackTarget = nil,
    
    
    setStatus = function(text, color) end, -- Will be overridden by main.lua
    afkEnabled = false
}

end)();
(function()
return function(state)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local RunService = game:GetService("RunService")
    
    local player = Players.LocalPlayer
    local NukeRemotes = ReplicatedStorage:WaitForChild("NukeRemotes")
    local Networking = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Remotes"):WaitForChild("Networking")
    
    local PickUpRemote = NukeRemotes:WaitForChild("PickUp")
    local MergeRequest = Networking:WaitForChild("RE/Merge/MergeRequest")
    local RequestLockBase = NukeRemotes:WaitForChild("RequestLockBase")
    local LaunchConfirm = Networking:WaitForChild("RE/Launch/LaunchConfirm")
    local CityEventStarted = Networking:WaitForChild("RE/City/CityEventStarted")
    local CityRewardPaid = Networking:WaitForChild("RE/City/CityRewardPaid")
    local PurchaseUpgrade = NukeRemotes:WaitForChild("PurchaseUpgrade")
    local RequestRebirth = NukeRemotes:WaitForChild("RequestRebirth")
    
    -- Event listeners
    CityEventStarted.OnClientEvent:Connect(function(arg1, arg2)
        state.cityEventActive = true
        state.setStatus("🚨 EVENT: CITY ATTACK DIMULAI!", Color3.fromRGB(255, 60, 60))
        
        if typeof(arg1) == "Vector3" then
            state.cityTargetPosition = arg1
        else
            local cityObj = workspace:FindFirstChild("CityModel") or workspace:FindFirstChild("City") or workspace:FindFirstChild("CityTarget")
            if cityObj and cityObj:IsA("Model") and cityObj.PrimaryPart then
                state.cityTargetPosition = cityObj.PrimaryPart.Position
            elseif cityObj and cityObj:IsA("BasePart") then
                state.cityTargetPosition = cityObj.Position
            end
        end
    end)
    
    CityRewardPaid.OnClientEvent:Connect(function()
        state.cityEventActive = false
        state.setStatus("✅ EVENT CITY SELESAI!", Color3.fromRGB(56, 201, 106))
    end)
    
    local AttackFeed = NukeRemotes:WaitForChild("AttackFeed")
    AttackFeed.OnClientEvent:Connect(function(attackerUserId, attackerName, targetUserId, targetName)
        if state.autoCounterAttack and targetName == player.Name and attackerName ~= player.Name then
            state.counterAttackTarget = attackerName
            state.setStatus("Counter Attack: Menandai " .. attackerName, Color3.fromRGB(255, 100, 50))
        end
    end)
    
    -- Disable Launch Camera
    -- Disable Launch Camera
    RunService:BindToRenderStep("VictoriaNukeCameraLock", Enum.RenderPriority.Camera.Value + 1, function()
        if state.disableLaunchCamera then
            for _, v in ipairs(workspace:GetChildren()) do
                if v:GetAttribute("State") == "flying" and v:GetAttribute("LauncherUserId") == player.UserId then
                    v:SetAttribute("LauncherUserId", -1)
                end
            end
            local cam = workspace.CurrentCamera
            if cam.CameraType ~= Enum.CameraType.Custom then
                cam.CameraType = Enum.CameraType.Custom
            end
            
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                if cam.CameraSubject ~= char.Humanoid then
                    cam.CameraSubject = char.Humanoid
                end
            end
        end
    end)
    
    -- ============================================================
    -- TELEPORT ANTI-GAGAL
    -- ============================================================
    local function safeTeleport(targetPos)
        local char = player.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(targetPos)
        task.wait(0.1)
        hrp.Anchored = false
        
        if (hrp.Position - targetPos).Magnitude > 5 then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:MoveTo(targetPos)
            end
            task.wait(0.3)
        end
        return true
    end

    local function getPlayerBase(targetPlayer)
        local p = targetPlayer or player
        local basesFolder = workspace:FindFirstChild("Bases")
        if not basesFolder then return nil end
        for _, base in ipairs(basesFolder:GetChildren()) do
            local ownerId = base:GetAttribute("OwnerUserId") or base:GetAttribute("UserId") or base:GetAttribute("PlayerId")
            local ownerName = base:GetAttribute("Owner") or base:GetAttribute("OwnerName")
            if ownerId == p.UserId or ownerName == p.Name then
                return base 
            end
            local nukes = base:FindFirstChild("Nukes")
            if nukes then
                for _, n in ipairs(nukes:GetChildren()) do
                    if n:GetAttribute("OwnerUserId") == p.UserId then
                        return base
                    end
                end
            end
        end
        return nil
    end

    local function executeMerge()
        local myBase = getPlayerBase()
        if not myBase then
            state.setStatus("Base belum ditemukan!", Color3.fromRGB(255, 60, 60))
            return 
        end
        
        local character = player.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local originalPos = hrp.Position
        local nukesByTier = {}
        
        for _, obj in ipairs(myBase:GetDescendants()) do
            local tier = obj:GetAttribute("Tier")
            if tier then
                if (obj:IsA("Model") and obj.Name == "Nuke") or (obj:IsA("BasePart") and obj.Name == "Nuke") then
                    if not nukesByTier[tier] then nukesByTier[tier] = {} end
                    table.insert(nukesByTier[tier], obj)
                end
            end
        end
        
        local hasMergedAny = false
        
        local heldVisual = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
        if heldVisual then
            local heldTier = heldVisual:GetAttribute("Tier")
            if heldTier and nukesByTier[heldTier] and #nukesByTier[heldTier] >= 1 then
                state.setStatus("Mencocokkan Nuke bawaan Tier: " .. tostring(heldTier), Color3.fromRGB(56, 182, 255))
                hasMergedAny = true
                
                local nukeTarget = table.remove(nukesByTier[heldTier], 1)
                local targetPos = nukeTarget:IsA("Model") and nukeTarget:GetPivot().Position or nukeTarget.Position
                
                safeTeleport(targetPos)
                PickUpRemote:FireServer(nukeTarget)
                task.wait(0.2)
                MergeRequest:FireServer(nukeTarget)
                
                task.wait(state.waktuTungguMerge) 
                safeTeleport(originalPos)
                task.wait(0.8)
            else
                forceDropNuke()
                task.wait(0.5)
            end
        end
        
        for tier, nukesList in pairs(nukesByTier) do
            while #nukesList >= 2 do
                if not state.autoMergeEnabled and not state.forceMergeOnce then return end
                hasMergedAny = true
                local nuke1 = table.remove(nukesList, 1)
                local nuke2 = table.remove(nukesList, 1)
                
                state.setStatus("Merging Nuke Tier: " .. tostring(tier), Color3.fromRGB(255, 185, 55))
                
                local pos1 = nuke1:IsA("Model") and nuke1:GetPivot().Position or nuke1.Position
                safeTeleport(pos1)
                PickUpRemote:FireServer(nuke1)
                task.wait(state.waktuTungguPickup)
                
                local currentHeld = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
                local currentHeldTier = currentHeld and currentHeld:GetAttribute("Tier")
                
                if currentHeldTier and currentHeldTier ~= tier then
                    forceDropNuke()
                    table.insert(nukesList, 1, nuke2) 
                    break 
                elseif not currentHeld then
                    table.insert(nukesList, 1, nuke2)
                    break
                end
                
                local pos2 = nuke2:IsA("Model") and nuke2:GetPivot().Position or nuke2.Position
                safeTeleport(pos2)
                MergeRequest:FireServer(nuke2)
                
                task.wait(state.waktuTungguMerge) 
                safeTeleport(originalPos)
                
                task.wait(0.8)
            end
        end
        
        if hasMergedAny then
            state.setStatus("Idle - Menunggu Nuke Baru", Color3.fromRGB(90, 105, 100))
        end
        
        state.forceMergeOnce = false
    end
    
    -- Loops
    task.spawn(function()
        while state.isScriptRunning do
            if state.autoMergeEnabled or state.forceMergeOnce then
                pcall(executeMerge)
            end
            task.wait(1)
        end
    end)
    
    task.spawn(function()
        while state.isScriptRunning do
            if state.autoLockBase then pcall(function() RequestLockBase:FireServer() end) end
            task.wait(1)
        end
    end)
    
    task.spawn(function()
        while state.isScriptRunning do
            if state.autoUpgradeTier then pcall(function() PurchaseUpgrade:FireServer("TIER") end) end
            if state.autoUpgradeRate then pcall(function() PurchaseUpgrade:FireServer("RATE") end) end
            if state.autoUpgradeLock then pcall(function() PurchaseUpgrade:FireServer("LOCKBASE") end) end
            if state.autoUpgradeMax  then pcall(function() PurchaseUpgrade:FireServer("MAX") end) end
            if state.autoRebirth     then pcall(function() RequestRebirth:FireServer() end) end
            task.wait(2)
        end
    end)
    
    local function playerHasShield(targetPlayer)
        if not targetPlayer.Character then return false end
        if targetPlayer.Character:FindFirstChildOfClass("ForceField") then return true end
        return false
    end

    local function isPositionShielded(pos)
        local basesFolder = workspace:FindFirstChild("Bases")
        if not basesFolder then return false end
        for _, base in ipairs(basesFolder:GetChildren()) do
            for _, p in ipairs(base:GetDescendants()) do
                if p:IsA("BasePart") and p.Transparency < 1 then
                    local lname = p.Name:lower()
                    if lname:match("shield") or lname:match("dome") or lname:match("forcefield") or lname:match("lock") then
                        local radius = p.Size.X / 2
                        if (pos - p.Position).Magnitude <= radius then return true end
                    elseif p.Size.X > 40 and p.Transparency > 0 and p.Transparency < 1 and p.Shape == Enum.PartType.Ball then
                        local radius = p.Size.X / 2
                        if (pos - p.Position).Magnitude <= radius then return true end
                    end
                end
            end
        end
        return false
    end

    local function getSmartNukes(myBase)
        local readyNukesList = {}
        local cooldownNukesList = {}
        for _, nuke in ipairs(myBase:GetDescendants()) do
            if (nuke:IsA("Model") or nuke:IsA("BasePart")) and nuke.Name == "Nuke" then
                local tier = nuke:GetAttribute("Tier") or 0
                if not nuke:FindFirstChild("CooldownBillboardLocal") then
                    table.insert(readyNukesList, {nuke = nuke, tier = tier})
                else
                    table.insert(cooldownNukesList, {nuke = nuke, tier = tier})
                end
            end
        end
        table.sort(readyNukesList, function(a, b) return a.tier > b.tier end)
        table.sort(cooldownNukesList, function(a, b) return a.tier > b.tier end)
        
        local readyNuke = readyNukesList[1] and readyNukesList[1].nuke
        local cooldownNuke = cooldownNukesList[1] and cooldownNukesList[1].nuke
        return readyNuke, cooldownNuke, readyNukesList
    end

    local function forceDropNuke()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:UnequipTools() end
            
            local hasTool = false
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "Nuke" then
                    hasTool = true
                    tool.Parent = workspace
                end
            end
            
            -- Fire the Drop remote to make sure server cleans up UI and drops it correctly
            local DropRemote = NukeRemotes:FindFirstChild("Drop")
            if DropRemote then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local dropCFrame = hrp and hrp.CFrame or CFrame.new(0, 10, 0)
                DropRemote:FireServer(dropCFrame)
            end
        end
        local heldVisual = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
        if heldVisual then heldVisual:Destroy() end
    end

    local function launchNuke(targetPos)
        local attempts = 0
        while workspace.CurrentCamera:FindFirstChild("HeldNukeVisual") and attempts < 3 do
            LaunchConfirm:FireServer(targetPos)
            task.wait(0.3)
            attempts = attempts + 1
        end
        -- Wajib drop setelah attack selesai (berhasil atau gagal)
        forceDropNuke()
        task.wait(0.2)
    end

    task.spawn(function()
        while state.isScriptRunning do
            if state.forceManualAttack then
                state.forceManualAttack = false
                local targetName = state.autoNukeTarget
                if targetName then
                    local tPlayer = Players:FindFirstChild(targetName)
                    local myBase = getPlayerBase()
                    if myBase and tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPos = tPlayer.Character.HumanoidRootPart.Position
                        if playerHasShield(tPlayer) then
                            state.setStatus("Manual Attack: Target pakai Shield!", Color3.fromRGB(255, 185, 55))
                        elseif isPositionShielded(targetPos) then
                            state.setStatus("Manual Attack: Target berlindung di Base!", Color3.fromRGB(255, 100, 60))
                        else
                            local readyNuke = getSmartNukes(myBase)
                            if readyNuke then
                                state.setStatus("Manual Attack: Menembak " .. targetName, Color3.fromRGB(255, 60, 60))
                                local hrp = player.Character.HumanoidRootPart
                                local orig = hrp.Position
                                
                                local pos = readyNuke:IsA("Model") and readyNuke:GetPivot().Position or readyNuke.Position
                                safeTeleport(pos)
                                PickUpRemote:FireServer(readyNuke)
                                task.wait(state.waktuTungguPickup)
                                local heldVisual = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
                                if heldVisual then
                                    launchNuke(targetPos)
                                end
                                safeTeleport(orig)
                                task.wait(1)
                            else
                                state.setStatus("Manual Attack: Nuke Habis/Cooldown!", Color3.fromRGB(255, 60, 60))
                            end
                        end
                    end
                else
                    state.setStatus("Manual Attack: Target Belum Dipilih", Color3.fromRGB(255, 100, 60))
                end
            end
            
            if state.brutalAttackEnabled then
                local character = player.Character
                if character then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool and tool.Name == "Nuke" and tool:FindFirstChild("CooldownBillboardLocal") then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then humanoid:UnequipTools() end
                    end
                end
                
                local myBase = getPlayerBase()
                if myBase then
                    local foundTarget = false
                    for _, tPlayer in ipairs(Players:GetPlayers()) do
                        if tPlayer ~= player then
                            local tBase = getPlayerBase(tPlayer)
                            local pos = nil
                            
                            if tBase then
                                if tBase.PrimaryPart then
                                    pos = tBase.PrimaryPart.Position
                                elseif tBase:FindFirstChild("Platform") then
                                    pos = tBase.Platform.Position
                                else
                                    pos = tBase:GetPivot().Position
                                end
                            elseif tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                pos = tPlayer.Character.HumanoidRootPart.Position
                            end
                            
                            if pos and not playerHasShield(tPlayer) and not isPositionShielded(pos) then
                                local readyNuke = getSmartNukes(myBase)
                                
                                if readyNuke then
                                    foundTarget = true
                                    local tierUsed = readyNuke:GetAttribute("Tier") or "?"
                                    state.setStatus("Brutal Attack: Menembak Base " .. tPlayer.Name .. " (T" .. tierUsed .. ")", Color3.fromRGB(255, 60, 60))
                                    
                                    local hrp = player.Character.HumanoidRootPart
                                    local orig = hrp.Position
                                    local posN = readyNuke:IsA("Model") and readyNuke:GetPivot().Position or readyNuke.Position
                                    
                                    safeTeleport(posN)
                                    PickUpRemote:FireServer(readyNuke)
                                    task.wait(state.waktuTungguPickup)
                                    local heldVisual = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
                                    if heldVisual then
                                        launchNuke(pos)
                                    end
                                    safeTeleport(orig)
                                    task.wait(1)
                                    break
                                end
                            end
                        end
                    end
                    if not foundTarget then
                        state.setStatus("Brutal Attack: Tidak Ada Target Terbuka", Color3.fromRGB(150, 150, 150))
                    end
                end
            elseif state.autoCounterAttack and state.counterAttackTarget then
                local tPlayer = Players:FindFirstChild(state.counterAttackTarget)
                if tPlayer then
                    local tBase = getPlayerBase(tPlayer)
                    local pos = nil
                    
                    if tBase then
                        if tBase.PrimaryPart then
                            pos = tBase.PrimaryPart.Position
                        elseif tBase:FindFirstChild("Platform") then
                            pos = tBase.Platform.Position
                        else
                            pos = tBase:GetPivot().Position
                        end
                    elseif tPlayer.Character and tPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        pos = tPlayer.Character.HumanoidRootPart.Position
                    end
                    
                    if pos then
                        if playerHasShield(tPlayer) or isPositionShielded(pos) then
                            state.setStatus("Counter Attack: Base dilock/Shield", Color3.fromRGB(255, 100, 50))
                            state.counterAttackTarget = nil 
                        else
                            local myBase = getPlayerBase()
                            if myBase then
                                local readyNuke = getSmartNukes(myBase)
                                
                                if readyNuke then
                                    local tierUsed = readyNuke:GetAttribute("Tier") or "?"
                                    state.setStatus("Counter Attack: Menembak Base " .. state.counterAttackTarget .. " (T" .. tierUsed .. ")", Color3.fromRGB(255, 60, 60))
                                    local hrp = player.Character.HumanoidRootPart
                                    local orig = hrp.Position
                                    
                                    local posN = readyNuke:IsA("Model") and readyNuke:GetPivot().Position or readyNuke.Position
                                    safeTeleport(posN)
                                    PickUpRemote:FireServer(readyNuke)
                                    task.wait(state.waktuTungguPickup)
                                    local heldVisual = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
                                    if heldVisual then
                                        launchNuke(pos)
                                    end
                                    safeTeleport(orig)
                                    task.wait(1)
                                else
                                    state.setStatus("Counter Attack: Nuke Habis/Cooldown", Color3.fromRGB(255, 100, 50))
                                end
                            end
                        end
                    else
                        state.setStatus("Counter Attack: Target Posisi Hilang", Color3.fromRGB(255, 100, 50))
                    end
                else
                    state.setStatus("Counter Attack: Player Keluar/Mati", Color3.fromRGB(255, 100, 50))
                    state.counterAttackTarget = nil
                end
            elseif state.autoAttackCommander then
                if state.commanderTargetName then
                    local cmdrTarget = workspace:FindFirstChild(state.commanderTargetName)
                    if cmdrTarget then
                        local targetPos
                        if cmdrTarget:IsA("Model") then
                            targetPos = cmdrTarget.PrimaryPart and cmdrTarget.PrimaryPart.Position or cmdrTarget:GetPivot().Position
                        else
                            targetPos = cmdrTarget.Position
                        end
                        
                        local myBase = getPlayerBase()
                        if myBase then
                            local readyNuke, cooldownNuke = getSmartNukes(myBase)
                            
                            if readyNuke then
                                local tierUsed = readyNuke:GetAttribute("Tier") or "?"
                                state.setStatus("Auto Cmdr: Nuke Tier " .. tostring(tierUsed), Color3.fromRGB(0, 255, 128))
                                local hrp = player.Character.HumanoidRootPart
                                local orig = hrp.Position
                                local pos = readyNuke:IsA("Model") and readyNuke:GetPivot().Position or readyNuke.Position
                                safeTeleport(pos)
                                PickUpRemote:FireServer(readyNuke)
                                task.wait(state.waktuTungguPickup)
                                local heldVisual = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
                                if heldVisual then
                                    launchNuke(targetPos)
                                end
                                safeTeleport(orig)
                                task.wait(1)
                            elseif cooldownNuke then
                                local cdBoard = cooldownNuke:FindFirstChild("CooldownBillboardLocal")
                                local txt = cdBoard and cdBoard:FindFirstChild("TextLabel")
                                local cdText = txt and txt.Text or "Cooldown"
                                state.setStatus("Auto Cmdr: " .. cdText, Color3.fromRGB(255, 185, 55))
                            else
                                state.setStatus("Auto Cmdr: Nuke Kosong!", Color3.fromRGB(255, 60, 60))
                            end
                        end
                    else
                        state.setStatus("Auto Cmdr: Target Hilang", Color3.fromRGB(255, 100, 60))
                    end
                else
                    state.setStatus("Auto Cmdr: Target Belum Dipilih", Color3.fromRGB(255, 100, 60))
                end
            elseif state.autoAttackCity then
                local cityTarget = workspace:FindFirstChild("CityModel") or workspace:FindFirstChild("MiddleTarget") or workspace:FindFirstChild("CityTarget") or workspace:FindFirstChild("City")
                if cityTarget and state.cityEventActive then
                    local targetPos = state.cityTargetPosition
                    if cityTarget then
                        if cityTarget:IsA("Model") then
                            if cityTarget.PrimaryPart then
                                targetPos = cityTarget.PrimaryPart.Position
                            else
                                targetPos = cityTarget:GetPivot().Position
                            end
                        elseif cityTarget:IsA("BasePart") then
                            targetPos = cityTarget.Position
                        end
                    end
                    
                    local myBase = getPlayerBase()
                    if myBase then
                        local readyNuke, cooldownNuke = getSmartNukes(myBase)
                        
                        if readyNuke then
                            local tierUsed = readyNuke:GetAttribute("Tier") or "?"
                            state.setStatus("Auto City: Mengambil Nuke Tier " .. tostring(tierUsed), Color3.fromRGB(255, 105, 180))
                            local hrp = player.Character.HumanoidRootPart
                            local orig = hrp.Position
                            
                            local pos = readyNuke:IsA("Model") and readyNuke:GetPivot().Position or readyNuke.Position
                            safeTeleport(pos)
                            PickUpRemote:FireServer(readyNuke)
                            task.wait(state.waktuTungguPickup)
                            
                            local heldVisual = workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
                            if heldVisual then
                                launchNuke(targetPos)
                            end
                            
                            safeTeleport(orig)
                            task.wait(1)
                        elseif cooldownNuke then
                            local cdBoard = cooldownNuke:FindFirstChild("CooldownBillboardLocal")
                            local txt = cdBoard and cdBoard:FindFirstChild("TextLabel")
                            local cdText = txt and txt.Text or "Cooldown"
                            state.setStatus("Auto City: " .. cdText, Color3.fromRGB(255, 185, 55))
                        else
                            state.setStatus("Auto City: Nuke Tier " .. state.autoNukeTier .. " Kosong!", Color3.fromRGB(255, 60, 60))
                        end
                    end
                else
                    state.setStatus("Auto City: Menunggu Event...", Color3.fromRGB(150, 150, 150))
                end
            end
            task.wait(1)
        end
    end)
    
    player.Idled:Connect(function()
        if state.afkEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            state.setStatus("anti afk triggered", Color3.fromRGB(56, 182, 255))
        end
    end)
end

end)()(state);

-- ============================================================
-- CLEANUP
-- ============================================================
if playerGui:FindFirstChild("VictoriaNuke") then playerGui.VictoriaNuke:Destroy() end

-- ============================================================
-- SCALE
-- ============================================================
local vp       = camera.ViewportSize
local scale    = math.clamp(vp.X / 1920, 0.65, 1.15)
local W        = 300 * scale
local FULL_H   = 680 * scale
local HDR_H    = 44 * scale

-- ============================================================
-- SCREEN GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name="VictoriaNuke"; screenGui.ResetOnSpawn=false
screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset=true; screenGui.Parent=playerGui

-- ============================================================
-- MAIN FRAME & INTRO HUB
-- ============================================================
local main = Instance.new("Frame")
main.Name="Main"; main.Size=UDim2.new(0,320*scale,0,140*scale)
main.Position=UDim2.new(0.5,0,0.5,0) -- Start at center
main.AnchorPoint=Vector2.new(0.5,0.5)
main.BackgroundColor3=Color3.fromRGB(15,15,22)
main.BorderSizePixel=0; main.ClipsDescendants=true; main.Parent=screenGui
Instance.new("UICorner",main).CornerRadius=UDim.new(0,12*scale)

local uiScale = Instance.new("UIScale", main)
uiScale.Scale = 0 -- Start invisible for zoom animation

local gradient = Instance.new("UIGradient", main)
gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))})
gradient.Rotation = 45

local mainStroke=Instance.new("UIStroke",main)
mainStroke.Color=Color3.fromRGB(40,50,60); mainStroke.Thickness=1

local glow=Instance.new("UIStroke",main)
glow.Color=Color3.fromRGB(0,210,255); glow.Thickness=0; glow.Transparency=1

-- HEADER
local header=Instance.new("Frame",main)
header.Size=UDim2.new(1,0,0,70*scale); header.BackgroundTransparency=1; header.ZIndex=5
local hLayout=Instance.new("UIListLayout",header); hLayout.FillDirection=Enum.FillDirection.Vertical
hLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left; hLayout.VerticalAlignment=Enum.VerticalAlignment.Center; hLayout.Padding=UDim.new(0,2*scale)
local hPad=Instance.new("UIPadding",header); hPad.PaddingLeft=UDim.new(0,18*scale)

local titleRow=Instance.new("Frame",header); titleRow.Size=UDim2.new(1,0,0,30*scale); titleRow.BackgroundTransparency=1
local tLayout=Instance.new("UIListLayout",titleRow); tLayout.FillDirection=Enum.FillDirection.Horizontal
tLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left; tLayout.VerticalAlignment=Enum.VerticalAlignment.Center; tLayout.Padding=UDim.new(0,6*scale)

local icon=Instance.new("TextLabel",titleRow); icon.Size=UDim2.new(0,18*scale,0,30*scale)
icon.BackgroundTransparency=1; icon.Text="~"; icon.TextColor3=Color3.fromRGB(255,105,180)
icon.TextScaled=true; icon.FontFace=Font.new("rbxassetid://12187368843"); icon.ZIndex=6

local titleLbl=Instance.new("TextLabel",titleRow); titleLbl.Size=UDim2.new(0,160*scale,0,26*scale)
titleLbl.BackgroundTransparency=1; titleLbl.Text="Victoria Script"; titleLbl.TextColor3=Color3.fromRGB(255,255,255)
titleLbl.TextScaled=false; titleLbl.TextSize=18*scale; titleLbl.FontFace=Font.new("rbxassetid://12187368843"); titleLbl.ZIndex=6
titleLbl.TextXAlignment=Enum.TextXAlignment.Left

local titleGrad = Instance.new("UIGradient", titleLbl)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255))
})

local subtitle=Instance.new("TextLabel",header); subtitle.Size=UDim2.new(1,0,0,14*scale)
subtitle.BackgroundTransparency=1; subtitle.Text="// By Sazaraaax & dhanzy"; subtitle.TextColor3=Color3.fromRGB(90, 105, 100)
subtitle.TextScaled=false; subtitle.TextSize=12*scale; subtitle.FontFace=Font.new("rbxassetid://12187368843"); subtitle.ZIndex=6
subtitle.TextXAlignment=Enum.TextXAlignment.Left
local sPad=Instance.new("UIPadding",subtitle); sPad.PaddingLeft=UDim.new(0*scale)

-- CLOSE BUTTON
local closeBtn=Instance.new("TextButton",main)
closeBtn.Size=UDim2.new(0,24*scale,0,24*scale); closeBtn.Position=UDim2.new(1,-36*scale,0,18*scale)
closeBtn.BackgroundColor3=Color3.fromRGB(220,60,60); closeBtn.BackgroundTransparency=0.85
closeBtn.Text="X"; closeBtn.TextColor3=Color3.fromRGB(220,60,60)
closeBtn.TextScaled=false; closeBtn.TextSize=math.floor(14*scale); closeBtn.FontFace=Font.new("rbxassetid://12187368843"); closeBtn.ZIndex=10; closeBtn.Visible=false
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,4*scale)
local closeStroke=Instance.new("UIStroke",closeBtn)
closeStroke.Color=Color3.fromRGB(220,60,60); closeStroke.Thickness=1.5; closeStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- MINIMIZE BUTTON
local minBtn=Instance.new("TextButton",main)
minBtn.Size=UDim2.new(0,24*scale,0,24*scale); minBtn.Position=UDim2.new(1,-66*scale,0,18*scale)
minBtn.BackgroundColor3=Color3.fromRGB(60,180,220); minBtn.BackgroundTransparency=0.85
minBtn.Text="-"; minBtn.TextColor3=Color3.fromRGB(60,180,220)
minBtn.TextScaled=false; minBtn.TextSize=math.floor(18*scale); minBtn.FontFace=Font.new("rbxassetid://12187368843"); minBtn.ZIndex=10; minBtn.Visible=false
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,4*scale)
local minStroke=Instance.new("UIStroke",minBtn)
minStroke.Color=Color3.fromRGB(60,180,220); minStroke.Thickness=1.5; minStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- INTRO BUTTONS
local introContent=Instance.new("CanvasGroup",main)
introContent.Size=UDim2.new(1,0,0,32*scale); introContent.Position=UDim2.new(0,0,0,70*scale)
introContent.BackgroundTransparency=1; introContent.GroupTransparency=1

local btnLayout=Instance.new("UIListLayout",introContent)
btnLayout.FillDirection=Enum.FillDirection.Horizontal; btnLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
btnLayout.VerticalAlignment=Enum.VerticalAlignment.Center; btnLayout.Padding=UDim.new(0,10*scale)

local function createBtn(text, strokeColor, width)
    local b=Instance.new("TextButton",introContent)
    b.Size=UDim2.new(0,width*scale,0,28*scale)
    b.BackgroundColor3=strokeColor; b.BackgroundTransparency=0.85
    b.Text=text; b.TextColor3=strokeColor; b.TextScaled=false; b.TextSize=math.floor(13*scale); b.FontFace=Font.new("rbxassetid://12187368843")
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4*scale)
    local stroke=Instance.new("UIStroke",b)
    stroke.Color=strokeColor; stroke.Thickness=1.5; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return b
end

local dcBtn=createBtn("💬 Discord",Color3.fromRGB(114, 137, 218), 105)
local waBtn=createBtn("📱 WhatsApp",Color3.fromRGB(37, 211, 102), 110)

local links={wa="https://whatsapp.com/channel/0029VbCBSBOCRs1pRNYpPN0r",dc="https://discord.gg/HB9gqZGMnT"}
local function copyLink(btn,linkType)
    if setclipboard then setclipboard(links[linkType]); local old=btn.Text; btn.Text="Copied!"; task.delay(1.5,function() btn.Text=old end) end
end
waBtn.MouseButton1Click:Connect(function() copyLink(waBtn,"wa") end)
dcBtn.MouseButton1Click:Connect(function() copyLink(dcBtn,"dc") end)

-- INTRO LOADING BAR
local loadContent=Instance.new("CanvasGroup",main)
loadContent.Size=UDim2.new(1,0,0,38*scale); loadContent.Position=UDim2.new(0,0,0,117*scale)
loadContent.BackgroundTransparency=1; loadContent.GroupTransparency=1

local loadBg=Instance.new("Frame",loadContent)
loadBg.Size=UDim2.new(0,230*scale,0,4*scale); loadBg.Position=UDim2.new(0.5,-115*scale,0,0)
loadBg.BackgroundColor3=Color3.fromRGB(20,26,32); loadBg.BorderSizePixel=0
Instance.new("UICorner",loadBg).CornerRadius=UDim.new(1,0)

local loadFill=Instance.new("Frame",loadBg)
loadFill.Size=UDim2.new(0,0,1,0); loadFill.BackgroundColor3=Color3.fromRGB(255,255,255)
Instance.new("UICorner",loadFill).CornerRadius=UDim.new(1,0)
local loadGrad=Instance.new("UIGradient",loadFill)
loadGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,105,180)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,210,255))})

local loadTxt=Instance.new("TextLabel",loadContent)
loadTxt.Size=UDim2.new(1,0,0,14*scale); loadTxt.Position=UDim2.new(0,0,0,8*scale)
loadTxt.BackgroundTransparency=1; loadTxt.Text="Injecting Victoria Nuke..."; loadTxt.TextColor3=Color3.fromRGB(150,165,175)
loadTxt.TextScaled=false; loadTxt.TextSize=10*scale; loadTxt.FontFace=Font.new("rbxassetid://12187368843"); loadTxt.ZIndex=6
loadTxt.TextXAlignment=Enum.TextXAlignment.Center

-- MAIN FEATURES SCROLL GROUP
local scrollGroup=Instance.new("CanvasGroup",main)
scrollGroup.Size=UDim2.new(1,0,1,-70*scale); scrollGroup.Position=UDim2.new(0,0,0,70*scale)
scrollGroup.BackgroundTransparency=1; scrollGroup.GroupTransparency=1; scrollGroup.Visible=false

-- DRAG
local dragging,dragStart,dragPos=false,nil,nil
header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=i.Position; dragPos=main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        main.Position=UDim2.new(dragPos.X.Scale,dragPos.X.Offset+d.X,dragPos.Y.Scale,dragPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dragging=false end)

-- SCROLL
local scroll=Instance.new("ScrollingFrame",scrollGroup)
scroll.Size=UDim2.new(1,0,1,0); scroll.Position=UDim2.new(0,0,0,0)
scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3*scale; scroll.ScrollBarImageColor3=Color3.fromRGB(56,182,255)
scroll.ScrollBarImageTransparency=0.5; scroll.CanvasSize=UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.ZIndex=2
local layout=Instance.new("UIListLayout",scroll)
layout.Padding=UDim.new(0,8*scale); layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
layout.SortOrder=Enum.SortOrder.LayoutOrder
local padMain=Instance.new("UIPadding",scroll)
padMain.PaddingTop=UDim.new(0,10*scale); padMain.PaddingBottom=UDim.new(0,14*scale)
padMain.PaddingLeft=UDim.new(0,10*scale); padMain.PaddingRight=UDim.new(0,10*scale)

-- HELPERS
local function mkSecLbl(text,order)
    local l=Instance.new("TextLabel",scroll); l.Size=UDim2.new(1,0,0,16*scale)
    l.BackgroundTransparency=1; l.Text=text; l.TextColor3=Color3.fromRGB(60,75,70)
    l.TextScaled=true; l.FontFace=Font.new("rbxassetid://12187368843"); l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=3; l.LayoutOrder=order
end
local function mkDivider(order)
    local d=Instance.new("Frame",scroll); d.Size=UDim2.new(1,0,0,1)
    d.BackgroundColor3=Color3.fromRGB(28,34,40); d.BorderSizePixel=0; d.ZIndex=3; d.LayoutOrder=order
end
local function mkCard(h,order)
    local f=Instance.new("Frame",scroll); f.Size=UDim2.new(1,0,0,h*scale)
    f.BackgroundColor3=Color3.fromRGB(20,20,28); f.BorderSizePixel=0; f.ZIndex=3; f.LayoutOrder=order
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8*scale)
    local s=Instance.new("UIStroke",f); s.Thickness=1
    local sg = Instance.new("UIGradient", s)
    sg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255))
    })
    return f,s
end
local function mkInfoCard(ltext,vtext,order)
    local f,s=mkCard(28,order)
    local dot=Instance.new("Frame",f); dot.Size=UDim2.new(0,7*scale,0,7*scale)
    dot.Position=UDim2.new(0,9*scale,0.5,-3.5*scale); dot.BackgroundColor3=Color3.fromRGB(56,182,255)
    dot.BorderSizePixel=0; dot.ZIndex=4; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local ll=Instance.new("TextLabel",f); ll.Size=UDim2.new(0.5,-10*scale,1,0)
    ll.Position=UDim2.new(0,22*scale,0,0); ll.BackgroundTransparency=1; ll.Text=ltext
    ll.TextColor3=Color3.fromRGB(90,105,100); ll.TextScaled=true; ll.FontFace=Font.new("rbxassetid://12187368843")
    ll.TextXAlignment=Enum.TextXAlignment.Left; ll.ZIndex=4
    local vl=Instance.new("TextLabel",f); vl.Name="Value"; vl.Size=UDim2.new(0.5,-10*scale,1,0)
    vl.Position=UDim2.new(0.5,0,0,0); vl.BackgroundTransparency=1; vl.Text=vtext
    vl.TextColor3=Color3.fromRGB(56,182,255); vl.TextScaled=true; vl.FontFace=Font.new("rbxassetid://12187368843")
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.ZIndex=4
    return f,dot,vl,s
end
local function mkToggleCard(mainTxt,subTxt,accent,order)
    local f,s=mkCard(52,order)
    local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,3*scale,0,30*scale)
    bar.Position=UDim2.new(0,10*scale,0.5,-15*scale); bar.BackgroundColor3=accent
    bar.BorderSizePixel=0; bar.ZIndex=4; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local ml=Instance.new("TextLabel",f); ml.Size=UDim2.new(1,-80*scale,0,22*scale)
    ml.Position=UDim2.new(0,22*scale,0,7*scale); ml.BackgroundTransparency=1; ml.Text=mainTxt
    ml.TextColor3=Color3.fromRGB(200,215,220); ml.TextScaled=true; ml.FontFace=Font.new("rbxassetid://12187368843")
    ml.TextXAlignment=Enum.TextXAlignment.Left; ml.ZIndex=4
    local sl=Instance.new("TextLabel",f); sl.Size=UDim2.new(1,-80*scale,0,14*scale)
    sl.Position=UDim2.new(0,22*scale,0,30*scale); sl.BackgroundTransparency=1; sl.Text=subTxt
    sl.TextColor3=Color3.fromRGB(60,75,70); sl.TextScaled=true; sl.FontFace=Font.new("rbxassetid://12187368843")
    sl.TextXAlignment=Enum.TextXAlignment.Left; ml.ZIndex=4
    local badge=Instance.new("TextLabel",f); badge.Size=UDim2.new(0,42*scale,0,20*scale)
    badge.Position=UDim2.new(1,-52*scale,0.5,-10*scale); badge.BackgroundColor3=Color3.fromRGB(22,26,30)
    badge.BorderSizePixel=0; badge.Text="OFF"; badge.TextColor3=Color3.fromRGB(80,90,85)
    badge.TextScaled=true; badge.FontFace=Font.new("rbxassetid://12187368843"); badge.ZIndex=4
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,5*scale)
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=5
    btn.MouseEnter:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(20,26,32)}):Play()
        TweenService:Create(s,TweenInfo.new(0.15),{Color=accent,Transparency=0.5}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(16,20,25)}):Play()
        TweenService:Create(s,TweenInfo.new(0.15),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
    end)
    return btn,badge,bar,s,f
end

-- ============================================================
-- STATUS BAR (order 1)
-- ============================================================
local statCard,_=mkCard(28,1)
local statDot=Instance.new("Frame",statCard); statDot.Size=UDim2.new(0,7*scale,0,7*scale)
statDot.Position=UDim2.new(0,9*scale,0.5,-3.5*scale); statDot.BackgroundColor3=Color3.fromRGB(80,80,80)
statDot.BorderSizePixel=0; statDot.ZIndex=4; Instance.new("UICorner",statDot).CornerRadius=UDim.new(1,0)
local statLbl=Instance.new("TextLabel",statCard); statLbl.Size=UDim2.new(1,-26*scale,1,0)
statLbl.Position=UDim2.new(0,22*scale,0,0); statLbl.BackgroundTransparency=1; statLbl.Text="status: idle"
statLbl.TextColor3=Color3.fromRGB(90,105,100); statLbl.TextScaled=true; statLbl.FontFace=Font.new("rbxassetid://12187368843")
statLbl.TextXAlignment=Enum.TextXAlignment.Left; statLbl.ZIndex=4
state.setStatus = function(text,color)
    color=color or Color3.fromRGB(90,105,100)
    statLbl.Text="status: "..text; statLbl.TextColor3=color; statDot.BackgroundColor3=color
end

-- ============================================================
-- SECTION: AUTO MERGE (order 10-12)
-- ============================================================
mkSecLbl("// auto merge (hit & run)",10)
local mergeBtn,mergeBadge,_,mergeStroke=mkToggleCard("AUTO MERGE","// otomatis menyatukan nuke",Color3.fromRGB(56,182,255),11)
mergeBtn.MouseButton1Click:Connect(function()
    state.autoMergeEnabled = not state.autoMergeEnabled
    if state.autoMergeEnabled then
        mergeBadge.Text="ON"; mergeBadge.TextColor3=Color3.fromRGB(56,182,255); mergeBadge.BackgroundColor3=Color3.fromRGB(15,35,50)
        TweenService:Create(mergeStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(56,182,255),Transparency=0.4}):Play()
        state.setStatus("Auto Merge ON",Color3.fromRGB(56,182,255))
    else
        mergeBadge.Text="OFF"; mergeBadge.TextColor3=Color3.fromRGB(80,90,85); mergeBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
        TweenService:Create(mergeStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
        state.setStatus("Auto Merge OFF",Color3.fromRGB(90,105,100))
    end
end)

-- MERGE ONCE BUTTON
local onceCard, onceStroke = mkCard(30, 12)
local onceLbl = Instance.new("TextLabel", onceCard)
onceLbl.Size = UDim2.new(1, -80 * scale, 1, 0)
onceLbl.Position = UDim2.new(0, 12 * scale, 0, 0)
onceLbl.BackgroundTransparency = 1
onceLbl.Text = "MERGE ONCE NOW"
onceLbl.TextColor3 = Color3.fromRGB(255, 105, 180)
onceLbl.TextScaled = true
onceLbl.FontFace = Font.new("rbxassetid://12187368843")
onceLbl.TextXAlignment = Enum.TextXAlignment.Left
onceLbl.ZIndex = 4

local onceBadge = Instance.new("TextLabel", onceCard)
onceBadge.Size = UDim2.new(0, 40 * scale, 0, 18 * scale)
onceBadge.Position = UDim2.new(1, -50 * scale, 0.5, -9 * scale)
onceBadge.BackgroundColor3 = Color3.fromRGB(35, 15, 25)
onceBadge.BorderSizePixel = 0
onceBadge.Text = "🚀"
onceBadge.TextColor3 = Color3.fromRGB(255, 105, 180)
onceBadge.TextScaled = true
onceBadge.FontFace = Font.new("rbxassetid://12187368843")
onceBadge.ZIndex = 4
Instance.new("UICorner", onceBadge).CornerRadius = UDim.new(0, 5 * scale)

local onceBtn = Instance.new("TextButton", onceCard)
onceBtn.Size = UDim2.new(1, 0, 1, 0)
onceBtn.BackgroundTransparency = 1
onceBtn.Text = ""
onceBtn.ZIndex = 5

onceBtn.MouseEnter:Connect(function() TweenService:Create(onceCard, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(20, 26, 32) }):Play() end)
onceBtn.MouseLeave:Connect(function() TweenService:Create(onceCard, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(16, 20, 25) }):Play() end)
onceBtn.MouseButton1Click:Connect(function()
    state.forceMergeOnce = true
end)

-- ============================================================
-- SECTION: TIMING CONFIG (order 20-22)
-- ============================================================
mkDivider(20); mkSecLbl("// timing config",21)
local timingCard,_=mkCard(48,22)

-- PICKUP WAIT
local pLbl=Instance.new("TextLabel",timingCard); pLbl.Size=UDim2.new(0.5,0,0,16*scale)
pLbl.Position=UDim2.new(0,12*scale,0,4*scale); pLbl.BackgroundTransparency=1; pLbl.Text="pickup wait:"
pLbl.TextColor3=Color3.fromRGB(90,105,100); pLbl.TextScaled=true; pLbl.FontFace=Font.new("rbxassetid://12187368843"); pLbl.TextXAlignment=Enum.TextXAlignment.Left; pLbl.ZIndex=4
local pVal=Instance.new("TextLabel",timingCard); pVal.Size=UDim2.new(0.5,-10*scale,0,16*scale)
pVal.Position=UDim2.new(0.5,0,0,4*scale); pVal.BackgroundTransparency=1
pVal.Text=state.waktuTungguPickup.."s"; pVal.TextColor3=Color3.fromRGB(255,185,55)
pVal.TextScaled=true; pVal.FontFace=Font.new("rbxassetid://12187368843"); pVal.TextXAlignment=Enum.TextXAlignment.Right; pVal.ZIndex=4

local pBtns={}
for idx, sec in ipairs({0.1, 0.5, 1.0, 1.5, 2.0}) do
    local b=Instance.new("TextButton",timingCard); b.Size=UDim2.new(0,35*scale,0,18*scale)
    b.Position=UDim2.new(0, 10*scale + (idx-1)*40*scale, 0, 24*scale)
    b.BackgroundColor3=Color3.fromRGB(22,28,34); b.BorderSizePixel=0
    b.Text=sec; b.TextColor3=Color3.fromRGB(80,95,90)
    b.TextScaled=true; b.FontFace=Font.new("rbxassetid://12187368843"); b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5*scale)
    pBtns[sec]=b
end

local function refreshPBtns()
    pVal.Text = state.waktuTungguPickup .. "s"
    for s,b in pairs(pBtns) do
        TweenService:Create(b,TweenInfo.new(0.12),{
            BackgroundColor3=s==state.waktuTungguPickup and Color3.fromRGB(10,32,48) or Color3.fromRGB(22,28,34),
            TextColor3=s==state.waktuTungguPickup and Color3.fromRGB(56,182,255) or Color3.fromRGB(80,95,90)
        }):Play()
    end
end
refreshPBtns()
for sec,b in pairs(pBtns) do b.MouseButton1Click:Connect(function() state.waktuTungguPickup=sec; refreshPBtns() end) end

-- ============================================================
-- SECTION: ANTI AFK (order 30-32)
-- ============================================================
mkDivider(30); mkSecLbl("// anti afk (prevents idle kick)", 31)
local afkBtn,afkBadge,_,afkStroke2=mkToggleCard("ANTI AFK","// auto click to prevent disconnect",Color3.fromRGB(56,182,255),32)
afkBtn.MouseButton1Click:Connect(function()
    state.afkEnabled = not state.afkEnabled
    if state.afkEnabled then
        afkBadge.Text="ON"; afkBadge.TextColor3=Color3.fromRGB(255,185,55); afkBadge.BackgroundColor3=Color3.fromRGB(40,28,6)
        TweenService:Create(afkStroke2,TweenInfo.new(0.2),{Color=Color3.fromRGB(255,185,55),Transparency=0.4}):Play()
        state.setStatus("anti afk ON",Color3.fromRGB(255,185,55))
    else
        afkBadge.Text="OFF"; afkBadge.TextColor3=Color3.fromRGB(80,90,85); afkBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
        TweenService:Create(afkStroke2,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
        state.setStatus("anti afk OFF",Color3.fromRGB(90,105,100))
    end
end)

-- ============================================================
-- SECTION: SUB PANEL (COMBAT & UPGRADES)
-- ============================================================
mkDivider(40)

local cbCard,cbStroke=mkCard(52,41)
local cbAccBar=Instance.new("Frame",cbCard); cbAccBar.Size=UDim2.new(0,3*scale,0,30*scale)
cbAccBar.Position=UDim2.new(0,10*scale,0.5,-15*scale); cbAccBar.BackgroundColor3=Color3.fromRGB(255,105,180)
cbAccBar.BorderSizePixel=0; cbAccBar.ZIndex=4; Instance.new("UICorner",cbAccBar).CornerRadius=UDim.new(1,0)
local cbMainLbl=Instance.new("TextLabel",cbCard); cbMainLbl.Size=UDim2.new(1,-80*scale,0,22*scale)
cbMainLbl.Position=UDim2.new(0,22*scale,0,7*scale); cbMainLbl.BackgroundTransparency=1
cbMainLbl.Text="COMBAT & UPGRADES"; cbMainLbl.TextColor3=Color3.fromRGB(200,215,220)
cbMainLbl.TextScaled=true; cbMainLbl.FontFace=Font.new("rbxassetid://12187368843"); cbMainLbl.TextXAlignment=Enum.TextXAlignment.Left; cbMainLbl.ZIndex=4
local cbSubLbl=Instance.new("TextLabel",cbCard); cbSubLbl.Size=UDim2.new(1,-80*scale,0,14*scale)
cbSubLbl.Position=UDim2.new(0,22*scale,0,30*scale); cbSubLbl.BackgroundTransparency=1
cbSubLbl.Text="// click to open panel"; cbSubLbl.TextColor3=Color3.fromRGB(60,75,70)
cbSubLbl.TextScaled=true; cbSubLbl.FontFace=Font.new("rbxassetid://12187368843"); cbSubLbl.TextXAlignment=Enum.TextXAlignment.Left; cbSubLbl.ZIndex=4
local cbBadge=Instance.new("TextLabel",cbCard); cbBadge.Size=UDim2.new(0,42*scale,0,20*scale)
cbBadge.Position=UDim2.new(1,-52*scale,0.5,-10*scale); cbBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
cbBadge.BorderSizePixel=0; cbBadge.Text=">>>"; cbBadge.TextColor3=Color3.fromRGB(255,105,180)
cbBadge.TextScaled=true; cbBadge.FontFace=Font.new("rbxassetid://12187368843"); cbBadge.ZIndex=4
Instance.new("UICorner",cbBadge).CornerRadius=UDim.new(0,5*scale)
local cbOpenBtn=Instance.new("TextButton",cbCard); cbOpenBtn.Size=UDim2.new(1,0,1,0)
cbOpenBtn.BackgroundTransparency=1; cbOpenBtn.Text=""; cbOpenBtn.ZIndex=5
cbOpenBtn.MouseEnter:Connect(function() TweenService:Create(cbCard,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(20,26,32)}):Play(); TweenService:Create(cbStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(255,105,180),Transparency=0.5}):Play() end)
cbOpenBtn.MouseLeave:Connect(function() TweenService:Create(cbCard,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(16,20,25)}):Play(); TweenService:Create(cbStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play() end)


-- SUB-PANEL UI
local SUB_W = 280 * scale
local SUB_H = FULL_H

local subPanel = Instance.new("Frame", screenGui)
subPanel.Name = "CombatPanel"
subPanel.Size = UDim2.new(0, SUB_W, 0, SUB_H)
subPanel.Position = UDim2.new(-1, 0, 0.5, -SUB_H / 2)
subPanel.BackgroundColor3 = Color3.fromRGB(10, 12, 15)
subPanel.BorderSizePixel = 0
subPanel.ClipsDescendants = true
subPanel.Visible = false
subPanel.ZIndex = 10
Instance.new("UICorner", subPanel).CornerRadius = UDim.new(0, 12 * scale)

local subStk = Instance.new("UIStroke", subPanel)
subStk.Color = Color3.fromRGB(40, 50, 60); subStk.Thickness = 1; subStk.Transparency = 0

local sHdr = Instance.new("Frame", subPanel)
sHdr.Size = UDim2.new(1, 0, 0, HDR_H)
sHdr.BackgroundColor3 = Color3.fromRGB(14, 17, 21); sHdr.BorderSizePixel = 0; sHdr.ZIndex = 12
Instance.new("UIPadding", sHdr).PaddingLeft = UDim.new(0, 12 * scale)

local sDiv = Instance.new("Frame", sHdr)
sDiv.Size = UDim2.new(1, 0, 0, 1); sDiv.Position = UDim2.new(0, 0, 1, -1)
sDiv.BackgroundColor3 = Color3.fromRGB(255, 105, 180); sDiv.BackgroundTransparency = 0.5; sDiv.BorderSizePixel = 0; sDiv.ZIndex = 13

local sTitleLbl = Instance.new("TextLabel", sHdr)
sTitleLbl.Size = UDim2.new(1, -60 * scale, 1, 0); sTitleLbl.Position = UDim2.new(0, 12 * scale, 0, 0)
sTitleLbl.BackgroundTransparency = 1; sTitleLbl.Text = "⚔️ Combat & Upgrades"
sTitleLbl.TextColor3 = Color3.fromRGB(200, 220, 235); sTitleLbl.TextScaled = true; sTitleLbl.FontFace = Font.new("rbxassetid://12187368843")
sTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; sTitleLbl.ZIndex = 13

local sClose = Instance.new("TextButton", sHdr)
sClose.Size = UDim2.new(0, 24 * scale, 0, 24 * scale); sClose.Position = UDim2.new(1, -30 * scale, 0.5, -12 * scale)
sClose.BackgroundColor3 = Color3.fromRGB(220, 60, 60); sClose.BackgroundTransparency = 0.85; sClose.Text = "X"
sClose.TextColor3 = Color3.fromRGB(220, 60, 60); sClose.TextScaled = false; sClose.TextSize = math.floor(14 * scale); sClose.FontFace = Font.new("rbxassetid://12187368843"); sClose.ZIndex = 13
Instance.new("UICorner", sClose).CornerRadius = UDim.new(0, 4 * scale)
local closeStrokeSub = Instance.new("UIStroke", sClose)
closeStrokeSub.Color = Color3.fromRGB(220, 60, 60); closeStrokeSub.Thickness = 1.5; closeStrokeSub.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local sScroll = Instance.new("ScrollingFrame", subPanel)
sScroll.Size = UDim2.new(1, 0, 1, -HDR_H); sScroll.Position = UDim2.new(0, 0, 0, HDR_H)
sScroll.BackgroundTransparency = 1; sScroll.BorderSizePixel = 0
sScroll.ScrollBarThickness = 3 * scale; sScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
sScroll.ScrollBarImageTransparency = 0.5; sScroll.CanvasSize = UDim2.new(0, 0, 0, 0); sScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; sScroll.ZIndex = 12

local sLayout = Instance.new("UIListLayout", sScroll)
sLayout.Padding = UDim.new(0, 8 * scale); sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; sLayout.SortOrder = Enum.SortOrder.LayoutOrder
local sPad2 = Instance.new("UIPadding", sScroll)
sPad2.PaddingTop = UDim.new(0, 10 * scale); sPad2.PaddingBottom = UDim.new(0, 10 * scale); sPad2.PaddingLeft = UDim.new(0, 10 * scale); sPad2.PaddingRight = UDim.new(0, 10 * scale)

local function mkSCard(h, order)
    local f = Instance.new("Frame", sScroll)
    f.Size = UDim2.new(1, 0, 0, h * scale); f.BackgroundColor3 = Color3.fromRGB(20, 20, 28); f.BorderSizePixel = 0; f.ZIndex = 13; f.LayoutOrder = order
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8 * scale)
    local s = Instance.new("UIStroke", f)
    s.Color = Color3.fromRGB(30, 38, 46); s.Thickness = 1
    return f, s
end

local function mkSLbl(text, order)
    local l = Instance.new("TextLabel", sScroll)
    l.Size = UDim2.new(1, 0, 0, 14 * scale); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = Color3.fromRGB(60, 75, 70)
    l.TextScaled = true; l.FontFace = Font.new("rbxassetid://12187368843"); l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 13; l.LayoutOrder = order
end

-- COMBAT FEATURES IN SUB PANEL
mkSLbl("// auto nuke combat", 1)

-- Player List Scroller
local pCard, pStk = mkSCard(150, 2)
local pTitle = Instance.new("TextLabel", pCard)
pTitle.Size = UDim2.new(1, -20*scale, 0, 16*scale); pTitle.Position = UDim2.new(0, 10*scale, 0, 4*scale)
pTitle.BackgroundTransparency = 1; pTitle.Text = "Target: None"; pTitle.TextColor3 = Color3.fromRGB(200,215,220)
pTitle.TextScaled = true; pTitle.FontFace = Font.new("rbxassetid://12187368843"); pTitle.TextXAlignment = Enum.TextXAlignment.Left; pTitle.ZIndex = 14

local pListFrame=Instance.new("ScrollingFrame",pCard)
pListFrame.Size=UDim2.new(1,-16*scale,0,122*scale); pListFrame.Position = UDim2.new(0, 8*scale, 0, 22*scale)
pListFrame.BackgroundTransparency=1; pListFrame.BorderSizePixel=0; pListFrame.ScrollBarThickness=2*scale
pListFrame.ScrollBarImageColor3=Color3.fromRGB(255,105,180); pListFrame.CanvasSize=UDim2.new(0,0,0,0); pListFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
pListFrame.ZIndex=14
local pL2=Instance.new("UIListLayout",pListFrame); pL2.FillDirection = Enum.FillDirection.Vertical; pL2.Padding=UDim.new(0,4*scale); pL2.SortOrder=Enum.SortOrder.LayoutOrder

local function refreshPlayers()
    for _, c in ipairs(pListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", pListFrame)
            b.Size = UDim2.new(0, 80*scale, 0, 24*scale)
            b.BackgroundColor3 = (state.autoNukeTarget == p.Name) and Color3.fromRGB(35, 15, 25) or Color3.fromRGB(22, 26, 30)
            b.Text = p.Name; b.TextColor3 = (state.autoNukeTarget == p.Name) and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(120, 135, 145)
            b.TextScaled = true; b.FontFace = Font.new("rbxassetid://12187368843"); b.ZIndex = 15
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4*scale)
            b.MouseButton1Click:Connect(function()
                state.autoNukeTarget = p.Name
                pTitle.Text = "Target: " .. p.Name
                refreshPlayers()
            end)
        end
    end
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers); Players.PlayerRemoving:Connect(refreshPlayers)

-- Auto Nuke Toggle
local function mkSToggle(mainTxt, accent, order)
    local f,s=mkSCard(34,order)
    local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,3*scale,0,20*scale)
    bar.Position=UDim2.new(0,8*scale,0.5,-10*scale); bar.BackgroundColor3=accent; bar.BorderSizePixel=0; bar.ZIndex=14
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local ml=Instance.new("TextLabel",f); ml.Size=UDim2.new(1,-80*scale,0,20*scale)
    ml.Position=UDim2.new(0,18*scale,0,7*scale); ml.BackgroundTransparency=1; ml.Text=mainTxt
    ml.TextColor3=Color3.fromRGB(200,215,220); ml.TextScaled=true; ml.FontFace=Font.new("rbxassetid://12187368843"); ml.TextXAlignment=Enum.TextXAlignment.Left; ml.ZIndex=14
    local badge=Instance.new("TextLabel",f); badge.Size=UDim2.new(0,42*scale,0,18*scale)
    badge.Position=UDim2.new(1,-52*scale,0.5,-9*scale); badge.BackgroundColor3=Color3.fromRGB(22,26,30); badge.BorderSizePixel=0; badge.Text="OFF"; badge.TextColor3=Color3.fromRGB(80,90,85)
    badge.TextScaled=true; badge.FontFace=Font.new("rbxassetid://12187368843"); badge.ZIndex=14
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,5*scale)
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=15
    return btn,badge,s,f
end

local atkCard, atkStroke = mkSCard(30, 3)
local atkLbl = Instance.new("TextLabel", atkCard)
atkLbl.Size = UDim2.new(1, -60 * scale, 1, 0); atkLbl.Position = UDim2.new(0, 10 * scale, 0, 0)
atkLbl.BackgroundTransparency = 1; atkLbl.Text = "MANUAL ATTACK"; atkLbl.TextColor3 = Color3.fromRGB(255, 60, 60)
atkLbl.TextScaled = true; atkLbl.FontFace = Font.new("rbxassetid://12187368843"); atkLbl.TextXAlignment = Enum.TextXAlignment.Left; atkLbl.ZIndex = 14
local atkIcon = Instance.new("TextLabel", atkCard)
atkIcon.Size = UDim2.new(0, 30 * scale, 0, 18 * scale); atkIcon.Position = UDim2.new(1, -40 * scale, 0.5, -9 * scale)
atkIcon.BackgroundColor3 = Color3.fromRGB(35, 15, 15); atkIcon.BorderSizePixel = 0; atkIcon.Text = "💣"; atkIcon.TextColor3 = Color3.fromRGB(255, 60, 60)
atkIcon.TextScaled = true; atkIcon.FontFace = Font.new("rbxassetid://12187368843"); atkIcon.ZIndex = 14
Instance.new("UICorner", atkIcon).CornerRadius = UDim.new(0, 5 * scale)
local nukeBtn = Instance.new("TextButton", atkCard)
nukeBtn.Size = UDim2.new(1, 0, 1, 0); nukeBtn.BackgroundTransparency = 1; nukeBtn.Text = ""; nukeBtn.ZIndex = 15
nukeBtn.MouseEnter:Connect(function() TweenService:Create(atkCard, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(30, 20, 20) }):Play() end)
nukeBtn.MouseLeave:Connect(function() TweenService:Create(atkCard, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(20, 20, 28) }):Play() end)
nukeBtn.MouseButton1Click:Connect(function()
    state.forceManualAttack = true
end)

local cityBtn, cityBadge, cityStk = mkSToggle("AUTO CITY EVENT", Color3.fromRGB(255, 185, 55), 4)
cityBtn.MouseButton1Click:Connect(function()
    state.autoAttackCity = not state.autoAttackCity
    if state.autoAttackCity then
        cityBadge.Text="ON"; cityBadge.TextColor3=Color3.fromRGB(255, 185, 55); cityBadge.BackgroundColor3=Color3.fromRGB(40, 30, 10)
        TweenService:Create(cityStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(255, 185, 55),Transparency=0.4}):Play()
    else
        cityBadge.Text="OFF"; cityBadge.TextColor3=Color3.fromRGB(80,90,85); cityBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
        TweenService:Create(cityStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
    end
end)

local brutalBtn, brutalBadge, brutalStk = mkSToggle("BRUTAL ATTACK", Color3.fromRGB(255, 0, 0), 5)
brutalBtn.MouseButton1Click:Connect(function()
    state.brutalAttackEnabled = not state.brutalAttackEnabled
    if state.brutalAttackEnabled then
        brutalBadge.Text="ON"; brutalBadge.TextColor3=Color3.fromRGB(255, 0, 0); brutalBadge.BackgroundColor3=Color3.fromRGB(40, 15, 15)
        TweenService:Create(brutalStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(255, 0, 0),Transparency=0.4}):Play()
    else
        brutalBadge.Text="OFF"; brutalBadge.TextColor3=Color3.fromRGB(80,90,85); brutalBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
        TweenService:Create(brutalStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
    end
end)

local camBtn, camBadge, camStk = mkSToggle("DISABLE CAMERA", Color3.fromRGB(200, 200, 200), 6)
camBtn.MouseButton1Click:Connect(function()
    state.disableLaunchCamera = not state.disableLaunchCamera
    if state.disableLaunchCamera then
        camBadge.Text="ON"; camBadge.TextColor3=Color3.fromRGB(200, 200, 200); camBadge.BackgroundColor3=Color3.fromRGB(40, 40, 40)
        TweenService:Create(camStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(200, 200, 200),Transparency=0.4}):Play()
    else
        camBadge.Text="OFF"; camBadge.TextColor3=Color3.fromRGB(80,90,85); camBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
        TweenService:Create(camStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
    end
end)

local counterBtn, counterBadge, counterStk = mkSToggle("AUTO COUNTER ATTACK", Color3.fromRGB(255, 100, 50), 7)
counterBtn.MouseButton1Click:Connect(function()
    state.autoCounterAttack = not state.autoCounterAttack
    if state.autoCounterAttack then
        counterBadge.Text="ON"; counterBadge.TextColor3=Color3.fromRGB(255, 100, 50); counterBadge.BackgroundColor3=Color3.fromRGB(40, 20, 10)
        TweenService:Create(counterStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(255, 100, 50),Transparency=0.4}):Play()
    else
        counterBadge.Text="OFF"; counterBadge.TextColor3=Color3.fromRGB(80,90,85); counterBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
        TweenService:Create(counterStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
    end
end)

mkSLbl("// commander event", 7)

local cCard, cStk = mkSCard(150, 8)
local cTitle = Instance.new("TextLabel", cCard)
cTitle.Size = UDim2.new(1, -40*scale, 0, 16*scale); cTitle.Position = UDim2.new(0, 10*scale, 0, 4*scale)
cTitle.BackgroundTransparency = 1; cTitle.Text = "Cmdr Target: None"; cTitle.TextColor3 = Color3.fromRGB(200,215,220)
cTitle.TextScaled = true; cTitle.FontFace = Font.new("rbxassetid://12187368843"); cTitle.TextXAlignment = Enum.TextXAlignment.Left; cTitle.ZIndex = 14

local cRefresh = Instance.new("TextButton", cCard)
cRefresh.Size = UDim2.new(0, 24*scale, 0, 16*scale); cRefresh.Position = UDim2.new(1, -34*scale, 0, 4*scale)
cRefresh.BackgroundColor3 = Color3.fromRGB(35, 35, 45); cRefresh.Text = "R"
cRefresh.TextColor3 = Color3.fromRGB(200, 200, 200); cRefresh.TextScaled = true; cRefresh.ZIndex = 15
Instance.new("UICorner", cRefresh).CornerRadius = UDim.new(0, 4*scale)

local cListFrame = Instance.new("ScrollingFrame", cCard)
cListFrame.Size = UDim2.new(1, -16*scale, 0, 122*scale); cListFrame.Position = UDim2.new(0, 8*scale, 0, 22*scale)
cListFrame.BackgroundTransparency = 1; cListFrame.BorderSizePixel = 0; cListFrame.ScrollBarThickness = 2*scale
cListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 128); cListFrame.CanvasSize = UDim2.new(0,0,0,0); cListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
cListFrame.ZIndex = 14
local cL2 = Instance.new("UIListLayout", cListFrame); cL2.FillDirection = Enum.FillDirection.Vertical; cL2.Padding = UDim.new(0,4*scale); cL2.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshCommanders()
    local existing = {}
    for _, c in ipairs(cListFrame:GetChildren()) do 
        if c:IsA("TextButton") then existing[c.Name] = c end 
    end
    
    local currentCmdrs = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:lower():match("claimablecommander") and (obj:IsA("Model") or obj:IsA("BasePart")) then
            currentCmdrs[obj.Name] = true
            local b = existing[obj.Name]
            if not b then
                b = Instance.new("TextButton", cListFrame)
                b.Name = obj.Name
                b.Size = UDim2.new(1, -8*scale, 0, 24*scale)
                b.Text = obj.Name
                b.TextScaled = true; b.FontFace = Font.new("rbxassetid://12187368843"); b.ZIndex = 15
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4*scale)
                b.MouseButton1Click:Connect(function()
                    state.commanderTargetName = obj.Name
                    cTitle.Text = "Cmdr: " .. obj.Name
                    refreshCommanders()
                end)
                existing[obj.Name] = b
            end
            
            b.BackgroundColor3 = (state.commanderTargetName == obj.Name) and Color3.fromRGB(15, 35, 25) or Color3.fromRGB(22, 26, 30)
            b.TextColor3 = (state.commanderTargetName == obj.Name) and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(120, 135, 145)
        end
    end
    
    for name, c in pairs(existing) do
        if not currentCmdrs[name] then c:Destroy() end
    end
end

task.spawn(function()
    while state.isScriptRunning do
        if state.autoAttackCommander or panel.Visible then
            pcall(refreshCommanders)
        end
        task.wait(0.5)
    end
end)

workspace.ChildAdded:Connect(function(child)
    if child.Name:lower():match("claimablecommander") then
        pcall(refreshCommanders)
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if child.Name:lower():match("claimablecommander") then
        pcall(refreshCommanders)
    end
end)
cRefresh.MouseButton1Click:Connect(refreshCommanders)
refreshCommanders()

local cmdBtn, cmdBadge, cmdStk = mkSToggle("AUTO COMMANDER", Color3.fromRGB(0, 255, 128), 9)
cmdBtn.MouseButton1Click:Connect(function()
    state.autoAttackCommander = not state.autoAttackCommander
    if state.autoAttackCommander then
        cmdBadge.Text="ON"; cmdBadge.TextColor3=Color3.fromRGB(0, 255, 128); cmdBadge.BackgroundColor3=Color3.fromRGB(10, 40, 20)
        TweenService:Create(cmdStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(0, 255, 128),Transparency=0.4}):Play()
    else
        cmdBadge.Text="OFF"; cmdBadge.TextColor3=Color3.fromRGB(80,90,85); cmdBadge.BackgroundColor3=Color3.fromRGB(22,26,30)
        TweenService:Create(cmdStk,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
    end
end)

mkSLbl("// auto upgrades", 20)

local function attachToggle(btn, badge, stk, stateKey, color)
    btn.MouseButton1Click:Connect(function()
        state[stateKey] = not state[stateKey]
        if state[stateKey] then
            badge.Text="ON"; badge.TextColor3=color; badge.BackgroundColor3=Color3.fromRGB(math.floor(color.R*255*0.2), math.floor(color.G*255*0.2), math.floor(color.B*255*0.2))
            TweenService:Create(stk,TweenInfo.new(0.2),{Color=color,Transparency=0.4}):Play()
        else
            badge.Text="OFF"; badge.TextColor3=Color3.fromRGB(80,90,85); badge.BackgroundColor3=Color3.fromRGB(22,26,30)
            TweenService:Create(stk,TweenInfo.new(0.2),{Color=Color3.fromRGB(30,38,46),Transparency=0}):Play()
        end
    end)
end

local upTBtn, upTBadge, upTStk = mkSToggle("UPGRADE TIER", Color3.fromRGB(56, 182, 255), 21)
attachToggle(upTBtn, upTBadge, upTStk, "autoUpgradeTier", Color3.fromRGB(56, 182, 255))

local upRBtn, upRBadge, upRStk = mkSToggle("UPGRADE RATE", Color3.fromRGB(56, 182, 255), 22)
attachToggle(upRBtn, upRBadge, upRStk, "autoUpgradeRate", Color3.fromRGB(56, 182, 255))

local upMBtn, upMBadge, upMStk = mkSToggle("UPGRADE MAX", Color3.fromRGB(56, 182, 255), 23)
attachToggle(upMBtn, upMBadge, upMStk, "autoUpgradeMax", Color3.fromRGB(56, 182, 255))

local upLBtn, upLBadge, upLStk = mkSToggle("LOCK BASE", Color3.fromRGB(56, 201, 106), 24)
attachToggle(upLBtn, upLBadge, upLStk, "autoLockBase", Color3.fromRGB(56, 201, 106))

local upReBtn, upReBadge, upReStk = mkSToggle("AUTO REBIRTH", Color3.fromRGB(182, 56, 255), 25)
attachToggle(upReBtn, upReBadge, upReStk, "autoRebirth", Color3.fromRGB(182, 56, 255))


-- LOGIC UNTUK BUKA/TUTUP SUB PANEL & INTRO ANIMASI
sClose.MouseButton1Click:Connect(function()
    TweenService:Create(subPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(-1, 0, 0.5, -SUB_H / 2) }):Play()
    task.wait(0.4); subPanel.Visible = false
end)

cbOpenBtn.MouseButton1Click:Connect(function()
    if subPanel.Visible then
        TweenService:Create(subPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(-1, 0, 0.5, -SUB_H / 2) }):Play()
        task.wait(0.4); subPanel.Visible = false
    else
        subPanel.Visible = true
        local targetX = main.Position.X.Offset + W + (10 * scale)
        subPanel.Position = UDim2.new(0, targetX, 0.5, -SUB_H / 2)
        TweenService:Create(subPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, targetX, 0.5, -SUB_H / 2) }):Play()
    end
end)

-- CLOSE & MINIMIZE BUTTON LOGIC
closeBtn.MouseButton1Click:Connect(function()
    state.isScriptRunning = false
    if subPanel.Visible then subPanel.Visible = false end
    local tw = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = UDim2.new(-0.4, 0, main.Position.Y.Scale, main.Position.Y.Offset) })
    tw:Play(); tw.Completed:Connect(function() screenGui:Destroy() end)
end)

local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        if subPanel.Visible then subPanel.Visible = false end
        scrollGroup.Visible = false
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, W, 0, 70 * scale) }):Play()
        minBtn.Text = "+"
    else
        local tw = TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, W, 0, FULL_H) })
        tw:Play()
        tw.Completed:Connect(function()
            if not isMinimized then scrollGroup.Visible = true end
        end)
        minBtn.Text = "-"
    end
end)

-- INTRO SEQUENCE
local tweenSmooth = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(uiScale, TweenInfo.new(0.9, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Scale = 1 }):Play()

task.delay(0.6, function()
    TweenService:Create(introContent, tweenSmooth, { GroupTransparency = 0 }):Play()
    TweenService:Create(loadContent, tweenSmooth, { GroupTransparency = 0 }):Play()
    
    TweenService:Create(loadFill, TweenInfo.new(2.5, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) }):Play()
    for i = 1, 10 do
        task.wait(0.25)
        loadTxt.Text = "Injecting Nuke" .. string.rep(".", i % 4)
    end
    loadTxt.Text = "Injection Complete!"
    task.wait(0.4)
    
    TweenService:Create(introContent, tweenSmooth, { GroupTransparency = 1 }):Play()
    TweenService:Create(loadContent, tweenSmooth, { GroupTransparency = 1 }):Play()
    
    task.wait(0.4)
    introContent.Visible = false
    loadContent.Visible = false
    
    scrollGroup.Visible = true
    main.AnchorPoint = Vector2.new(0, 0.5)
    main.Position = UDim2.new(0, main.AbsolutePosition.X, 0.5, 0)
    
    closeBtn.Visible = true
    minBtn.Visible = true
    
    local twExpand = TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, W, 0, FULL_H),
        Position = UDim2.new(0, 16 * scale, 0.5, 0)
    })
    twExpand:Play()
    
    twExpand.Completed:Wait()
    TweenService:Create(scrollGroup, tweenSmooth, { GroupTransparency = 0 }):Play()
    
    -- Sync sub panel jika main pindah
    main:GetPropertyChangedSignal("Position"):Connect(function()
        if subPanel.Visible then
            local targetX = main.Position.X.Offset + W + (10 * scale)
            subPanel.Position = UDim2.new(0, targetX, 0.5, -SUB_H / 2)
        end
    end)
end)