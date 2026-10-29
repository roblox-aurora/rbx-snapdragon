--!strict
local UserInputService = game:GetService("UserInputService")

local objectAssign = require(script.Parent.objectAssign)
local Signal = require(script.Parent.Signal)
local SnapdragonRef = require(script.Parent.SnapdragonRef)
local t = require(script.Parent.t)
local Maid = require(script.Parent.Maid)
local Types = require("./Types")

local SnapdragonController = {}
SnapdragonController.__index = SnapdragonController

type DragEnd = () -> ()
type SnapdragonControllerProps = {
	dragGui: Types.SnapdragonRef,
	gui: Types.SnapdragonRef,
	debug: boolean,
	originPosition: UDim2,
	dragEndedResetsPosition: boolean,
	snapEnabled: boolean,
	snapAxis: Types.SnapdragonAxis?,
	dragAxis: Types.SnapdragonAxis?,
	dragThreshold: number?,
	dragRelativeTo: Types.SnapdragonRelativeTo,
	canDrag: Types.DragPredicate?,
	dragGridSize: number,
	dragPositionMode: Types.DragPositionMode?,
	requireDragDistance: number,

	_useAbsoluteCoordinates: boolean,

	DragEnded: Signal.Signal1<Types.DragEndedEvent>,
	DragBegan: Signal.Signal1<Types.DragBeganEvent>,
	DragChanged: Signal.Signal1<Types.DragChangedEvent>,
	
	OnDragEnd: Types.DragEndCallback?,

	maid: Maid.Maid,

	snapVerticalMargin: Vector2,
	snapHorizontalMargin: Vector2,

	snapThresholdVertical: Vector2,
	snapThresholdHorizontal: Vector2,

	dragScaleModifier: number,

	locked: boolean,
}

type SnapdragonInternal = setmetatable<SnapdragonControllerProps, typeof(SnapdragonController)>
export type SnapdragonController = Types.SnapdragonController

local controllers = setmetatable({}, { __mode = "k" }) :: { [GuiObject]: SnapdragonInternal }

local function findAllScaleModifiers(instance: GuiObject | LayerCollector, scales: {number}?): { read number }
	scales = scales or {}

	local scale = instance:FindFirstChildWhichIsA("UIScale")
	if scale then 
		table.insert(scales, 1, scale.Scale) -- we go LIFO with scaling since it's based on heirarchy
	end

	if instance.Parent ~= nil and (instance.Parent:IsA("GuiObject") or instance.Parent:IsA("LayerCollector")) then
		return findAllScaleModifiers(instance.Parent, scales)
	end

	return scales
end

function SnapdragonController.new(gui: GuiObject | Types.SnapdragonRef, options: Types.SnapdragonOptions): Types.SnapdragonController
	local dragGui = options.DragGui
	local guiRef = SnapdragonRef.toRef(gui)
	local dragGuiRef = if dragGui then SnapdragonRef.toRef(dragGui) else guiRef

	local pluginAncestor = dragGuiRef.current:FindFirstAncestorWhichIsA("PluginGui")
	local scale = 1

	options = objectAssign<<Types.SnapdragonOptions>>({
		DragGui = gui,
		DragThreshold = 0,
		DragGridSize = 0,
		SnapMargin = {},
		SnapMarginThreshold = {},
		SnapEnabled = true,
		DragEndedResetsPosition = false,
		SnapAxis = "XY",
		DragAxis = "XY",
		Debugging = false,
		DragRelativeTo = if pluginAncestor then "Parent" else "LayerCollector",
		DragPositionMode = "Scale",
	}, options) :: Types.SnapdragonOptions

	local self = setmetatable({}, SnapdragonController) :: SnapdragonInternal
	-- Basic immutable values

	self.gui = guiRef
	self.dragGui = dragGuiRef

	assert(self:GetGui():IsA("GuiObject"), "Gui should be a GuiObject")
	assert(self:GetDragGui():IsA("GuiObject"), "DragGui should be a GuiObject")

	self.debug = options.Debugging or false
	self.originPosition = self.dragGui.current.Position
	self.canDrag = options.CanDrag
	self.dragEndedResetsPosition = options.DragEndedResetsPosition or false
	self.dragScaleModifier = scale

	self.snapEnabled = options.SnapEnabled or false
	self.snapAxis = options.SnapAxis

	self.dragAxis = options.DragAxis
	self.dragThreshold = options.DragThreshold
	self.dragRelativeTo = options.DragRelativeTo
	self.dragGridSize = options.DragGridSize or 0
	self.dragPositionMode = options.DragPositionMode
	self.requireDragDistance = options.RequiredDragDistance or 0

	-- Internal stuff
	self._useAbsoluteCoordinates = false

	-- Events
	local DragEnded = Signal.new()
	local DragChanged = Signal.new()
	local DragBegan = Signal.new()
	self.DragEnded = DragEnded :: Signal.Signal1<Types.DragEndedEvent>
	self.DragBegan = DragBegan :: Signal.Signal1<Types.DragBeganEvent>
	self.DragChanged = DragChanged :: Signal.Signal1<Types.DragChangedEvent>

	-- Advanced stuff
	self.maid = Maid.new()
	self:SetSnapEnabled(options.SnapEnabled or false)
	self:SetSnapMargin(options.SnapMargin or {})
	self:SetSnapThreshold(options.SnapMarginThreshold or {})

	return self :: SnapdragonController
