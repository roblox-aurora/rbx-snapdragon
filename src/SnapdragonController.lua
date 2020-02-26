local UserInputService = game:GetService("UserInputService")

local objectAssign = require(script.Parent.objectAssign)
local Signal = require(script.Parent.Signal)
local SnapdragonRef = require(script.Parent.SnapdragonRef)
local t = require(script.Parent.t)
local Maid = require(script.Parent.Maid)

local isMarginProp = t.interface({
	Vertical = t.optional(t.Vector2),
	Horizontal = t.optional(t.Vector2),
})

local SnapdragonController = {}
SnapdragonController.__index = SnapdragonController

local controllers = setmetatable({}, {__mode = "k"})

function SnapdragonController.new(gui, dragOptions, snapOptions)
	dragOptions = objectAssign({
		DragGui = gui
	}, dragOptions)
	snapOptions = objectAssign({
		SnapMargin = {},
		SnapMarginThreshold = {},
		SnapEnabled = true
	}, snapOptions)

	local self = setmetatable({}, SnapdragonController)
	-- Basic immutable values
	local dragGui = dragOptions.DragGui
	self.dragGui = dragGui
	self.gui = gui
	self.originPosition = dragGui.Position
	self.snapEnabled = snapOptions.SnapEnabled

	-- Events
	local DragEnded = Signal.new()
	local DragBegan = Signal.new()
	self.DragEnded = DragEnded
	self.DragBegan = DragBegan

	-- Advanced stuff
	self.maid = Maid.new()
	self:SetSnapEnabled(snapOptions.SnapEnabled)
	self:SetSnapMargin(snapOptions.SnapMargin)
	self:SetSnapThreshold(snapOptions.SnapMarginThreshold)

	return self
end

function SnapdragonController:SetSnapEnabled(snapEnabled)
	assert(t.boolean(snapEnabled))
	self.snapEnabled = snapEnabled
end

function SnapdragonController:SetSnapMargin(snapMargin)
	assert(isMarginProp(snapMargin))
	local snapVerticalMargin = snapMargin.Vertical or Vector2.new()
	local snapHorizontalMargin = snapMargin.Horizontal or Vector2.new()
	self.snapVerticalMargin = snapVerticalMargin
	self.snapHorizontalMargin = snapHorizontalMargin
end

function SnapdragonController:SetSnapThreshold(snapThreshold)
	assert(isMarginProp(snapThreshold))
	local snapThresholdVertical = snapThreshold.Vertical or Vector2.new()
	local snapThresholdHorizontal = snapThreshold.Horizontal or Vector2.new()
	self.snapThresholdVertical = snapThresholdVertical
	self.snapThresholdHorizontal = snapThresholdHorizontal
end

function SnapdragonController:GetDragGui()
	local gui = self.dragGui
	if SnapdragonRef.is(gui) then
		return gui:Get(), gui
	else
		return gui, gui
	end
end

function SnapdragonController:GetGui()
	local gui = self.gui
	if SnapdragonRef.is(gui) then
		return gui:Get()
	else
		return gui
	end
end

function SnapdragonController:ResetPosition()
	self.dragGui.Position = self.originPosition
end

function SnapdragonController:__bindControllerBehaviour()
	local maid = self.maid

	local gui = self:GetGui()
	local dragGui = self:GetDragGui()
	local snap = self.snapEnabled
	local DragEnded = self.DragEnded
	local DragBegan = self.DragBegan

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local snapHorizontalMargin = self.snapHorizontalMargin
		local snapVerticalMargin = self.snapVerticalMargin
		local snapThresholdVertical = self.snapThresholdVertical
		local snapThresholdHorizontal = self.snapThresholdHorizontal

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

	maid.guiInputBegan = gui.InputBegan:Connect(
		function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = (dragGui or gui).Position
				DragBegan:Fire(dragStart)

				input.Changed:Connect(
					function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
							DragEnded:Fire(input.Position)
						end
					end
				)
			end
		end
	)

	maid.guiInputChanged = gui.InputChanged:Connect(
		function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end
	)

	maid.uisInputChanged = UserInputService.InputChanged:Connect(
		function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end
	)
end

function SnapdragonController:Connect()
	if self.locked then
		error("[SnapdragonController] Cannot connect locked controller!", 2)
	end

	local _, ref = self:GetDragGui()

	if not controllers[ref] or controllers[ref] == self then
		controllers[ref] = self
		self:__bindControllerBehaviour()
	else
		error("[SnapdragonController] This object is already bound to a controller")
	end
	return self
end

function SnapdragonController:Disconnect()
	if self.locked then
		error("[SnapdragonController] Cannot disconnect locked controller!", 2)
	end

	local _, ref = self:GetDragGui()

	local controller = controllers[ref]
	if controller then
		self.maid:DoCleaning()
		controllers[ref] = nil
	end
end

function SnapdragonController:Destroy()
	self:Disconnect()
	self.DragEnded:Destroy()
	self.DragBegan:Destroy()
	self.DragEnded = nil
	self.DragBegan = nil
	self.locked = true
end

return SnapdragonController