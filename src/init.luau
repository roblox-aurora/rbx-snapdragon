--!strict
local SnapdragonController = require("@self/SnapdragonController")
local SnapdragonRef = require("@self/SnapdragonRef")
local Types = require("@self/Types")
local DragAndDrop = require("@self/DragAndDrop/DragAndDropContext")

local function createDragController(gui: GuiObject, options: Types.SnapdragonOptions)
	return SnapdragonController.new(gui, options) :: Types.SnapdragonController
end

local function createDragAndDropContext()
	return DragAndDrop.new()
end

local function createRef(gui)
	return SnapdragonRef.new(gui)
end

type Snapdragon = {
	createDragController: (gui: GuiObject, options: Types.SnapdragonOptions) -> Types.SnapdragonController,
	SnapdragonController: Types.SnapdragonControllerType,
	createRef: (initialValue: GuiObject) -> Types.SnapdragonRef,
	createDragAndDropContext: () -> DragAndDrop.SnapdragAndDropContext,
}

local Snapdragon = {
	createDragController = createDragController, 
	createDragAndDropContext = createDragAndDropContext,
	SnapdragonController = SnapdragonController :: Types.SnapdragonControllerType,
	createRef = createRef,
}

-- roblox-ts `default` support
Snapdragon.default = Snapdragon
return Snapdragon :: Snapdragon