# PlayerInventory.gd
class_name PlayerInventory
extends Node

@export var ui_display: Control # Reference to UI element showing current tool

var current_tool: Tool
var ui_icon_display: TextureRect # UI element to show tool icon

signal tool_changed(new_tool: Tool)

func _ready():
	# Find UI elements - adjust paths as needed for your UI setup
	if ui_display:
		ui_icon_display = ui_display.get_node("ToolIcon") as TextureRect
	update_ui()

func has_tool() -> bool:
	return current_tool != null

func get_current_tool() -> Tool:
	return current_tool

func add_tool(tool: Tool):
	current_tool = tool
	tool_changed.emit(tool )
	update_ui()

func remove_current_tool() -> Tool:
	var tool = current_tool
	current_tool = null
	tool_changed.emit(null)
	update_ui()
	return tool

func can_use_tool_on_tile(tile_source_id: int) -> bool:
	if not has_tool():
		return false
	return tile_source_id in current_tool.usable_on_tiles

func get_converted_tile(tile_source_id: int) -> int:
	if not has_tool():
		return -1
	
	var index = current_tool.usable_on_tiles.find(tile_source_id)
	if index != -1 and index < current_tool.converts_to_tiles.size():
		return current_tool.converts_to_tiles[index]
	return -1

func update_ui():
	if not ui_icon_display:
		return
		
	if has_tool():
		ui_icon_display.texture = current_tool.ui_icon
		ui_icon_display.visible = true
	else:
		ui_icon_display.visible = false
