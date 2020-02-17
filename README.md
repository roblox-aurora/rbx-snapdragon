Snapdragon
=============
A controller that makes a GuiObject draggable


API
-------------
```ts
declare interface SnapdragonController {
  Disconnect(): void
}
namespace Snapdragon {
  type SnapMargin = { Vertical?: Vector2; Horizontal?: Vector2 };

  interface SnapProps {
    SnapEnabled: boolean | undefined;
    SnapIgnoresOffset: boolean | undefined;
    SnapMargin: SnapMargin | undefined;
    SnapThresholdMargin?: SnapMargin;
  }

  interface DraggingSnapOptions {
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

 /**
 *
 * @param gui The gui that ends up being dragged
 * @param dragGui The draggable Gui (defaults to `gui`)
 * @param dragOptions Options relating to the dragging
 * @param dragSnapOptions Options relating to the snapping behaviour
 */
  export function createDragController(
	  gui: GuiObject,
	  dragGui?: GuiObject,
	  dragOptions?: DraggingOptions,
	  dragSnapOptions?: DraggingSnapOptions,
  ): SnapdragonController;
}
```
