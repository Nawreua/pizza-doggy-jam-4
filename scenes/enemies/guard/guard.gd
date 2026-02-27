extends RigidBody3D

@export var normal_speed: float = 3
@export var patrol: bool = true

var random_motion: Vector3 = Vector3.ZERO
var target: Node3D = null

func target_seen(body: Node3D):
	target = body
	$AudioStreamPlayer3D.stop()
	$AudioStreamPlayer3D.stream = load("res://assets/sounds/hey.wav")
	$AudioStreamPlayer3D.play()

func _physics_process(delta: float) -> void:
	# By default, we move following the random patrol
	var motion = random_motion * normal_speed
	
	# If player seen
	if target:
		motion = (target.position - position)
		motion.y = 0
		if not $AudioStreamPlayer3D.playing and randi() % 100 == 0:
			$AudioStreamPlayer3D.play()
	elif patrol:
		# At random, we recalculate the patrol
		if randi() % 20 == 0:
			random_motion = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
			if not $AudioStreamPlayer3D.playing and randi() % 20 == 0:
				$AudioStreamPlayer3D.play()
	
	var collision = move_and_collide(motion * delta)
	# If player caught
	if collision and collision.get_collider() is Player:
		get_tree().change_scene_to_file("res://levels/room213/room213.tscn")

func _on_sight_body_entered(body: Node3D) -> void:
	if body is Player:
		var query = PhysicsRayQueryParameters3D.create(position, body.position)
		query.exclude = [self]
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result.has(&"collider") and result[&"collider"] is Player:
			target_seen(body)
