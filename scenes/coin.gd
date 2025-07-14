extends Node2D

var speed = 300

func _ready() -> void:
	rotation_degrees = randi_range(0, 360)

func _physics_process(delta: float) -> void:
	if global_position.distance_to(get_global_mouse_position()) < 70:
		var mouse_pos = get_global_mouse_position()
		global_position = global_position.move_toward(mouse_pos, speed * delta)
		speed *= 1.1
		if global_position.distance_to(get_global_mouse_position()) < 20:
			data.coins += 1
			SoundManager.play_sound('coin', randf_range(0.9, 1.1), -10)
			queue_free()
	else:
		speed = 300
