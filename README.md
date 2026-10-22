<!-- ![](Snapdragon.png) -->

<div align="center">
    <img src="Snapdragon.png" width="150">
    <h1>Snapdragon v2</h2>
    <p>
        UI agnostic Roblox library for draggable UIs, with snapping and drag & drop capabilities.
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

# React
To use Snapdragon with React, you can pass a `React.Ref` to Snapdragon directly in place of a `SnapdragonRef` and it will bind to the component.

```luau
const React = require(path.to.React)
const Snapdragon = require(path.to.Snapdragon)
const dragContext = Snapdragon.createDragAndDropContext()


-- Make a draggable frame component
local function DragFrame(props)
    local ref = React.useRef()
    React.useEffect(function() 
        if not ref.current then return end -- snapdragon requires an instance

        local drag = dragContext:RegisterDragSource(ref, {
            DropGroup = "ExampleGroup",
            Data = "Some data here"
        })

        drag:Connect() -- enable the drag behaviour
        return function()
            dragContext:UnregisterDragSource(ref) -- destroy the source on unmount
        end
    end, { ref --[[ we update on ref change ]] })

    return React.createElement("Frame", {
        ref = ref,
        Size = UDim2.fromOffset(0, 100, 0, 100),
    }, props.children)
end
```

<!-- ## Usage with React
If you want to use Snapdragon with Roact, simply use `React.Ref` with the object you want to be draggable, and create and assign a controller in the `componentDidMount` method to the ref's instance.

## Usage with Roact
If you want to use Snapdragon with Roact, simply use `Roact.Ref` with the object you want to be draggable, and create and assign a controller in the `didMount` method to the ref's instance. -->

<!-- ## What about controller support?
I would like to add the ability for controllers to drag UI elements at some point. Some console games actually have a faux-mouse type dragging system, it would function in a similar fashion. -->

