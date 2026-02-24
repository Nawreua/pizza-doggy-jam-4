class_name Player extends CharacterBody3D

@export var speed: float = 5
@export var slowdown: float = 3
@export var rotation_speed: float = 0.5

@export var horizontal_sens: float = 0.003
@export var vertical_sens: float = 0.003

@onready var head = $Head

func _input(event: InputEvent) -> void:
	# Handle camera inputs
	if event is InputEventMouseMotion:
		head.rotation.x -= event.relative.y * vertical_sens
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-30.0), deg_to_rad(30.0))
		head.rotation.y -= event.relative.x * horizontal_sens
		head.rotation.y = clamp(head.rotation.y, deg_to_rad(-60.0), deg_to_rad(60.0))
		
	if event is InputEventKey:
		# Quit the game
		if event.is_action_pressed(&"exit"):
			get_tree().quit()
		
func _physics_process(delta: float) -> void:
	var input = Input.get_vector(&"turn_right", &"turn_left", &"move_backward", &"move_forward")
	
	rotation.y += input.x * rotation_speed * delta
	
	if input.y != 0:
		var angle = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		velocity += sign(input.y) * angle * speed * delta
		velocity.y = 0
	
	move_and_slide()
	
	# Slowdown
	velocity.x = sign(velocity.x) * max(abs(velocity.x) - (slowdown * delta), 0)
	velocity.z = sign(velocity.z) * max(abs(velocity.z) - (slowdown * delta), 0)
