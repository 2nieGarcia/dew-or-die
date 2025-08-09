# ToolManager.gd - Manages tool creation and sprite setup
class_name ToolManager
extends Node

@export var ui_sprite_sheet: Texture2D  # Your single UI sprite file
@export var rack_sprite_sheet: Texture2D  # Your single tool rack sprite file
@export var animation_sprite_sheet: Texture2D  # Your single animation sprite file

# Sprite dimensions - adjust these based on your actual sprites
@export var ui_icon_size: Vector2 = Vector2(16, 16)
@export var rack_sprite_size: Vector2 = Vector2(16, 16)
@export var animation_frame_size: Vector2 = Vector2(16, 16)  # Assuming animation frames are also 16x16

var tool_ui_icons: Dictionary
var tool_rack_sprites: Array[Texture2D]
var tools: Array[Tool]

func _ready():
	setup_sprites()
	create_tools()

func setup_sprites():
	if ui_sprite_sheet:
		tool_ui_icons = AtlasTextureHelper.create_tool_ui_icons(ui_sprite_sheet, ui_icon_size)
	
	if rack_sprite_sheet:
		tool_rack_sprites = AtlasTextureHelper.create_tool_rack_sprites(rack_sprite_sheet, rack_sprite_size)

func create_tools() -> Array[Tool]:
	tools.clear()
	
	# Create Hoe (first in your sprite order)
	var hoe = Tool.new()
	hoe.tool_name = "Hoe"
	hoe.tool_type = Tool.ToolType.HOE
	hoe.ui_icon = tool_ui_icons.get("hoe")
	hoe.animation_name = "use_hoe"
	hoe.usable_on_tiles = [4, 5]  # dirt, soil - adjust based on your tile IDs
	hoe.converts_to_tiles = [5, 4]  # to soil, to dirt
	tools.append(hoe)
	
	# Create Shovel (second in your sprite order)
	var shovel = Tool.new()
	shovel.tool_name = "Shovel"
	shovel.tool_type = Tool.ToolType.SHOVEL
	shovel.ui_icon = tool_ui_icons.get("shovel")
	shovel.animation_name = "use_shovel"
	shovel.usable_on_tiles = [1, 5]  # grass, soil - adjust based on your tile IDs
	shovel.converts_to_tiles = [4, 1]  # to dirt, to grass
	tools.append(shovel)
	
	# Create Watering Can (third in your sprite order)
	var watering_can = Tool.new()
	watering_can.tool_name = "Watering Can"
	watering_can.tool_type = Tool.ToolType.WATERING_CAN
	watering_can.ui_icon = tool_ui_icons.get("watering_can")
	watering_can.animation_name = "use_watering_can"
	watering_can.usable_on_tiles = [5]  # soil only
	watering_can.converts_to_tiles = [5]  # keeps as soil
	tools.append(watering_can)
	
	return tools

func get_tools() -> Array[Tool]:
	return tools

func get_rack_sprites() -> Array[Texture2D]:
	return tool_rack_sprites

# Call this to setup animation frames for the player
func setup_player_tool_animations(animated_sprite: AnimatedSprite2D):
	if not animation_sprite_sheet:
		print("No animation sprite sheet assigned!")
		return
	
	# Create SpriteFrames for tool animations
	var sprite_frames = animated_sprite.sprite_frames
	if not sprite_frames:
		sprite_frames = SpriteFrames.new()
		animated_sprite.sprite_frames = sprite_frames
	
	# Your animation sheet layout: 2 columns, 12 rows
	# Each tool has 4 directions (down, up, left, right) with 2 frames each
	# Tools order: hoe, shovel, watering_can
	
	create_directional_tool_animation(sprite_frames, "use_hoe", 0)      # Rows 0-3
	create_directional_tool_animation(sprite_frames, "use_shovel", 4)   # Rows 4-7  
	create_directional_tool_animation(sprite_frames, "use_watering_can", 8)  # Rows 8-11

func create_directional_tool_animation(sprite_frames: SpriteFrames, base_animation_name: String, start_row: int):
	# Create animations for each direction
	var directions = ["_down", "_up", "_left", "_right"]
	
	for dir_index in range(4):
		var animation_name = base_animation_name + directions[dir_index]
		
		if sprite_frames.has_animation(animation_name):
			continue  # Animation already exists
		
		sprite_frames.add_animation(animation_name)
		sprite_frames.set_animation_speed(animation_name, 8.0)
		sprite_frames.set_animation_loop(animation_name, false)
		
		# Each direction has 2 frames (2 columns)
		var row = start_row + dir_index
		for frame in range(2):
			var atlas = AtlasTextureHelper.create_atlas_texture(
				animation_sprite_sheet,
				Rect2(frame * animation_frame_size.x, row * animation_frame_size.y, animation_frame_size.x, animation_frame_size.y)
			)
			sprite_frames.add_frame(animation_name, atlas)
