<div align="center">
	<img src="https://raw.githubusercontent.com/Vorlias/Vorlias/master/assets/snapdragon.png"/>


</div>
<div align="center">
  	<h1>Snapdragon</h1>
	<a href="https://www.npmjs.com/package/@rbxts/snapdragon">
		<img src="https://badge.fury.io/js/%40rbxts%2Fsnapdragon.svg"></img>
	</a>
</div>

Library for UI dragging support, with snapping capabilities in Roblox.

Documentation for Snapdragon can be found at https://roblox-aurora.github.io/rbx-snapdragon


# Basic Usage
```ts
// Typescript
import { createDragController } from "@rbxts/snapdragon";
const controller = createDragController(gui, {SnapEnabled: true});
controller.Connect() // Attaches the controller to the gui you specify

controller.Disconnect() // Will disconnect the drag controller from the Gui
```

```lua
-- Lua
local Snapdragon = require(snapdragonModule)
local controller = Snapdragon.createDragController(gui, {SnapEnabled = true})
controller:Connect() -- Attaches the controller to the gui you specify

controller:Disconnect() -- Will disconnect the drag controller from the Gui
```

## Usage with Roact
If you want to use Snapdragon with Roact, simply use `Roact.Ref` with the object you want to be draggable, and create and assign a controller in the `didMount` method to the ref's instance.

# FAQ
## Why not just use `GuiObject.Draggable`?
`Draggable` is deprecated. It never worked well and isn't flexible - as discussed [here](https://devforum.roblox.com/t/draggable-property-is-hidden-on-gui-objects/107689/5?u=vorlias).

This library aims to add the ability to make your UI draggable without the extra work on your part, as well as make it more flexible with snapping capabilities and constraints (soon&trade;)

## What about controller support?
I would like to add the ability for controllers to drag UI elements at some point. Some console games actually have a faux-mouse type dragging system, it would function in a similar fashion.

# API
The API for Snapdragon can be found [here](index.d.ts)

There will eventually&trade; be proper docs for this library.
