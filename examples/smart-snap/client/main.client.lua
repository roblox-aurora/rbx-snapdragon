local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Snapdragon = require(ReplicatedStorage:WaitForChild("Snapdragon"))


-- Basic Example
do
	-- create "Window"
	local screenGui = Instance.new("ScreenGui")
	local windowFrame = Instance.new("TextLabel")
	windowFrame.Size = UDim2.new(0, 200, 0, 200)
	windowFrame.Text = "Drag Me 1"
	windowFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	windowFrame.Parent = screenGui
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- attach dragger to window
	local controller = Snapdragon.createDragController(windowFrame, {
		SnapEnabled = true,
		--ControllerType = "UIDragDetector",
		-- DragAxis = "X",
	});

	controller:Connect()

	controller.DragBegan:Connect(function(event)
		print("Drag began", event.InputPosition, event.GuiPosition, event.AbsolutePosition)
	end)

	controller.DragEnded:Connect(function(event) 
		print("Drag ended", event.DraggedGui, event.GuiPosition, event.InputPosition, event.ReachedExtents)
	end)
end

-- Basic Example w/ AnchorPoint
do
	-- create "Window"
	local screenGui = Instance.new("ScreenGui")
	local windowFrame = Instance.new("TextLabel")
	windowFrame.Size = UDim2.new(0, 200, 0, 200)
	windowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	windowFrame.Text = "Drag Me"
	windowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	windowFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	windowFrame.Parent = screenGui
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- attach dragger to window
	local controller = Snapdragon.createDragController(windowFrame, {
		SnapEnabled = true,
		--ControllerType = "UIDragDetector"
	});
	controller.DragEnded:Connect(function(_, ext)
		print("ext", tick(),  ext.X, ext.Y)
	end)
	controller:Connect()
end

-- With titlebar
do
	-- create "Window"
	local screenGui = Instance.new("ScreenGui")

	local windowFrame = Instance.new("Frame")
	windowFrame.Size = UDim2.new(0, 200, 0, 200)
	windowFrame.Position = UDim2.new(0, 200, 0, 0)

	local windowTitle = Instance.new("TextButton")
	windowTitle.Text = "Drag Me"
	windowTitle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	windowTitle.Size = UDim2.new(1, 0, 0, 25)
	windowTitle.Parent = windowFrame

	windowFrame.Parent = screenGui

	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- attach dragger to a titlebar, but treat it like it's dragging the window
	local controller = Snapdragon.createDragController(windowTitle, {
		DragGui = windowFrame, -- Tells this controller that it's dragging the window, not the titlebar
		SnapEnabled = true,
		--ControllerType = "UIDragDetector",
		DragPositionMode = "Offset",
		RequiredDragDistance = 50
	});
	controller:Connect()
end