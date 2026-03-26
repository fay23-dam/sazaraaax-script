-- SERVICES
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 240, 0, 140)
Frame.Position = UDim2.new(0.5, -120, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "WORLD INTERACT"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

-- BUTTON 1: LOOT TAP
local BtnLoot = Instance.new("TextButton")
BtnLoot.Parent = Frame
BtnLoot.Size = UDim2.new(1,-20,0,40)
BtnLoot.Position = UDim2.new(0,10,0,40)
BtnLoot.Text = "LOOT TAP"
BtnLoot.TextScaled = true
BtnLoot.BackgroundColor3 = Color3.fromRGB(0,170,0)

-- BUTTON 2: CABINET TAP
local BtnCabinet = Instance.new("TextButton")
BtnCabinet.Parent = Frame
BtnCabinet.Size = UDim2.new(1,-20,0,40)
BtnCabinet.Position = UDim2.new(0,10,0,90)
BtnCabinet.Text = "CABINET TAP"
BtnCabinet.TextScaled = true
BtnCabinet.BackgroundColor3 = Color3.fromRGB(170,100,0)

-- FUNCTION TAP KE PART
local function tapPart(part)
    if not part then
        warn("Part tidak ditemukan")
        return
    end

    local worldPos = part.Position
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)

    if not onScreen then
        warn("Part tidak terlihat di layar")
        return
    end

    local x = screenPos.X
    local y = screenPos.Y
    local id = tick()

    VIM:SendTouchEvent(id, 0, x, y)
    task.wait(0.05)
    VIM:SendTouchEvent(id, 1, x, y)
    task.wait(0.05)
    VIM:SendTouchEvent(id, 2, x, y)
end

-- FUNCTION CARI INTERACTABLE PERTAMA
local function findFirstInteractable(parent)
    if not parent then return nil end
    for _, child in pairs(parent:GetChildren()) do
        if child:FindFirstChild("Interactable") then
            return child.Interactable
        end
    end
    return nil
end

-- BUTTON EVENTS
BtnLoot.MouseButton1Click:Connect(function()
    local lootsWorld = workspace:FindFirstChild("GameSystem")
        and workspace.GameSystem:FindFirstChild("Loots")
        and workspace.GameSystem.Loots:FindFirstChild("World")
    local target = findFirstInteractable(lootsWorld)
    tapPart(target)
end)

BtnCabinet.MouseButton1Click:Connect(function()
    local interactiveItem = workspace:FindFirstChild("GameSystem")
        and workspace.GameSystem:FindFirstChild("InteractiveItem")
    local target = findFirstInteractable(interactiveItem)
    tapPart(target)
end)
