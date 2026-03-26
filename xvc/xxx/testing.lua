local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TapButton = Instance.new("TextButton")
local DropButton = Instance.new("TextButton") -- Tombol Baru
local Title = Instance.new("TextLabel")

-- === SETUP UI ===
-- Menggunakan CoreGui agar UI tidak hilang saat reset (jika executor mendukung)
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "InteractControlPanel"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Position = UDim2.new(0.5, -110, 0.1, 0)
Frame.Size = UDim2.new(0, 220, 0, 160) -- Tinggi tetap 160
Frame.Active = true
Frame.Draggable = true 

Title.Parent = Frame
Title.Text = "CONTROL PANEL"
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true

-- Tombol 1: INTERACT (TAP)
TapButton.Name = "TapButton"
TapButton.Parent = Frame
TapButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Hijau
TapButton.Position = UDim2.new(0, 10, 0, 40)
TapButton.Size = UDim2.new(1, -20, 0, 50)
TapButton.Text = "FORCE INTERACT (TAP)"
TapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TapButton.TextScaled = true

-- Tombol 2: DROP ITEM (BARU)
DropButton.Name = "DropButton"
DropButton.Parent = Frame
DropButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0) -- Oranye/Coklat
DropButton.Position = UDim2.new(0, 10, 0, 100)
DropButton.Size = UDim2.new(1, -20, 0, 50)
DropButton.Text = "FORCE DROP ITEM"
DropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DropButton.TextScaled = true

-- === FUNGSI SIMULASI SENTUHAN ===
local vim = game:GetService("VirtualInputManager")

local function simulateTouch(targetInstance, buttonLabel, originalText)
    if not targetInstance then 
        warn("Target UI tidak ditemukan!")
        return 
    end

    -- Hitung posisi tengah tombol berdasarkan koordinat layar (AbsolutePosition)
    local x = targetInstance.AbsolutePosition.X + (targetInstance.AbsoluteSize.X / 2)
    local y = targetInstance.AbsolutePosition.Y + (targetInstance.AbsoluteSize.Y / 2) + 58 -- Offset Topbar Roblox
    
    local touchId = os.time()
    
    -- Kirim sinyal touch (Began -> Ended)
    vim:SendTouchEvent(touchId, 0, x, y) 
    task.wait(0.05)
    vim:SendTouchEvent(touchId, 2, x, y)
    
    -- Feedback visual pada tombol panel
    buttonLabel.Text = "SUCCESS!"
    task.wait(0.5)
    buttonLabel.Text = originalText
end

-- === LOGIKA TOMBOL ===

-- Klik untuk Interact
TapButton.MouseButton1Click:Connect(function()
    local interactPath = game:GetService("Players").LocalPlayer.PlayerGui.Touch.Right.InteractButton
    simulateTouch(interactPath, TapButton, "FORCE INTERACT (TAP)")
end)

-- Klik untuk Drop
DropButton.MouseButton1Click:Connect(function()
    -- Path sesuai permintaan: PlayerGui.Touch.Right.DropButton.Icon
    -- Kita ambil DropButton-nya untuk mendapatkan posisi koordinat klik
    local dropPath = game:GetService("Players").LocalPlayer.PlayerGui.Touch.Right.DropButton
    simulateTouch(dropPath, DropButton, "FORCE DROP ITEM")
end)
tapButton.TextScaled = true
tapButton.Text = "TAP TARGET"
tapButton.Parent = screenGui

-- Info text
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0, 320, 0, 50)
info.Position = UDim2.new(0.5, -160, 0.85, 0)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.new(1, 1, 1)
info.TextScaled = true
info.Text = "Belum ada trigger"
info.Parent = screenGui

-- Event saat TARGET benar-benar terpicu
target.Activated:Connect(function()
	target.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	target.Text = "TERPICU"
	info.Text = "Target berhasil dipicu"

	task.wait(0.4)

	target.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
	target.Text = "TARGET"
end)

-- Fungsi tap berdasarkan posisi tengah target
local function tapAtTargetPosition()
	local pos = target.AbsolutePosition
	local size = target.AbsoluteSize

	if size.X <= 0 or size.Y <= 0 then
		info.Text = "Ukuran target belum valid"
		return
	end

	local x = pos.X + size.X / 2
	local y = pos.Y + size.Y / 2

	info.Text = ("Tap ke posisi: %d, %d"):format(x, y)

	VirtualInputManager:SendTouchEvent(1, x, y, true, game)
	task.wait(0.08)
	VirtualInputManager:SendTouchEvent(1, x, y, false, game)
end

-- Saat tombol TAP ditekan, dia tidak klik target langsung
-- tapi mengirim touch ke posisi target
tapButton.MouseButton1Click:Connect(function()
	tapAtTargetPosition()
end)
