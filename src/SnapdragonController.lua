local UserInputService = game:GetService("UserInputService")

local objectAssign = require(script.Parent.objectAssign)
local Signal = require(script.Parent.Signal)
local SnapdragonRef = require(script.Parent.SnapdragonRef)
local t = require(script.Parent.t)
local Maid = require(script.Parent.Maid)

local MarginTypeCheck = t.interface({
	Vertical = t.optional(t.Vector2),
	Horizontal = t.optional(t.Vector2),
})

local DragAxisEnumCheck = t.literal("XY", "X", "Y")
local DragRelativeToEnumCheck = t.literal("LayerCollector", "Parent")

local OptionsInterfaceCheck = t.interface({
	DragGui = t.union(t.instanceIsA("GuiObject"), SnapdragonRef.is),
	DragThreshold = t.number,
	SnapMargin = MarginTypeCheck,
	SnapMarginThreshold = MarginTypeCheck,
	DragAxis = DragAxisEnumCheck,
	DragRelativeTo = DragRelativeToEnumCheck,
	SnapEnabled = t.boolean,
})

local SnapdragonController = {}
SnapdragonController.__index = SnapdragonController

local controllers = setmetatable({}, {__mode = "k"})

function SnapdragonController.new(gui, options)
	options = objectAssign({
		DragGui = gui,
		DragThreshold = 0,
		SnapMargin = {},
		SnapMarginThreshold = {},
		SnapEnabled = true,
		DragAxis = "XY",
		DragRelativeTo = "LayerCollector",
	}, options)

	assert(OptionsInterfaceCheck(options))

	local self = setmetatable({}, SnapdragonController)
	-- Basic immutable values
	local dragGui = options.DragGui
	self.dragGui = dragGui
	self.gui = gui
	self.originPosition = dragGui.Position
	self.snapEnabled = options.SnapEnabled
	self.dragThreshold = options.DragThreshold
	self.dragAxis = options.DragAxis
	self.dragRelativeTo = options.DragRelativeTo

	-- Events
	local DragEnded = Signal.new()
	local DragBegan = Signal.new()
	self.DragEnded = DragEnded
	self.DragBegan = DragBegan

	-- Advanced stuff
	self.maid = Maid.new()
	self:SetSnapEnabled(options.SnapEnabled)
	self:SetSnapMargin(options.SnapMargin)
	self:SetSnapThreshold(options.SnapMarginThreshold)

	return self
end

function SnapdragonController:SetSnapEnabled(snapEnabled)
	assert(t.boolean(snapEnabled))
	self.snapEnabled = snapEnabled
end

function SnapdragonController:SetSnapMargin(snapMargin)
	assert(MarginTypeCheck(snapMargin))
	local snapVerticalMargin = snapMargin.Vertical or Vector2.new()
	local snapHorizontalMargin = snapMargin.Horizontal or Vector2.new()
	self.snapVerticalMargin = snapVerticalMargin
	self.snapHorizontalMargin = snapHorizontalMargin
end

function SnapdragonController:SetSnapThreshold(snapThreshold)
	assert(MarginTypeCheck(snapThreshold))
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
	local dragAxis = self.dragAxis
	local dragRelativeTo = self.dragRelativeTo

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local snapHorizontalMargin = self.snapHorizontalMargin
		local snapVerticalMargin = self.snapVerticalMargin
		local snapThresholdVertical = self.snapThresholdVertical
		local snapThresholdHorizontal = self.snapThresholdHorizontal

		local screenSize = workspace.CurrentCamera.ViewportSize
		local inset = game:GetService("GuiService"):GetGuiInset()
		

		local delta = input.Position - dragStart

		gui = dragGui or gui

		local host = gui:FindFirstAncestorOfClass("ScreenGui") or gui:FindFirstAncestorOfClass("PluginGui")
		local topLeft = Vector2.new()
		if host and dragRelativeTo == "LayerCollector" then
			-- if host:IsA("ScreenGui") and not host.IgnoreGuiInset then
			-- 	topLeft = inset
			-- end
			screenSize = host.AbsoluteSize
		elseif dragRelativeTo == "Parent" then
			assert(gui.Parent:IsA("GuiObject"), "DragRelativeTo is set to Parent, but the parent is not a GuiObject!")

			screenSize = gui.Parent.AbsoluteSize
			topLeft = gui.Parent.AbsolutePosition
			if host:IsA("ScreenGui") and host.IgnoreGuiInset then
				topLeft = topLeft + inset
			end
		end

		if snap then
			local scaleOffsetX = screenSize.X * startPos.X.Scale
			local scaleOffsetY = screenSize.Y * startPos.Y.Scale
			local resultingOffsetX = startPos.X.Offset + delta.X
			local resultingOffsetY = startPos.Y.Offset + delta.Y
			local absSize = gui.AbsoluteSize + Vector2.new(snapHorizontalMargin.Y, snapVerticalMargin.Y + topLeft.Y)


			if dragAxis == "XY" or dragAxis == "X" then
				if (resultingOffsetX + scaleOffsetX) > screenSize.X - absSize.X - snapThresholdHorizontal.Y then
					resultingOffsetX = screenSize.X - absSize.X - scaleOffsetX
				elseif (resultingOffsetX + scaleOffsetX) < snapHorizontalMargin.X + snapThresholdHorizontal.X then
					resultingOffsetX = -scaleOffsetX + (snapHorizontalMargin.X)
				end
			end

			if dragAxis == "XY" or dragAxis == "Y" then
				if (resultingOffsetY + scaleOffsetY) > screenSize.Y - absSize.Y - snapThresholdVertical.Y then
					resultingOffsetY = screenSize.Y - absSize.Y - scaleOffsetY
				elseif (resultingOffsetY + scaleOffsetY) < snapVerticalMargin.X + snapThresholdVertical.X then
					resultingOffsetY = -scaleOffsetY + (snapVerticalMargin.X)
				end
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