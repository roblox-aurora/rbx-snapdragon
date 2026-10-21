--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Snapdragon = require(ReplicatedStorage:WaitForChild("Snapdragon"))

-- Basic Example
do
	-- create "Window"
	local screenGui = Instance.new("ScreenGui")
	
	local windowFrame = Instance.new("TextLabel")
	windowFrame.Size = UDim2.new(0, 200, 0, 200)
	windowFrame.Text = "Drag Me On a Drop"
	windowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	windowFrame.Parent = screenGui


	local windowFrame2 = Instance.new("TextLabel")
	windowFrame2.Size = UDim2.new(0, 200, 0, 200)
	windowFrame2.Position = UDim2.new(0, 500, 0, 500)
	windowFrame2.Text = "Drag Me On a Drop"
	windowFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	windowFrame2.Parent = screenGui

	screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")


	local dnd = Snapdragon.createDragAndDropContext()
	
	local controller = dnd:RegisterDragSource(Snapdragon.createRef(windowFrame), {
		DropGroup = "test",
		Data = "I'm some data!"
	})
	controller:Connect()

	dnd:RegisterDropTarget(Snapdragon.createRef(windowFrame2), {
		DropGroups = { "test" },
		DroppedOnTarget = function(data)
			print("dropped", data)
		end,
		CanDropOnTarget = function(data)
			return typeof(data) == "string"
		end
	})
end
