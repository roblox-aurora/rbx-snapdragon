--!strict
const UserInputService = game:GetService("UserInputService")
const runService = game:GetService("RunService")

const Maid = require("../Maid")
const Snapdragon = require("../Types")
const DragAndDrop = require("./Types")

const SnapdragonController = require("../SnapdragonController")
const Types = require("../Types")

const SnapdragAndDropContext = {}
SnapdragAndDropContext.__index = SnapdragAndDropContext

type SnapdragAndDropContextProps = {
    dragSources: { [Snapdragon.SnapdragonRef]: DragAndDrop.DragSource },
    dropTargets: { [Snapdragon.SnapdragonRef]: DragAndDrop.DropTarget },
}

export type SnapdragAndDropContext = setmetatable<SnapdragAndDropContextProps, typeof(SnapdragAndDropContext)>

function SnapdragAndDropContext.new(): SnapdragAndDropContext
    local self: SnapdragAndDropContextProps = {
        dragSources = {},
        dropTargets = {}
    }

    return setmetatable(self, SnapdragAndDropContext)
end

local hostGui = Instance.new("ScreenGui")
hostGui.DisplayOrder = 1_000

local function assignConfig(config: Types.SnapdragonOptions, addendum: Types.Partial<Types.SnapdragonOptions>?): Types.SnapdragonOptions
    if addendum == nil then
        return config
    end

    local merged = table.clone(config) :: {[string]: any }
    for k, v in addendum :: {[string]: any }  do
        merged[k] = v
    end

    return merged :: Types.SnapdragonOptions
end

--- Registers the given snapdragon object as a draggable source
function SnapdragAndDropContext.RegisterDragSource(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef, options: DragAndDrop.DragSourceOptions)
    const raiseAbove = if options.RaiseAbove ~= nil then options.RaiseAbove else runService:IsClient()

    local mergedConfig = assignConfig({
        DragRelativeTo = "LayerCollector",
        DragEndedResetsPosition = true,
        CanDrag = options.CanDragSource,
        DragPositionMode = if raiseAbove then "AbsoluteOffset" else "Offset",
        SnapEnabled = false
    }, options.ControllerOptions)

    const controller = SnapdragonController.new(ref, mergedConfig)
    const maid = Maid.new()

    local dragSource: DragAndDrop.DragSource = {
        controller = controller,
        data = options.Data,
        gui = ref,
        margin = options.Margin,
        id = game:GetService("HttpService"):GenerateGUID(false),
        dropId = options.DropGroup,
        maid = maid,
    }
    self.dragSources[ref] = dragSource


    local originParent: Instance?
    local originSize: UDim2

    local localPlayer = game:GetService("Players").LocalPlayer

        
    local targets
    local lastTarget: DragAndDrop.DropTarget?

    maid.DragBegin = controller.DragBegan:Connect(function(event) 
        targets = {}

        if raiseAbove and localPlayer then
            local instance = ref.current

            originParent = instance.Parent
            originSize = instance.Size

            instance.Size = UDim2.new(0, instance.AbsoluteSize.X, 0, instance.AbsoluteSize.Y)
            instance.Parent = hostGui
            hostGui.Parent = localPlayer:WaitForChild("PlayerGui")
            
            assert(hostGui.Parent)
        end

        
        runService:BindToRenderStep("DragAndDrop", Enum.RenderPriority.First.Value, function(delta: number)
            targets = self:GetDropTargets(dragSource.gui)

            local currentTarget = targets[1]
            if currentTarget ~= lastTarget then
                if lastTarget and typeof(lastTarget.onHoverStop) == "function" then
                    lastTarget.onHoverStop(dragSource.data, dragSource.gui.current)
                end

                if currentTarget and typeof(currentTarget.onHover) == "function" then
                    currentTarget.onHover(dragSource.data, dragSource.gui.current)
                end

                lastTarget = currentTarget
            end
        end)
    end)

    controller.OnDragEnd = function()
        runService:UnbindFromRenderStep("DragAndDrop")
        
        if lastTarget and typeof(lastTarget.onHoverStop) == "function" then
            lastTarget.onHoverStop(dragSource.data, dragSource.gui.current)
        end
        lastTarget = nil

        if not targets then return end

        local dropped = false
        local droppedTarget: DragAndDrop.DropTarget?

        if #targets > 0 then
            for _, target in targets do
                if target.canDrop == nil or target.canDrop(dragSource.data) then
                    dropped = true
                    droppedTarget = target
                    break
                end
            end
        end

        if droppedTarget ~= nil and typeof(droppedTarget.onDrop) == "function" then
            droppedTarget.onDrop(dragSource.data, dragSource.gui.current)
        end

        if typeof(dragSource.dragEnd) == "function" then
            dragSource.dragEnd(dropped)
        end
    end

    maid.DragEnded = controller.DragEnded:Connect(function(event)
        if raiseAbove and localPlayer then
            local instance = ref.current
            instance.Parent = originParent
            instance.Size = originSize
            hostGui.Parent = nil
        end
    end)

    return controller
end

