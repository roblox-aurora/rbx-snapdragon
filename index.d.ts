import "@rbxts/types";

declare type SnapMargin = { Vertical?: Vector2; Horizontal?: Vector2 };
declare interface SnapProps {
	SnapEnabled: boolean | undefined;
	SnapIgnoresOffset: boolean | undefined;
	SnapMargin: SnapMargin | undefined;
	SnapThresholdMargin?: SnapMargin;
}

declare interface SnapdragonRef {
	Update(gui: GuiObject): void;
	Get(): GuiObject | undefined;
}

declare interface SnapdragonRefConstructor {
	new (gui?: GuiObject): SnapdragonRef;
	is(value: unknown): value is SnapdragonRef;
}

declare type DragPositionMode = "Scale" | "Offset";
declare type AxisConstraint = "XY" | "X" | "Y";

declare interface DraggingOptions {
	/**
	 * Overrides which object when dragged, will drag this object.
	 *
	 * Useful for things like titlebars
	 */
	DragGui?: GuiObject | SnapdragonRef;

	/**
	 * The amount of pixels the mouse must be held down before the dragging happens
	 * 
	 * Note: The bigger the threshold, the more "snappy" the initial drag may feel.
	 * 
	 * @todo
	 */
	DragThreshold?: number;

	/**
	 * @todo
	 */
	DragAxis?: AxisConstraint;

	/**
	 * @todo
	 */
	DragRelativeTo?: "LayerCollector" | "Parent";

	/**
	 * @todo
	 */
	DragGridSize?: number;

	/**
	 * @todo
	 */
	DragPositionMode?: DragPositionMode;
	
	/**
	 * The position is reset on drag end
	 */
	DragEndedResetsPosition?: boolean;

	/**
	 * Callback to whether or not to allow this component to drag
	 */
	CanDrag?: () => boolean;
}

declare interface DraggingSnapOptions {
	/**
	 * The margin to the edges of the parent container
	 */
	SnapMargin?: SnapMargin;

	/**
	 * The threshold margin for snapping to edges.
	 *
	 * It's additive to the snapMargin, so a margin of 20 + a snap threshold of 20 = total snapThreshold of 40.
	 *
	 * That means if the dragged object comes within 40 pixels, it will snap to the edge.
	 */
	SnapThreshold?: SnapMargin;

	/**
	 * Whether or not the snapping behaviour is enabled
	 *
	 * (true by default)
	 */
	SnapEnabled?: boolean;

	/**
	 * @todo
	 */
	SnapAxis?: AxisConstraint;
}

declare interface SnapdragonOptions extends DraggingSnapOptions, DraggingOptions {

}

declare interface Signal<
	ConnectedFunctionSignature = () => void,
	Generic = false
> {
	/**
	 * Connects a callback to BindableEvent.Event
	 * @param callback The function to connect to BindableEvent.Event
	 */
	Connect<
		O extends Array<unknown> = FunctionArguments<ConnectedFunctionSignature>
	>(
		callback: Generic extends true
			? FunctionArguments<ConnectedFunctionSignature> extends Array<
					unknown
			  >
				? (...args: O) => void
				: ConnectedFunctionSignature
			: ConnectedFunctionSignature,
	): RBXScriptConnection;

	/**
	 * Yields the current thread until the thread is fired.
	 */
	Wait(): LuaTuple<FunctionArguments<ConnectedFunctionSignature>>;
}

declare type Extents = "Float" | "Min" | "Max";

declare interface Vector2Extents {
	X: Extents,
	Y: Extents
}

declare interface DragBeganEvent {
	InputPosition: Vector3;
	GuiPosition: UDim2;
}

declare interface DragEndedEvent {
	InputPosition: Vector3;
	GuiPosition: UDim2;
	ReachedExtents: Vector2Extents;
}

declare interface DragChangedEvent {
	GuiPosition: UDim2;
	DragPositionMode?: DragPositionMode;
	SnapAxis?: AxisConstraint;
}

declare interface SnapdragonController {
	/**
	 * Stops this drag controller from listening for drag events.
	 * 
	 * Call `Destroy` to clean up this controller & all attached events such as `DragBegan`, `DragEnded`
	 */
	Disconnect(): void;

	/**
	 * Resets the position of the attached gui to the start position
	 */
	ResetPosition(): void;

	/**
	 * Event called when the dragging stops
	 */
	DragEnded: Signal<(event: DragEndedEvent) => void>;

	DragChanged: Signal<(event: DragChangedEvent) => void>;

	/**
	 * Event called when the dragging begins
	 */
	DragBegan: Signal<(event: DragBeganEvent) => void>;

	/**
	 * Connects this controller to the gui
	 */
	Connect(): void;

	/**
	 * Sets the snap margin
	 * @param snapMargin The snap margin
	 */
	SetSnapMargin(snapMargin: SnapMargin): void;

	/**
	 * Sets the snapping enabled
	 * @param snapEnabled Whether or not the snapping is enabled
	 */
	SetSnapEnabled(snapEnabled: boolean): void;

	/**
	 * The amount of pixels the mouse must be held down before the dragging happens
	 * 
	 * Note: The bigger the threshold, the more "snappy" the initial drag may feel.
	 * 
	 * @param dragThreshold The drag threshold
	 */
	SetDragThreshold(dragThreshold: number): void;

	/**
	 * Set the snap threshold
	 * @param snapThreshold The snap theshold
	 */
	SetSnapThreshold(snapThreshold: SnapMargin): void;

	/**
	 * Sets the drag gui
	 * @param dragGui The drag gui
	 */
	SetDragGui(dragGui: GuiObject): void;

	/**
	 * Fully cleans up this controller & locks it from further use.
	 * 
	 * Actions:
	 * - Calls `Disconnect` on this controller
	 * - Disconnects all `DragBegan` and `DragEnded` events.
	 * - Locks the controller from being used again
	 */
	Destroy(): void;
}

declare interface SnapdragonConstructor {
	/**
	 * Create a new snapdragon controller object
	 * @param gui The gui that ends up being dragged
	 * @param dragGui The draggable Gui (defaults to `gui`)
	 * @param dragSnapOptions The snap options
	 */
	new (
		gui: GuiObject | SnapdragonRef,
		options?: SnapdragonOptions,
	): SnapdragonController;
}

declare const SnapdragonController: SnapdragonConstructor;

// /**
//  * A reference for a gui object
//  * 
//  * This is useful for Roact-based UI
//  */
// declare const SnapdragonRef: SnapdragonRefConstructor;

declare function createRef(gui?: GuiObject): SnapdragonRef;

/**
 *
 * @param gui The gui that ends up being dragged
 * @param dragGui The draggable Gui (defaults to `gui`)
 * @param dragSnapOptions The snap options
 */
declare function createDragController(
	gui: GuiObject | SnapdragonRef,
	options?: SnapdragonOptions,
): SnapdragonController;

export as namespace Snapdragon;
export {
	createDragController,
	SnapProps,
	SnapMargin,
	SnapdragonOptions,
	SnapdragonController,
	createRef,
};
