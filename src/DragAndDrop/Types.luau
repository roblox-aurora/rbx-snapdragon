local types = require("../Types")
local maid = require("../Maid")

export type CanDropPredicate = (targetData: unknown) -> boolean
export type CanDragPredicate = () -> boolean

export type DroppedOnTargetCallback = (sourceData: unknown, sourceGui: GuiObject) -> ()
export type DragEndAction = (dropped: boolean) -> ()

export type DropGroupType = string | number

export type DragSource = {
	dropId: DropGroupType,
	data: unknown,
	gui: types.SnapdragonRef,
	dragBegin: (() -> ())?,
	target: unknown,
	id: string,
	dragEnd: DragEndAction?,
    controller: types.SnapdragonController,
	maid: maid.Maid
}

export type DropTarget = {
	gui: types.SnapdragonRef,
	dropIds: { DropGroupType },
	onDrop: DroppedOnTargetCallback?,
	priority: number,
	canDrop: CanDropPredicate?,
	id: string,
}


export type DragSourceOptions = {
    --- The group this source belongs to
    DropGroup: DropGroupType,
    --- The data that will be given to any drop targets that are valid
    Data: unknown,
    --- A predicate to check if this source can be dragged
    CanDragSource: CanDragPredicate?,
    --- Raise this drag source above everything else when dragged - defaults to `true`
    RaiseAbove: boolean?,
}

export type DropTargetOptions = {
    --- Drop groups accepted by this drop target
    DropGroups: { DropGroupType },
    --- A function invoked when a source is dropped on this target
    DroppedOnTarget: DroppedOnTargetCallback?,
    --- A predicate to determine if it's valid to drop on this target
    CanDropOnTarget: CanDropPredicate?,
    --- The priority of this target, higher means that even if it's overlapping another target it will take precedence
    DropPriority: number?;
}

return nil