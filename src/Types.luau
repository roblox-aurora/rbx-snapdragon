export type SnapdragonRef<T> = {
    Update: (self: SnapdragonRef<T>, value: T) -> (),
    Get: (self:  SnapdragonRef<T>) -> T,
}

export type SnapdragonGuiRef = SnapdragonRef<GuiObject>

export type SnapdragonRefType = {
    new: <T>(initialValue: T) -> SnapdragonRef<T>,
    is: (value: unknown) -> boolean,
}


export type SnapdragonMargins = { Vertical: Vector2?, Horizontal: Vector2? }

export type SnapdragonAxis = "X" | "XY" | "Y"
export type SnapdragonRelativeTo = "LayerCollector" | "Parent"
export type DragPositionMode = "Offset" | "Scale"
export type DragPredicate = () -> boolean

export type SnapdragonOptions = {
	DragGui: (GuiObject | SnapdragonRef<GuiObject>)?,
	DragThreshold: number?,
	DragGridSize: number?,
	SnapMargin: SnapdragonMargins?,
	SnapMarginThreshold: SnapdragonMargins?,
	SnapAxis: SnapdragonAxis?,
	DragAxis: SnapdragonAxis?,
	DragRelativeTo: SnapdragonRelativeTo,
	SnapEnabled: boolean?,
	Debugging: boolean?,
	DragPositionMode: DragPositionMode?,
	CanDrag: DragPredicate | nil,
	DragEndedResetsPosition: boolean?,
}

export type SnapdragonController = {
    SetSnapEnabled: (self: SnapdragonController, snapEnabled: boolean) -> (),
    SetSnapMargin: (self: SnapdragonController, margin: SnapdragonMargins) -> (),
    SetSnapThreshold: (self: SnapdragonController, threshold: SnapdragonMargins) -> (),
    GetDragGui: (self: SnapdragonController) -> (GuiObject, GuiObject),
    GetGui: (self: SnapdragonController) -> GuiObject,
    Connect: (self: SnapdragonController) -> SnapdragonController,
    Disconnect: (self: SnapdragonController) -> (),
    Destroy: (self: SnapdragonController) -> ()
}
export type SnapdragonControllerType = {
    new: (gui: GuiObject, options: SnapdragonOptions) -> SnapdragonController
}

return nil