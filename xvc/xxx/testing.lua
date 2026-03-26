local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Hapus GUI lama kalau ada
local oldGui = playerGui:FindFirstChild("AndroidTouchTest")
if oldGui then
	oldGui:Destroy()
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AndroidTouchTest"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Target yang akan disentuh berdasarkan posisi
local target = Instance.new("TextButton")
target.Name = "Target"
target.Size = UDim2.new(0, 220, 0, 90)
target.Position = UDim2.new(0.5, -110, 0.35, 0)
target.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
target.TextColor3 = Color3.new(1, 1, 1)
target.TextScaled = true
target.Text = "TARGET"
target.Parent = screenGui

-- Tombol untuk memicu simulasi tap
local tapButton = Instance.new("TextButton")
tapButton.Name = "TapButton"
tapButton.Size = UDim2.new(0, 220, 0, 70)
tapButton.Position = UDim2.new(0.5, -110, 0.7, 0)
tapButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
tapButton.TextColor3 = Color3.new(1, 1, 1)
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
