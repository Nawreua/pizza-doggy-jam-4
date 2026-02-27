extends Area3D

@export var scene: String = ""
@export var stream: VideoStreamPlayer
@export var audio: AudioStreamPlayer3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.process_mode = Node.PROCESS_MODE_DISABLED
		audio.play()
		stream.play()

func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file(scene)
