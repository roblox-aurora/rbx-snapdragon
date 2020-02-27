!!! info "Before you continue"
	Make sure you've installed Snapdragon for [TypeScript](../robloxts-install) or [Lua](../lua-install)


# Basic Usage, Part 1
To begin with, the main function you will be using with Snapdragon is `createDragController`.

`createDragController` takes two arguments - the gui that you want to be dragged around, and the options for the drag controller.

A basic example with a draggable GUI with default dragging options is as follows:

```Lua tab="" linenums="1"
local Snapdragon = require(snapdragonModule)

local connector = Snapdragon.createDragController(dragGui)
connector:Connect()
```

```ts tab="TypeScript" linenums="1"
import Snapdragon from "@rbxts/snapdragon";

const connector = Snapdragon.createDragController(dragGui);
connector.Connect();
```

Then when you want to disconnect or destroy the controller, you can do the following:

```lua tab="Lua" linenums="1"
-- Will just stop Snapdragon from making this draggable
connector:Disconnect();

-- Will fully destroy the controller + detach events, etc.
connector:Destroy();
```

```ts tab="TypeScript" linenums="1"
// Will just stop Snapdragon from making this draggable
connector.Disconnect();

// Will fully destroy the controller + detach events, etc.
connector.Destroy();
```

`Disconnect` will only stop the controller being active on the gui, `Destroy` will fully destroy the controller (including disconnecting it), making it further unusable.