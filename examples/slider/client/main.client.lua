local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Snapdragon = require(ReplicatedStorage:WaitForChild("Snapdragon"))

-- "Slider"
do
	-- create "Window"
	local screenGui = Instance.new("ScreenGui")
	local windowFrame = Instance.new("Frame")
	windowFrame.Size = UDim2.new(0, 200, 0, 50)
	windowFrame.Position = UDim2.new(0.5, -100, 0.5, -25)

	windowFrame.Parent = screenGui

	local sliderFrame = Instance.new("TextLabel")
	sliderFrame.Text = "Drag"
	sliderFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	sliderFrame.Size = UDim2.new(0, 20, 0, 50)
	sliderFrame.Parent = windowFrame

	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Attach to slider gui
	local controller = Snapdragon.createDragController(sliderFrame, {
		SnapEnabled = true, -- keep constrained within parent
		DragAxis = "X", -- Only draggable on X axis
		DragRelativeTo = "Parent", -- constrain to parent frame
	});
	controller:Connect()
end

-- "Snappy Slider"
do
	-- create "Window"
	local screenGui = Instance.new("ScreenGui")
	local windowFrame = Instance.new("Frame")
	windowFrame.Size = UDim2.new(0, 200, 0, 50)
	windowFrame.Position = UDim2.new(0.5, -100, 0.5, 25)

	windowFrame.Parent = screenGui

	local sliderFrame = Instance.new("TextLabel")
	sliderFrame.Text = "SnappyDrag"
	sliderFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	sliderFrame.Size = UDim2.new(0, 20, 0, 50)
	sliderFrame.Parent = windowFrame

	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Attach to slider gui
	local controller = Snapdragon.createDragController(sliderFrame, {
		SnapEnabled = true, -- keep constrained within parent
		DragAxis = "X", -- Only draggable on X axis
		DragRelativeTo = "Parent", -- constrain to parent frame
		DragGridSize = 200 / 10, -- Will move in a grid of 200/10 (20 pixels)
	});
	controller:Connect()
end