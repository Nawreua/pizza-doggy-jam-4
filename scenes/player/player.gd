class_name Player extends CharacterBody3D

@export var speed: float = 5
@export var slowdown: float = 3
@export var rotation_speed: float = 0.75
@export var first_person: bool = true

var falling_speed: float = 9.1

var current_camera: Camera3D = null

@export var horizontal_sens: float = 0.003
@export var vertical_sens: float = 0.003

@onready var head = $Head
@onready var shoulder = $Shoulder
@onready var light = $SpotLight3D
@onready var audio = $AudioStreamPlayer3D
@onready var guide = $Guide

func capture_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func shift_perspective():
	if first_person:
		head.visible = true
		$old.visible = false
		shoulder.visible = false
		$wheelchair.visible = true
		current_camera = head
		#guide.visible = true
	else:
		head.visible = false
		$old.visible = true
		shoulder.visible = true
		$wheelchair.visible = false
		current_camera = shoulder
		#guide.visible = false
	current_camera.make_current()

func unsettle():
	var tween = get_tree().create_tween()
	await tween.tween_property(current_camera, "fov", 179, 1).finished
	# get_tree().change_scene_to_file("res://levels/room213/room213.tscn")
	get_tree().reload_current_scene()

func erode_shader(value: float):
	$CanvasLayer/ColorRect.set_instance_shader_parameter("opacity", value)
	$CanvasLayer/ColorRect.set_instance_shader_parameter("noise_intensity", min(value, 0.3))

func _ready() -> void:
	capture_mouse()
	shift_perspective()
	# Setup shader erosion
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(erode_shader, 0.1, 1.0, 120)

func _input(event: InputEvent) -> void:
	# Handle camera inputs
	if event is InputEventMouseMotion:
		current_camera.rotation.x -= event.relative.y * vertical_sens
		current_camera.rotation.x = clamp(current_camera.rotation.x, deg_to_rad(-30.0), deg_to_rad(30.0))
		current_camera.rotation.y -= event.relative.x * horizontal_sens
		current_camera.rotation.y = clamp(current_camera.rotation.y, deg_to_rad(-50.0), deg_to_rad(50.0))
		
		light.rotation.x = current_camera.rotation.x + deg_to_rad(7.5)
		light.rotation.y = current_camera.rotation.y
		
	if event is InputEventKey:
		# Switch torchlight
		if event.is_action_pressed(&"action_light"):
			light.visible = not light.visible
		# Perspective shift
		if event.is_action_pressed(&"camera_shift"):
			first_person = not first_person
			shift_perspective()
		# Quit the game
		if event.is_action_pressed(&"exit"):
			get_tree().quit()
		
func _physics_process(delta: float) -> void:
	var input = Input.get_vector(&"turn_right", &"turn_left", &"move_backward", &"move_forward")
	
	# Tank control
	rotation.y += input.x * rotation_speed * delta
	if input.y != 0:
		var angle = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		velocity += sign(input.y) * angle * speed * delta
		velocity.y = 0
		
	# Handle audio
	if input.x != 0 or input.y != 0:
		if not audio.playing:
			audio.play()
	
	# Gravity
	if not is_on_floor():
		velocity.y = velocity.y - (falling_speed * delta)
	
	move_and_slide()
	
	# Slowdown
	velocity.x = sign(velocity.x) * max(abs(velocity.x) - (slowdown * delta), 0)
	velocity.z = sign(velocity.z) * max(abs(velocity.z) - (slowdown * delta), 0)
	
	# If speed falls below 0, cut audio
	if input.x == 0 and input.y == 0:
		if velocity.x > -0.01 and velocity.x < 0.01 and velocity.z > -0.01 and velocity.z < 0.01:
			audio.stop()
