# Tool.gd - Resource script (Compatibility version)
class_name Tool
extends Resource

@export var tool_name: String = ""
@export var tool_type: ToolType = ToolType.NONE
@export var ui_icon: Texture2D
@export var animation_name: String = ""
@export var usable_on_tiles: Array = [] # Tile source IDs this tool can be used on (ints)
@export var converts_to_tiles: Array = [] # What tiles it converts to (ints, same order as usable_on_tiles)

enum ToolType {
	NONE,
	SHOVEL,
	HOE,
	WATERING_CAN
}
