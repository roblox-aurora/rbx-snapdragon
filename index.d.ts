import "@rbxts/types";

declare type SnapMargin = { Vertical?: Vector2; Horizontal?: Vector2 };
declare interface SnapProps {
	SnapEnabled: boolean | undefined;
	SnapIgnoresOffset: boolean | undefined;
	SnapMargin: SnapMargin | undefined;
	SnapThresholdMargin?: SnapMargin;
}

declare interface DraggingOptions {
	/**
	 * Overrides which object when dragged, will drag this object.
	 * 
	 * Useful for things like titlebars
	 */
	dragGui?: GuiObject;
}

declare interface DraggingSnapOptions {
	/**
	 * The margin to the edges of the parent container
	 */
	snapMargin?: SnapMargin;

	/**
	 * The threshold margin for snapping to edges.
	 * 
	 * It's additive to the snapMargin, so a margin of 20 + a snap threshold of 20 = total snapThreshold of 40.
	 * 
	 * That means if the dragged object comes within 40 pixels, it will snap to the edge.
	 */
	snapThreshold?: SnapMargin;

	/**
	 * Whether or not the snapping behaviour is enabled
	 * 
	 * (true by default)
	 */
	snapEnabled?: boolean;
}

declare interface Signal<ConnectedFunctionSignature = () => void, Generic = false> {
	/**
	 * Connects a callback to BindableEvent.Event
	 * @param callback The function to connect to BindableEvent.Event
	 */
	Connect<O extends Array<unknown> = FunctionArguments<ConnectedFunctionSignature>>(
		callback: Generic extends true
			? (FunctionArguments<ConnectedFunctionSignature> extends Array<unknown>
					? (...args: O) => void
					: ConnectedFunctionSignature)
			: ConnectedFunctionSignature,
	): RBXScriptConnection;

	/**
	 * Yields the current thread until the thread is fired.
	 */
	Wait(): LuaTuple<FunctionArguments<ConnectedFunctionSignature>>;
}

declare interface SnapdragonController {
	/**
	 * Disconnects the drag listeners
	 */
	Disconnect(): void;

	/**
	 * Resets the position of the attached gui to the start position
	 */
	ResetPosition(): void;

	/**
	 * Event called when the dragging stops
	 */
	DragFinished: Signal<(position: Vector3) => void>;

	/**
	 * Event called when the dragging begins
	 */
	DragBegan: Signal<(position: Vector3) => void>;
}

/**
 *
 * @param gui The gui that ends up being dragged
 * @param dragGui The draggable Gui (defaults to `gui`)
 * @param dragSnapOptions The snap options
 */
declare function createDragController(
	gui: GuiObject,
	dragOptions?: DraggingOptions,
	dragSnapOptions?: DraggingSnapOptions,
): SnapdragonController;

export as namespace Snapdragon;
export {createDragController, SnapProps, SnapMargin, DraggingOptions, DraggingSnapOptions};