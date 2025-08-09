# Updated player.gd
extends CharacterBody2D

@export var speed = 100.0
@export var acceleration = 0.4
@export var friction = 0.1

@onready var animated_sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var inventory: PlayerInventory = $PlayerInventory

var last_direction = Vector2(0, 1)
var is_using_tool: bool = false

# Reference to the tilemap - set this in _ready or export it
@onready var tilemap: TileMap = get_parent().get_node("TileMap")
@export var tool_manager: ToolManager  # Reference to ToolManager

func _ready():
	# Connect inventory signals if needed
	if inventory:
		inventory.tool_changed.connect(_on_tool_changed)
	
	# Setup tool animations from sprite sheet
	if tool_manager:
		tool_manager.setup_player_tool_animations(animated_sprite)

func _physics_process(delta):
	if is_using_tool:
		return  # Don't move while using tool
		
	if last_direction != Vector2.ZERO:
		raycast.target_position = last_direction * 24
	
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_direction != Vector2.ZERO:
		last_direction = input_direction.normalized()
		velocity = velocity.lerp(last_direction * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)

	update_animation(input_direction)
	move_and_slide()

func _unhandled_input(event):
	if is_using_tool:
		return
		
	if event.is_action_pressed("interact"):
		handle_interaction()
	elif event.is_action_pressed("use_tool"):  # Add this input action
		use_current_tool()

func handle_interaction():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		if collider is ToolRack:
			collider.interact(self)
		else:
			print("Interacting with: ", collider.name)
	else:
		print("Nothing to interact with")

func use_current_tool():
	if not inventory.has_tool():
		print("No tool equipped!")
		return
		
	var tool = inventory.get_current_tool()
	var world_pos = global_position + (last_direction * 24)
	var tile_pos = tilemap.local_to_map(tilemap.to_local(world_pos))
	
	# Get current tile
	var current_tile_data = tilemap.get_cell_source_id(0, tile_pos)
	
	if inventory.can_use_tool_on_tile(current_tile_data):
		var new_tile = inventory.get_converted_tile(current_tile_data)
		
		# Start tool animation
		start_tool_animation(tool.animation_name)
		
		# Change the tile after a short delay (or immediately)
		await get_tree().create_timer(0.3).timeout  # Adjust timing as needed
		tilemap.set_cell(0, tile_pos, new_tile, Vector2i(0, 0))
		
	else:
		print("Can't use ", tool.tool_name, " on this tile!")

func start_tool_animation(animation_name: String):
	is_using_tool = true
	
	# Choose direction based on last_direction
	var direction_suffix = ""
	if last_direction.y < -0.5:
		direction_suffix = "_up"
	elif last_direction.y > 0.5:
		direction_suffix = "_down"
	elif last_direction.x < -0.5:
		direction_suffix = "_left"
	elif last_direction.x > 0.5:
		direction_suffix = "_right"
	else:
		direction_suffix = "_down"  # Default to down if no clear direction
	
	var full_animation_name = animation_name + direction_suffix
	animated_sprite.play(full_animation_name)
	
	# Wait for animation to finish
	await animated_sprite.animation_finished
	
	is_using_tool = false
	# Return to appropriate idle animation
	update_animation(Vector2.ZERO)

func update_animation(input_dir):
	if is_using_tool:
		return  # Don't change animation while using tool
		
	if input_dir == Vector2.ZERO:
		if last_direction.y < -0.5:
			animated_sprite.play("idle_up")
		elif last_direction.y > 0.5:
			animated_sprite.play("idle_down")
		elif last_direction.x < -0.5:
			animated_sprite.play("idle_left")
		elif last_direction.x > 0.5:
			animated_sprite.play("idle_right")
	else:
		if input_dir.y < -0.5:
			animated_sprite.play("walk_up")
		elif input_dir.y > 0.5:
			animated_sprite.play("walk_down")
		elif input_dir.x < -0.5:
			animated_sprite.play("walk_left")
		elif input_dir.x > 0.5:
			animated_sprite.play("walk_right")

func _on_tool_changed(new_tool: Tool):
	print("Tool changed to: ", new_tool.tool_name if new_tool else "None")
