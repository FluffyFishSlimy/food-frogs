extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var speed = 300
var collected = false

func _ready() -> void:
	rotation_degrees = randi_range(0, 360)
	animation_player.play("spawn")
	await animation_player.animation_finished
	animation_player.play("passive")

func _physics_process(delta: float) -> void:
	if global_position.distance_to(get_global_mouse_position()) < 120:
		var mouse_pos = get_global_mouse_position()
		global_position = global_position.move_toward(mouse_pos, speed * delta)
		speed *= 1.1
		if global_position.distance_to(get_global_mouse_position()) < 20 and collected == false:
			collected = true
			data.coins += 1
			data.total_money += 1
			SoundManager.play_sound('coin', randf_range(0.9, 1.1), -10)
			data.coin_picked_up.emit()
			queue_free()
	else:
		speed = 300


func _on_timer_timeout() -> void:
	collected = true
	data.coins += 1
	#SoundManager.play_sound('coin', randf_range(0.9, 1.1), -10)
	data.coin_picked_up.emit()
	animation_player.stop()
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, 'scale', Vector2.ZERO, 0.3)
	await t.finished
	queue_free()
