# ToolRack.gd
class_name ToolRack
extends StaticBody2D

@export var tool_manager: ToolManager # Reference to ToolManager

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var tools: Array[Tool] = []
var rack_sprites: Array[Texture2D] = []
var current_tool_index: int = 0 # Which tool is currently in the rack
var is_empty: bool = false

signal tool_taken(tool: Tool)
signal tool_returned(tool: Tool)

func _ready():
	if tool_manager:
		tools = tool_manager.get_tools()
		rack_sprites = tool_manager.get_rack_sprites()
	update_sprite()

func interact(player: CharacterBody2D) -> bool:
	var player_inventory = player.get("inventory") as PlayerInventory
	if not player_inventory:
		print("Player doesn't have inventory component")
		return false
	
	if player_inventory.has_tool():
		# Try to return tool to rack
		if is_empty:
			var returned_tool = player_inventory.remove_current_tool()
			return_tool(returned_tool)
			return true
		else:
			print("Tool rack is full! Current tool: ", get_current_tool().tool_name)
			return false
	else:
		# Take tool from rack
		if not is_empty:
			var tool_to_take = get_current_tool()
			take_tool()
			player_inventory.add_tool(tool_to_take)
			return true
		else:
			print("Tool rack is empty!")
			return false

func get_current_tool() -> Tool:
	if is_empty or current_tool_index >= tools.size():
		return null
	return tools[current_tool_index]

func take_tool():
	if not is_empty:
		var tool = get_current_tool()
		is_empty = true
		tool_taken.emit(tool )
		update_sprite()

func return_tool(tool: Tool):
	# Find the tool in our array and set it as current
	for i in range(tools.size()):
		if tools[i].tool_name == tool .tool_name:
			current_tool_index = i
			break
	
	is_empty = false
	tool_returned.emit(tool )
	update_sprite()

func update_sprite():
	if rack_sprites.size() == 0:
		return
		
	if is_empty:
		sprite.texture = rack_sprites[0] # Empty rack
	else:
		var tool = get_current_tool()
		if not tool:
			return
			
		match tool .tool_type:
			Tool.ToolType.HOE:
				sprite.texture = rack_sprites[1] # hoe is index 1
			Tool.ToolType.SHOVEL:
				sprite.texture = rack_sprites[2] # shovel is index 2
			Tool.ToolType.WATERING_CAN:
				sprite.texture = rack_sprites[3] # watering_can is index 3

func set_tool(tool_type: Tool.ToolType):
	for i in range(tools.size()):
		if tools[i].tool_type == tool_type:
			current_tool_index = i
			is_empty = false
			update_sprite()
			break
