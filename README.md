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

# Drag and Drop (Experimental)
Snapdragon has a drag & drop feature for making UI that is interactive.

There are two components to the drag and drop feature:
- Drag Sources: These are UI that are draggable w/ data that can be dropped on drop targets
- Drop Targets: These are UI that drag sources can be "dropped" on

Drag sources contain  _`DropGroup`_ - the group it belongs to - and drop targets contain _`DropGroups`_ - the groups it allows to drop on it.

- Drag groups can be numbers or strings.

Drag sources also contain _`Data`_, a value that is passed to any drop targets that validate and accept drag sources that are dropped on them.
- As an example, if you have an inventory you may use the slot index as the data to let the target know what the source slot was

# React
To use Snapdragon with React, you can pass a `React.Ref` to Snapdragon directly in place of a `SnapdragonRef` and it will bind to the component.

## Dragging UI (e.g. Windows)
```luau
const React = require(path.to.React)
const Snapdragon = require(path.to.Snapdragon)

-- A window that's dragged by the title
-- If you want it just draggable overall - omit DragGui from the controller options
local function WindowWithDraggableTitle(props)
    local windowRef = React.useRef()
    local titlebarRef = React.useRef()

    React.useEffect(function() 
        if not windowRef.current or not titlebarRef.current then return end -- snapdragon requires instances

        local controller = Snapdragon.createDragController(windowRef, {
            SnapEnabled = true, -- Enable snapping to edges
            DragGui = titlebarRef,
        })

        controller:Connect() -- enable dragging

        return function()
            controller:Destroy()
        end
    end, { windowRef, titlebarRef })

    return React.createElement("Frame", {
            ref = windowRef,
            Size = UDim2.fromOffset(800, 600)
        },
        React.createElement("TextLabel", {
            key = "Titlebar",
            ref = titlebarRef,
            Size = UDim2.new(1, 0, 0, 30),
            Text = "Title",
            TextSize = 20,
        })
        props.children
    )
end
```

## Drag and Drop (e.g. Inventory/Spell Slots)

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

