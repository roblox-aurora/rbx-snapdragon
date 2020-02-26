<div align="center">
	<img src="https://assets.vorlias.com/i1/snapdragon.png"/>

</div>
<div align="center">
  	<h1>Snapdragon</h1>
	<a href="https://www.npmjs.com/package/@rbxts/snapdragon">
		<img src="https://badge.fury.io/js/%40rbxts%2Fsnapdragon.svg"></img>
	</a>
</div>

Library for UI dragging support, with snapping capabilities in Roblox.

# Basic Usage
```ts
// Typescript
import { createDragController } from "@rbxts/snapdragon";
const controller = createDragController(gui, undefined, {SnapEnabled: true});
controller.Connect() // Attaches the controller to the gui you specify

controller.Disconnect() // Will disconnect the drag controller from the Gui
```

```lua
-- Lua
local Snapdragon = require(snapdragonModule)
local controller = Snapdragon.createDragController(gui, nil, {SnapEnabled = true})
controller:Connect() -- Attaches the controller to the gui you specify

controller:Disconnect() -- Will disconnect the drag controller from the Gui
```

## Usage with Roact
If you want to use Snapdragon with Roact, simply use `Roact.Ref` with the object you want to be draggable, and create and assign a controller in the `didMount` method to the ref's instance.

API
-------------
The API for Snapdragon can be found [here](index.d.ts)

There will eventually&trade; be proper docs for this library.