end

function SnapdragonController.SetSnapEnabled(self: SnapdragonInternal, snapEnabled: boolean)
	assert(t.boolean(snapEnabled))
	self.snapEnabled = snapEnabled
end

function SnapdragonController.SetSnapMargin(self: SnapdragonInternal, snapMargin: Types.SnapdragonMargins)
	-- assert(MarginTypeCheck(snapMargin))
	local snapVerticalMargin = snapMargin.Vertical or Vector2.new()
	local snapHorizontalMargin = snapMargin.Horizontal or Vector2.new()
	self.snapVerticalMargin = snapVerticalMargin
	self.snapHorizontalMargin = snapHorizontalMargin
end

function SnapdragonController.SetSnapThreshold(self: SnapdragonInternal, snapThreshold: Types.SnapdragonMargins)
	local snapThresholdVertical = snapThreshold.Vertical or Vector2.new()
	local snapThresholdHorizontal = snapThreshold.Horizontal or Vector2.new()
	self.snapThresholdVertical = snapThresholdVertical
	self.snapThresholdHorizontal = snapThresholdHorizontal
end

function SnapdragonController.GetDragGui(self: SnapdragonInternal): GuiObject
	local gui = self.dragGui
	return gui.current
end

function SnapdragonController.GetGui(self: SnapdragonInternal): GuiObject
	local gui = self.gui
	return gui.current
end

function SnapdragonController.ResetPosition(self: SnapdragonInternal): ()
	self.dragGui.current.Position = self.originPosition
end

