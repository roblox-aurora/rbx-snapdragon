local Signal = require("./Signal")

export type SnapdragonRef = {
    read current: GuiObject, -- makes it compatible with react and roact
}

type ReactLikeRef = { current: unknown }
type RoactLikeRef = { getValue: () -> unknown }

export type SnapdragonRefType = {
    new: <T>(initialValue: GuiObject) -> SnapdragonRef,
    toRef: (value: ReactLikeRef | RoactLikeRef | SnapdragonRef | GuiObject) -> SnapdragonRef,
    is: (value: unknown) -> boolean,
}


export type SnapdragonMargins = { Vertical: Vector2?, Horizontal: Vector2? }

export type SnapdragonAxis = "X" | "XY" | "Y"
export type SnapdragonRelativeTo = "LayerCollector" | "Parent"
export type DragPositionMode = "Offset" | "Scale" | "AbsoluteOffset"

export type function Partial(object: type)
	local tag = object.tag

	if tag == "union" or tag == "intersection" then
		local result

		for _, component in object:components() do
			if component.tag == "nil" then
				continue
			end
			if result == nil then
				result = component
				continue
			end

			result = types.unionof(result, component)
		end

		return types.optional(result :: type)
	elseif tag == "table" then
		local result = types.newtable()

		for key, prop in object:properties() do
			local partialRead = Partial(prop.read)
			if prop.read ~= prop.write then
				result:setreadproperty(key, partialRead)
				result:setwriteproperty(key, prop.write)
			else
				result:setproperty(key, partialRead)
			end
		end

		return result
	end

	return types.optional(object)
end

export type DragEndCallback = () -> ()
export type DragPredicate = () -> boolean

export type SnapdragonOptions = {
	DragGui: (GuiObject | SnapdragonRef)?,
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

export type DragBeganEvent = {
    AbsolutePosition: Vector2,
    InputPosition: Vector3,
    GuiPosition: UDim2,
}

export type DragChangedEvent = {
    GuiPosition: UDim2,
    SnapAxis: SnapdragonAxis?,
    DragPositionMode: DragPositionMode?,
}

export type DragEndedEvent = {
    InputPosition: Vector3,
    GuiPosition: UDim2,
    ReachedExtents: nil,
    DraggedGui: GuiObject,
}

export type SnapdragonController = {
    SetSnapEnabled: (self: SnapdragonController, snapEnabled: boolean) -> (),
    SetSnapMargin: (self: SnapdragonController, margin: SnapdragonMargins) -> (),
    SetSnapThreshold: (self: SnapdragonController, threshold: SnapdragonMargins) -> (),
    GetDragGui: (self: SnapdragonController) -> (GuiObject, GuiObject),
    GetGui: (self: SnapdragonController) -> GuiObject,
    Connect: (self: SnapdragonController) -> SnapdragonController,
    Disconnect: (self: SnapdragonController) -> (),
    Destroy: (self: SnapdragonController) -> (),

    DragBegan: Signal.Signal1<DragBeganEvent>,
    DragChanged: Signal.Signal1<DragChangedEvent>,
    DragEnded: Signal.Signal1<DragEndedEvent>,

    OnDragEnd: DragEndCallback?,
}
export type SnapdragonControllerType = {
    new: (gui: GuiObject, options: SnapdragonOptions) -> SnapdragonController
}

export type Set<T> = { [T]: true? }

return nil