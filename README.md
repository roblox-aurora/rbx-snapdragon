<!-- ![](Snapdragon.png) -->

<div align="center">
    <img src="Snapdragon.png" width="150">
    <h1>Snapdragon v2</h2>
    <p>
        Library for draggable UIs in Roblox, with snapping and drag & drop capabilities.
    </p>
</div>




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

# Drag and Drop
Work in progress feature to be UI library agnostic. This will allow you to set certain GUIs as drag sources, and others as "drop targets"

<!-- ## Usage with React
If you want to use Snapdragon with Roact, simply use `React.Ref` with the object you want to be draggable, and create and assign a controller in the `componentDidMount` method to the ref's instance.

## Usage with Roact
If you want to use Snapdragon with Roact, simply use `Roact.Ref` with the object you want to be draggable, and create and assign a controller in the `didMount` method to the ref's instance. -->

<!-- ## What about controller support?
I would like to add the ability for controllers to drag UI elements at some point. Some console games actually have a faux-mouse type dragging system, it would function in a similar fashion. -->

