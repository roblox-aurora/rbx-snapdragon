--!strict
local SnapdragonController = require("@self/SnapdragonController")
local SnapdragonRef = require("@self/SnapdragonRef")
local Types = require("@self/Types")

local function createDragController(gui: GuiObject, options: Types.SnapdragonOptions)
	return SnapdragonController.new(gui, options) :: Types.SnapdragonController
end

local function createRef(gui)
	return SnapdragonRef.new(gui)
end

type SnapdragonExport = {
	createDragController: (gui: GuiObject, options: Types.SnapdragonOptions) -> Types.SnapdragonController,
	SnapdragonController: Types.SnapdragonControllerType,
	createRef: <T>(initialValue: T) -> Types.SnapdragonRef<T>,
	VERSION: string,
}

local export = {
	createDragController = createDragController, 
	SnapdragonController = SnapdragonController :: Types.SnapdragonControllerType,
	createRef = createRef,
	VERSION = "2.2.0-beta.0"
}

-- roblox-ts `default` support
export.default = export
return export :: SnapdragonExport