function SnapdragonController.__bindControllerBehaviour(self: SnapdragonInternal)
	local maid = self.maid
	local debug = self.debug

	local gui = self:GetGui() :: GuiObject
	local dragGui = self:GetDragGui() :: (GuiObject)
	local snap = self.snapEnabled
	local DragEnded = self.DragEnded
	local DragBegan = self.DragBegan
	local DragChanged = self.DragChanged
	local snapAxis = self.snapAxis
	local dragAxis = self.dragAxis
	local dragRelativeTo = self.dragRelativeTo
	local dragGridSize = self.dragGridSize
	local dragPositionMode = self.dragPositionMode

	local useAbsoluteCoordinates = self._useAbsoluteCoordinates

	local reachedExtents

	local dragging: boolean
	local dragInput: InputObject
	local dragStart: Vector3
	local startPos: UDim2
	local guiStartPos: UDim2
	local startAbsPos: Vector2
	local scaleModifier = 1

	local function updateDragPosition(position: Vector3)
		local snapHorizontalMargin = self.snapHorizontalMargin
		local snapVerticalMargin = self.snapVerticalMargin
		local snapThresholdVertical = self.snapThresholdVertical
		local snapThresholdHorizontal = self.snapThresholdHorizontal

		local screenSize = workspace.CurrentCamera.ViewportSize
		local delta = position - dragStart

		if dragAxis == "X" then
			delta = Vector3.new(delta.X, 0, 0)
		elseif dragAxis == "Y" then
			delta = Vector3.new(0, delta.Y, 0)
		end
		
		if self.requireDragDistance > 0 and delta.Magnitude < self.requireDragDistance then
			return
		end

		delta = delta / scaleModifier

		gui = dragGui or gui
		reachedExtents = {
			X = "Float",
			Y = "Float",
		}

		local host = gui:FindFirstAncestorOfClass("ScreenGui") or gui:FindFirstAncestorOfClass("PluginGui")
		local topLeft = Vector2.new()
		if host and dragRelativeTo == "LayerCollector" then
			screenSize = host.AbsoluteSize
		elseif dragRelativeTo == "Parent" then
			assert(gui.Parent)
			assert(gui.Parent:IsA("GuiObject"), "DragRelativeTo is set to Parent, but the parent is not a GuiObject!")
			screenSize = gui.Parent.AbsoluteSize
		end

		if snap then
			local scaleOffsetX = screenSize.X * startPos.X.Scale
			local scaleOffsetY = screenSize.Y * startPos.Y.Scale
			local resultingOffsetX = startPos.X.Offset + delta.X
			local resultingOffsetY = startPos.Y.Offset + delta.Y
			local absSize = gui.AbsoluteSize + Vector2.new(snapHorizontalMargin.Y, snapVerticalMargin.Y + topLeft.Y)

			local anchorOffset =
				Vector2.new(gui.AbsoluteSize.X * gui.AnchorPoint.X, gui.AbsoluteSize.Y * gui.AnchorPoint.Y)

			if snapAxis == "XY" or snapAxis == "X" then
				local computedMinX = snapHorizontalMargin.X + anchorOffset.X
				local computedMaxX = screenSize.X - absSize.X + anchorOffset.X

				if (resultingOffsetX + scaleOffsetX) > computedMaxX - snapThresholdHorizontal.Y then
					resultingOffsetX = computedMaxX - scaleOffsetX
					reachedExtents.X = "Max"
				elseif (resultingOffsetX + scaleOffsetX) < computedMinX + snapThresholdHorizontal.X then
					resultingOffsetX = -scaleOffsetX + computedMinX
					reachedExtents.X = "Min"
				end
			end

			if snapAxis == "XY" or snapAxis == "Y" then
				local computedMinY = snapVerticalMargin.X + anchorOffset.Y
				local computedMaxY = screenSize.Y - absSize.Y + anchorOffset.Y

				if (resultingOffsetY + scaleOffsetY) > computedMaxY - snapThresholdVertical.Y then
					resultingOffsetY = computedMaxY - scaleOffsetY
					reachedExtents.Y = "Max"
				elseif (resultingOffsetY + scaleOffsetY) < computedMinY + snapThresholdVertical.X then
					resultingOffsetY = -scaleOffsetY + computedMinY
					reachedExtents.Y = "Min"
				end
			end

			if dragGridSize > 0 then
				resultingOffsetX = math.floor(resultingOffsetX / dragGridSize) * dragGridSize
				resultingOffsetY = math.floor(resultingOffsetY / dragGridSize) * dragGridSize
			end

			if dragPositionMode == "Offset" then
				local newPosition = UDim2.new(startPos.X.Scale, resultingOffsetX, startPos.Y.Scale, resultingOffsetY)

				gui.Position = newPosition

				DragChanged:Fire({
					GuiPosition = newPosition,
				})
			elseif dragPositionMode == "AbsoluteOffset" then
				local newPosition = UDim2.new(
					0,
					resultingOffsetX,
					0,
					resultingOffsetY
				)

				gui.Position = newPosition

				DragChanged:Fire({
					SnapAxis = snapAxis,
					GuiPosition = newPosition,
					DragPositionMode = dragPositionMode,
				})
			else
				local newPosition = UDim2.new(
					startPos.X.Scale + (resultingOffsetX / screenSize.X),
					0,
					startPos.Y.Scale + (resultingOffsetY / screenSize.Y),
					0
				)

				gui.Position = newPosition

				DragChanged:Fire({
					SnapAxis = snapAxis,
					GuiPosition = newPosition,
					DragPositionMode = dragPositionMode,
				})
			end
		else
			if dragGridSize > 0 then
				delta = Vector3.new(
					math.floor(delta.X / dragGridSize) * dragGridSize,
					math.floor(delta.Y / dragGridSize) * dragGridSize,
					0
				)
			end

			if dragPositionMode == "AbsoluteOffset" then
				local newPosition =
					UDim2.new(0, startAbsPos.X + (delta.X), 0, startAbsPos.Y + delta.Y)
				gui.Position = newPosition


				DragChanged:Fire({
					GuiPosition = newPosition,
				})	
			else
				local newPosition =
					UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				gui.Position = newPosition


				DragChanged:Fire({
					GuiPosition = newPosition,
				})
			end
		end
	end

	local function startDragging(startPosition: Vector3)
		if dragging then return end

		dragging = true
		dragStart = startPosition

		scaleModifier = 1 -- reset modifier to 1
		-- Apply any scaling required to our drag behaviour
		local scales = findAllScaleModifiers(gui)
		for _, scale in scales do
			scaleModifier *= scale
		end
		print("scale is", scaleModifier)

		local draggingGui = (dragGui or gui)
		startPos = useAbsoluteCoordinates
				and UDim2.new(0, draggingGui.AbsolutePosition.X, 0, draggingGui.AbsolutePosition.Y)
			or draggingGui.Position

		startAbsPos = draggingGui.AbsolutePosition
		guiStartPos = draggingGui.Position



		if dragPositionMode == "AbsoluteOffset" then
			local newPosition =
				UDim2.new(0, startAbsPos.X, 0, startAbsPos.Y)
			gui.Position = newPosition
		end

		DragBegan:Fire({
			AbsolutePosition = (dragGui or gui).AbsolutePosition,
			InputPosition = dragStart,
			GuiPosition = startPos,
		})
	end

	local function endDragging(endPosition: Vector3)
		if not dragging then return end

		dragging = false

		local draggingGui = (dragGui or gui)
		local endPos = draggingGui.Position

		DragEnded:Fire({
			InputPosition = endPosition,
			GuiPosition = endPos,
			ReachedExtents = reachedExtents,
			DraggedGui = dragGui or gui,
		})
	end

	maid.guiInputBegan = gui.InputBegan:Connect(function(input)
		local canDrag = true
		if type(self.canDrag) == "function" then
			canDrag = self.canDrag()
		end

		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and canDrag
		then
			startDragging(input.Position)

			if debug then
				print("[snapdragon]", "Drag began", input.Position)
			end

			local pluginGui = gui:FindFirstAncestorWhichIsA("PluginGui") :: PluginGui
            if pluginGui and self.dragRelativeTo == "Parent" then
                -- Fixing dragging in a PluginGui context
                while dragging do
                    local relativePos = pluginGui:GetRelativeMousePosition()
                    updateDragPosition(Vector3.new(relativePos.X, relativePos.Y, 0))
                    task.wait()
                end
            end
		end
	end)

	maid.guiInputEnded = gui.InputEnded:Connect(function(input)
		if
			dragging
			and input.UserInputState == Enum.UserInputState.End
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local draggingGui = (dragGui or gui)
			endDragging(input.Position)

			if typeof(self.OnDragEnd) == "function" then
				self.OnDragEnd()
			end

			if debug then
				print("[snapdragon]", "Drag ended", input.Position)
			end

			-- Enable the ability to "reset" the position automatically.
			-- This will be used for stuff like roact-dnd
			local dragEndedResetsPosition = self.dragEndedResetsPosition
			if dragEndedResetsPosition then
				draggingGui.Position = guiStartPos
			end
		end
	end)

	maid.guiInputChanged = gui.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)

	maid.uisInputChanged = UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			updateDragPosition(input.Position)
		end
	end)
end

function SnapdragonController.Connect(self: SnapdragonInternal): SnapdragonInternal
	if self.locked then
		error("[SnapdragonController] Cannot connect locked controller!", 2)
	end

	local ref = self:GetDragGui()

	if not controllers[ref] or controllers[ref] == self then
		controllers[ref] = self
		self:__bindControllerBehaviour()
	else
		error("[SnapdragonController] This object is already bound to a controller")
	end
	return self
end

function SnapdragonController.Disconnect(self: SnapdragonInternal): ()
	if self.locked then
		error("[SnapdragonController] Cannot disconnect locked controller!", 2)
	end

	local ref = self:GetDragGui()

	local controller = controllers[ref]
	if controller then
		self.maid:DoCleaning()
		controllers[ref] = nil
	end
end

function SnapdragonController.Destroy(self: SnapdragonInternal): ()
	self:Disconnect()
	self.DragEnded:Destroy()
	self.DragBegan:Destroy()
	self.DragEnded = nil :: any
	self.DragBegan = nil :: any
	self.locked = true
end

return SnapdragonController
