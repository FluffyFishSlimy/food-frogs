extends Area2D

var bullet_damge:float = 1

func _ready() -> void:
	scale = Vector2.ZERO
	rotation_degrees = randi_range(0, 360)
	modulate.darkened(randf_range(0, 0.2))
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, 'scale', Vector2(randf_range(0.7, 0.9), randf_range(0.7, 0.9)), 0.2)
	SoundManager.play_sound('splat', randf_range(0.9, 1.1), -7)

func _on_timer_timeout() -> void:
	var t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_property(self, 'scale', Vector2.ZERO, 0.3)
	t.tween_property(self, 'modulate', Color.TRANSPARENT, 0.4)
	await t.finished
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	body.take_damage(bullet_damge)
	SoundManager.play_sound('tick', randf_range(0.8, 1.2), -10)
	data.dmg_num.emit(body.global_position, bullet_damge)
#
#func _process(delta: float) -> void:
	#position = lerp(position, Vector2(position.x+randf_range(-3, 3), position.y+randf_range(-3, 3)), 0.8)
