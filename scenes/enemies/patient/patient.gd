extends RigidBody3D

var available_sounds = [
	"res://assets/sounds/cry_1.wav",
	"res://assets/sounds/groan_1.wav",
	"res://assets/sounds/groan_2.wav",
	"res://assets/sounds/laugh_1.wav",
]

func play_sound():
	# Load a sound at random
	$AudioStreamPlayer3D.stop()
	$AudioStreamPlayer3D.stream = load(available_sounds[randi() % available_sounds.size()])
	$AudioStreamPlayer3D.play()

func _ready() -> void:
	play_sound()

func _on_audio_stream_player_3d_finished() -> void:
	$Timer.start(randi() % 5 + 5)

func _on_timer_timeout() -> void:
	play_sound()
