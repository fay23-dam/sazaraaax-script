local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local target = playerGui:WaitForChild("Interactable")
	:WaitForChild("Main")
	:WaitForChild("Frame")
	:WaitForChild("Touch")

local function tapGui(guiObject)
	if not guiObject or not guiObject:IsA("GuiObject") then
		warn("Target bukan GuiObject")
		return
	end

	local pos = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize

	if size.X <= 0 or size.Y <= 0 then
		warn("Ukuran GUI belum valid")
		return
	end

	local x = pos.X + size.X / 2
	local y = pos.Y + size.Y / 2

	print("Tap di posisi:", x, y, guiObject:GetFullName(), guiObject.ClassName)

	VirtualInputManager:SendTouchEvent(1, x, y, true, game)
	task.wait(0.05)
	VirtualInputManager:SendTouchEvent(1, x, y, false, game)
end

task.wait(2) -- kasih waktu UI muncul
tapGui(target)
