local UserInputService = game:GetService("UserInputService")

local function objectAssign(target, ...)
	local targets = {...}
	for _, t in pairs(targets) do
		for k ,v in pairs(t) do
			target[k] = v;
		end
	end
	return target
end

local function createDragController(gui, dragOptions, snapOptions)
	dragOptions = objectAssign({
		dragGui = nil
	}, dragOptions)
	snapOptions = objectAssign({
		snapMargin = {},
		snapMarginThreshold = {},
		snapEnabled = false
	}, snapOptions)

	local dragGui = dragOptions.dragGui

	local snapMargin = snapOptions.snapMargin
	local snapVerticalMargin = snapMargin.Vertical or Vector2.new()
	local snapHorizontalMargin = snapMargin.Horizontal or Vector2.new()

	local snapThreshold = snapOptions.snapMarginThreshold
	local snapThresholdVertical = snapThreshold.Vertical or Vector2.new()
	local snapThresholdHorizontal = snapThreshold.Horizontal or Vector2.new()

	local snap = snapOptions.snapEnabled

	if snap == nil then
		snap = true
	end

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local view = workspace.CurrentCamera.ViewportSize
		local screen = view

		local delta = input.Position - dragStart

		gui = dragGui or gui

		local host = gui:FindFirstAncestorOfClass("ScreenGui")
		local topLeft = Vector2.new()
		if host and not host.IgnoreGuiInset then
			topLeft = game:GetService("GuiService"):GetGuiInset()
		end

		if snap then
			local scaleOffsetX = screen.X * startPos.X.Scale
			local scaleOffsetY = screen.Y * startPos.Y.Scale
			local resultingOffsetX = startPos.X.Offset + delta.X
			local resultingOffsetY = startPos.Y.Offset + delta.Y
			local absSize = gui.AbsoluteSize + Vector2.new(snapHorizontalMargin.Y, snapVerticalMargin.Y + topLeft.Y)


			-- proximity based snap would  affect the checks, but not the results
			if (resultingOffsetX + scaleOffsetX) > screen.X - absSize.X - snapThresholdHorizontal.Y then
				resultingOffsetX = screen.X - absSize.X - scaleOffsetX
			elseif (resultingOffsetX + scaleOffsetX) < snapHorizontalMargin.X + snapThresholdHorizontal.X then
				resultingOffsetX = -scaleOffsetX + (snapHorizontalMargin.X)
			end

			if (resultingOffsetY + scaleOffsetY) > screen.Y - absSize.Y - snapThresholdVertical.Y then
				resultingOffsetY = screen.Y - absSize.Y - scaleOffsetY
			elseif (resultingOffsetY + scaleOffsetY) < snapVerticalMargin.X + snapThresholdVertical.X then
				resultingOffsetY = -scaleOffsetY + (snapVerticalMargin.X)
			end

			gui.Position = UDim2.new(startPos.X.Scale, resultingOffsetX, startPos.Y.Scale, resultingOffsetY)
		else
			gui.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end

	local guiInputBegan = gui.InputBegan:Connect(
		function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = (dragGui or gui).Position

				input.Changed:Connect(
					function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end
				)
			end
		end
	)

	local guiInputChanged = gui.InputChanged:Connect(
		function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end
	)

	local uisInputChanged = UserInputService.InputChanged:Connect(
		function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end
	)

	return {
		Disconnect = function()
			guiInputBegan:Disconnect()
			guiInputChanged:Disconnect()
			uisInputChanged:Disconnect()
		end
	}
end

return {createDragController = createDragController}
