local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Snapdragon = require(ReplicatedStorage:WaitForChild("Snapdragon"))


local screenGui = Instance.new("ScreenGui")
local hostFrame = Instance.new("Frame")
hostFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
hostFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
hostFrame.Parent = screenGui
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Basic Example
do
	-- create "Child"
	local windowFrame = Instance.new("TextLabel")
	windowFrame.Size = UDim2.new(0, 200, 0, 200)
	windowFrame.Text = "I will only drag inside parent frame"
	windowFrame.TextWrapped = true
	windowFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	windowFrame.Parent = hostFrame
	
	-- attach dragger to window
	local controller = Snapdragon.createDragController(windowFrame, {
		SnapEnabled = true,
		DragRelativeTo = "Parent"
	});
	controller:Connect()
end