function SnapdragAndDropContext.GetDragSource(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef): DragAndDrop.DragSource?
    return self.dragSources[ref]
end

function SnapdragAndDropContext.GetDropTarget(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef): DragAndDrop.DropTarget?
    return self.dropTargets[ref]
end

function SnapdragAndDropContext.UpdateDragSourceData(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef, data: unknown)
    local target = self:GetDragSource(ref)
    if not target then return end
    target.data = data
end

function SnapdragAndDropContext.UnregisterDragSource(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef)
    local dragSource = self.dragSources[ref]
    if not dragSource then return end

    dragSource.controller:Destroy()
    dragSource.maid:DoCleaning()
    self.dragSources[ref] = nil
end


function SnapdragAndDropContext.RegisterDropTarget(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef, options: DragAndDrop.DropTargetOptions)
    self.dropTargets[ref] = {
        id = game:GetService("HttpService"):GenerateGUID(false),
        dropIds = options.DropGroups,
        gui = ref,
        onDrop = options.DroppedOnTarget,
        canDrop = options.CanDropOnTarget,
        priority = options.DropPriority or 1,
        onHover = options.HoveringOverTarget,
        onHoverStop = options.StoppedHoveringOverTarget,
    }
end

function SnapdragAndDropContext.UnregisterDropTarget(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef)
    local data = self.dropTargets[ref]
    if not data then return end

    self.dropTargets[ref] = nil
end

local function getClip(instance: GuiObject)
    if instance:IsA("ScrollingFrame") then
        return instance.AbsolutePosition, instance.AbsoluteSize
    elseif instance.ClipsDescendants then
        return instance.AbsolutePosition, instance.AbsoluteSize
    elseif instance.Parent and instance.Parent:IsA("GuiObject") then
        return getClip(instance.Parent)
    else
        return Vector2.new(), Vector2.new()
    end
end

local function pointIntersectsRect(point: Vector2, rect: Rect)
    local instanceStartPosition = rect.Min
    local instanceEndPosition = rect.Max

	return (
		    point.X >= instanceStartPosition.X
        and point.Y >= instanceStartPosition.Y
        and point.X <= instanceEndPosition.X
        and point.Y <= instanceEndPosition.Y
	)
end

local function intersectsPos(instPos: Vector2, instEndPos: Vector2, intersectPos: Vector2, intersectEndPos: Vector2)
	return (
		instEndPos.X > intersectPos.X
		and instEndPos.Y > intersectPos.Y
		and instPos.X < intersectEndPos.X
		and instPos.Y < intersectEndPos.Y
	)
end

local function intersects(source: GuiObject, target: GuiObject, sourceMargin: Rect?)
    const targetGuiPos = target.AbsolutePosition
    const targetGuiSize = target.AbsoluteSize

    const sourceGuiPos = source.AbsolutePosition
    const sourceGuiSize = source.AbsoluteSize

    local instPos = sourceGuiPos
    local instEndPos = sourceGuiPos + sourceGuiSize
    const intersectPos = targetGuiPos
    const intersectEndPos = targetGuiPos + targetGuiSize

    if sourceMargin ~= nil then
        instPos = Vector2.new(instPos.X + sourceMargin.Min.X, instPos.Y + sourceMargin.Min.Y)
        instEndPos = Vector2.new(instEndPos.X - sourceMargin.Max.X, instEndPos.Y - sourceMargin.Max.Y)
    end

	return (
		instEndPos.X > intersectPos.X
		and instEndPos.Y > intersectPos.Y
		and instPos.X < intersectEndPos.X
		and instPos.Y < intersectEndPos.Y
	)
end

local USE_MOUSE = false
function SnapdragAndDropContext.GetDropTargets(self: SnapdragAndDropContext, source: Snapdragon.SnapdragonRef): { DragAndDrop.DropTarget }
    const dragSource = self.dragSources[source]
    if not dragSource then return {} end

    const mouseLocation = UserInputService:GetMouseLocation()
    const dropTargets: { DragAndDrop.DropTarget } = {}

    const dragGui = source.current
    for k, v in self.dropTargets do
        const dropGui = k.current
        const hoverPos = if USE_MOUSE then mouseLocation else dragGui.AbsolutePosition + dragGui.AbsoluteSize / 2

        const clipPosition, clipSize = getClip(dropGui)
        if clipSize ~= Vector2.zero then
            local rect = Rect.new(clipPosition, clipPosition + clipSize)
            if not pointIntersectsRect(hoverPos, rect) then continue end
        end


        if not table.find(v.dropIds, dragSource.dropId) then continue end -- must match group

        const rect = Rect.new(dropGui.AbsolutePosition, dropGui.AbsolutePosition + dropGui.AbsoluteSize)

        if not pointIntersectsRect(hoverPos, rect) then continue end

        table.insert(dropTargets, v)
    end

    table.sort(dropTargets, function(a0: DragAndDrop.DropTarget, a1: DragAndDrop.DropTarget): boolean  
        return a0.priority > a1.priority
    end)

    return dropTargets
end

return SnapdragAndDropContext