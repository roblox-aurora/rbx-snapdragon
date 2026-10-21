--!strict

const Maid = require("../Maid")
const Snapdragon = require("../Types")
const DragAndDrop = require("./Types")

const SnapdragonController = require("../SnapdragonController")

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



--- Registers the given snapdragon object as a draggable source
function SnapdragAndDropContext.RegisterDragSource(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef, options: DragAndDrop.DragSourceOptions)
    const raiseAbove = if options.RaiseAbove ~= nil then options.RaiseAbove else true

    const controller = SnapdragonController.new(ref, {
        DragRelativeTo = "LayerCollector",
        DragEndedResetsPosition = true,
        CanDrag = options.CanDragSource,
    })

    const maid = Maid.new()

    local dragSource: DragAndDrop.DragSource = {
        controller = controller,
        data = options.Data,
        gui = ref,
        id = game:GetService("HttpService"):GenerateGUID(false),
        dropId = options.DropGroup,
        maid = maid,
    }
    self.dragSources[ref] = dragSource

    local originParent
    maid.DragBegin = controller.DragBegan:Connect(function(event) 
        if raiseAbove then
            local instance = ref:Get()
            originParent = instance.Parent
            hostGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

            instance.Parent = hostGui
        end
    end)
    
    maid.DragChange = controller.DragChanged:Connect(function(event: Snapdragon.DragChangedEvent)

    end)

    controller.OnDragEnd = function()
        local targets = self:GetDropTargets(ref)

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
            droppedTarget.onDrop(dragSource.data, dragSource.gui:Get())
        end

        if typeof(dragSource.dragEnd) == "function" then
            dragSource.dragEnd(dropped)
        end
    end

    maid.DragEnded = controller.DragEnded:Connect(function(event)
        if raiseAbove then
            local instance = ref:Get()
            instance.Parent = originParent
            hostGui.Parent = nil
        end
    end)

    return controller
end

function SnapdragAndDropContext.UnregisterDragSource(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef)
    local data = self.dragSources[ref]
    if not data then return end

    data.controller:Destroy()
    data.maid:DoCleaning()
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
    }
end

function SnapdragAndDropContext.UnregisterDropTarget(self: SnapdragAndDropContext, ref: Snapdragon.SnapdragonRef)
    local data = self.dropTargets[ref]
    if not data then return end

    self.dropTargets[ref] = nil
end

local function intersects(source: GuiObject, target: GuiObject)
    const targetGuiPos = target.AbsolutePosition
    const targetGuiSize = target.AbsoluteSize

    const sourceGuiPos = source.AbsolutePosition
    const sourceGuiSize = source.AbsoluteSize

    const instPos = sourceGuiPos
    const instEndPos = sourceGuiPos + sourceGuiSize
    const intersectPos = targetGuiPos
    const intersectEndPos = targetGuiPos + targetGuiSize

	return (
		instEndPos.X > intersectPos.X
		and instEndPos.Y > intersectPos.Y
		and instPos.X < intersectEndPos.X
		and instPos.Y < intersectEndPos.Y
	)
end

function SnapdragAndDropContext.GetDropTargets(self: SnapdragAndDropContext, source: Snapdragon.SnapdragonRef): { DragAndDrop.DropTarget }
    local dragSource = self.dragSources[source]
    if not dragSource then return {} end

    local dropTargets: { DragAndDrop.DropTarget } = {}

    local dragGui = source:Get()
    for k, v in self.dropTargets do
        local dropGui = k:Get()

        if not table.find(v.dropIds, dragSource.dropId) then continue end -- must match group
        if not intersects(dragGui, dropGui) then continue end -- must intersect

        table.insert(dropTargets, v)
    end

    table.sort(dropTargets, function(a0: DragAndDrop.DropTarget, a1: DragAndDrop.DropTarget): boolean  
        return a0.priority > a1.priority
    end)

    return dropTargets
end

return SnapdragAndDropContext