--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Snapdragon = require(ReplicatedStorage:WaitForChild("Snapdragon"))

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local SnapdragonRef = require(ReplicatedStorage.Snapdragon.SnapdragonRef)


-- -- Basic Example
-- do
-- 	-- create "Window"
-- 	local screenGui = Instance.new("ScreenGui")
	
-- 	local windowFrame = Instance.new("TextLabel")
-- 	windowFrame.Size = UDim2.new(0, 200, 0, 200)
-- 	windowFrame.Text = "Drag Me On a Drop"
-- 	windowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
-- 	windowFrame.Parent = screenGui


-- 	local windowFrame2 = Instance.new("TextLabel")
-- 	windowFrame2.Size = UDim2.new(0, 200, 0, 200)
-- 	windowFrame2.Position = UDim2.new(0, 500, 0, 500)
-- 	windowFrame2.Text = "Drag Me On a Drop"
-- 	windowFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
-- 	windowFrame2.Parent = screenGui

-- 	screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")


-- 	local dnd = Snapdragon.createDragAndDropContext()
	
-- 	local windowFrameRef = Snapdragon.createRef(windowFrame)
-- 	local controller = dnd:RegisterDragSource(windowFrameRef, {
-- 		DropGroup = "test",
-- 		Data = "I'm some data!"
-- 	})
-- 	controller:Connect()

-- 	dnd:UpdateDragSourceData(windowFrameRef, "I'm updated data now :-)")

-- 	dnd:RegisterDropTarget(Snapdragon.createRef(windowFrame2), {
-- 		DropGroups = { "test" },
-- 		DroppedOnTarget = function(data, gui)
-- 			print("dropped", data, gui)
-- 		end,
-- 		CanDropOnTarget = function(data)
-- 			return typeof(data) == "string"
-- 		end,
-- 		HoveringOverTarget = function(data, gui)
-- 			print("recieved hover data", data, gui)
-- 		end,
-- 		StoppedHoveringOverTarget = function(data, gui)
-- 			print("stopped hovering", data, gui)
-- 		end
-- 	})
-- end

--- React example
do
	local dnd = Snapdragon.createDragAndDropContext()

	local e = React.createElement

	local function DragFrame(props)
		local ref = React.useRef(nil)

		React.useEffect(function() 
			if not ref.current then return end
			local snapdragonRef = Snapdragon.createRef(ref.current)
			local drag = dnd:RegisterDragSource(snapdragonRef, {
				DropGroup = props.DropGroup or "test",
				Data = "hello, world!"
			})

			drag:Connect()

			return function()
				dnd:UnregisterDragSource(snapdragonRef)
			end
		end, {ref})

		return e("Frame", {
			ref = ref,
			Size = UDim2.new(0, 100, 0, 100),
			Position = props.Position
		}, props.children)
	end

	local function DropFrame(props)
		local ref = React.useRef(nil)
		local isHovering, setHovering = React.useState(false)
		local dropped, setDropped = React.useState(false)

		React.useEffect(function() 
			if not ref.current then return end
			local snapdragonRef = Snapdragon.createRef(ref.current)
			dnd:RegisterDropTarget(snapdragonRef, {
				DropGroups = { "test" },
				DroppedOnTarget = function(data)
					print("dropped on me", data)
					setHovering(false)
					setDropped(true)
				end,
				HoveringOverTarget = function(data)
					print("hovering over", data)

					setDropped(false)
					setHovering(true)
				end,
				StoppedHoveringOverTarget = function(data)
					print("stopped hovering over", data)

					setDropped(false)
					setHovering(false)
				end
			})

			return function()
				dnd:UnregisterDropTarget(snapdragonRef)
			end
		end, {ref})

		return e("Frame", {
			ref = ref,
			Size = UDim2.new(0, 100, 0, 100),
			Position = props.Position or UDim2.new(0, 200, 0, 200)
		}, props.children, React.createElement("UIStroke", {
			Thickness = if isHovering then 2 else 1,
			Color = if dropped then Color3.fromRGB(0, 255, 0) else if isHovering then Color3.fromRGB(255, 255, 0) else Color3.fromRGB(0, 0, 0)
		}))
	end


	local testGui = Instance.new("ScreenGui")
	testGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	
	local root = ReactRoblox.createRoot(testGui)

	local function Test()
		return React.createElement(
			React.Fragment, {}, 
			React.createElement(DragFrame, {}, 
				React.createElement("TextLabel", {
					Text = "Drag me!",
					TextSize = 15,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1
				})
			),
			React.createElement(DropFrame, {},
				React.createElement("TextLabel", {
					Text = "Drop here!",
					TextSize = 15,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1
				})
			),
			React.createElement(DragFrame, { DropGroup = "wrong", Position = UDim2.new(0, 300, 0, 300), }, 
				React.createElement("TextLabel", {
					Text = "No drop here",
					TextSize = 15,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
				})
			)
		)
	end

	root:render(React.createElement(Test))
end