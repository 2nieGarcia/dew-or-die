extends CharacterBody2D

@export var speed = 100.0
@export var acceleration = 0.4
@export var friction = 0.1

@onready var animated_sprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D

var last_direction = Vector2(0, 1)

func _physics_process(delta):
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
	if event.is_action_pressed("interact"):
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			print("Interact button pressed! Raycast is hitting: ", collider.name)
		else:
			print("no interact yet")

func update_animation(input_dir):
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
